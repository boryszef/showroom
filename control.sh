# List of services to start
services=('ssh' 'apache2')

# Start services
for serv in "${services[@]}"; do
	echo "Starting service $serv ..."
	/usr/sbin/service $serv start
	estat=$?
	if [ $estat -ne 0 ]; then
		echo "Service $serv failed to start."
		exit $estat
	fi
done

# Every 1 minute check if there are any services still running
while sleep 60; do
	count_running=0
	for serv in "${services[@]}"; do
		/usr/sbin/service $serv status | grep -q "is running$"
		stat=$?
		if [ $stat == 0 ]; then
			count_running=$(( $count_running + 1))
		fi
	done
	if [ $count_running == 0 ]; then
		echo "All processes have finished, exiting."
		exit 0
	fi
done
