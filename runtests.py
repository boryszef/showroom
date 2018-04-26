import unittest
import subprocess
import socket
from paramiko import SSHClient, AutoAddPolicy
from paramiko import AuthenticationException, SSHException
import time
import urllib.request as urlreq
import os
import csv

container_name = os.environ['IMAGENAME']
password = os.environ['PASSWORD']
maxconnections = os.environ['MAXCONNECTIONS']
locustsuffix = os.environ['LOCUSTSUFFIX']


ports = { 'http' : (8080, 80), 'ssh' : (2222, 22) }


class ImgtecContainer(unittest.TestCase):

    '''Perform functional tests on the container'''

    container_id = None

    def setUp(self):

        '''Start the container and keep its ID for tearDown method'''

        command = "docker run -d"
        for p1,p2 in ports.values():
            command += " -p {}:{}".format(p1, p2)
        command += " -t {}".format(container_name)

        self.container_id = subprocess.getoutput(command)

        # Wait 3 seconds to make sure that all processes are ready
        time.sleep(3)

    def tearDown(self):

        '''Bring down the container'''

        command = [ 'docker', 'kill', self.container_id ]
        subprocess.run(command, stdout=subprocess.DEVNULL)

    def test_ssh(self):

        '''Establish the connection to SSH deamon and make sure
        it works by checking if no exception are raised by paramiko'''

        with SSHClient() as client:
            client.set_missing_host_key_policy(AutoAddPolicy)
            try:
                client.connect(hostname='127.0.0.1',
                               port=ports['ssh'][0],
                               username='root',
                               password=password)
            except (AuthenticationException,
                    SSHException,
                    socket.error) as err:
                self.fail('ssh connection failed with {}'.format(err))

    def test_http(self):

        '''Connect to Apache using standard urllib.request and
        confirm it works by checking if status is 200'''

        url = "http://127.0.0.1:{}".format(ports['http'][0])
        with urlreq.urlopen(url) as conn:
            self.assertEqual(conn.status, 200)

    def test_many(self):

        '''Open multiple connections and make sure that the web server
        can handle them. Uses locust package to generate statistics.'''

        command = ['locust', '-f', 'locustfile.py', '--no-web', '--only-summary']
        command.append('--host=http://localhost:{}'.format(ports['http'][0]))
        command.append(('--csv={}'.format(locustsuffix)))
        command.extend(('-c', str(maxconnections)))
        command.extend(('-t', '2m'))
        print(command)
        subprocess.run(command)
        with open('{}_requests.csv'.format(locustsuffix)) as csvfile:
            reader = csv.reader(csvfile, delimiter=',', quotechar='"')
            for row in reader:
                if row[1] == "/":
                    # This resource exists
                    self.assertEqual(int(row[3]), 0)
                elif row[1] == "/blah":
                    # This resource does not exist
                    self.assertEqual(int(row[2]), 0)



if __name__ == '__main__':
    unittest.main()
