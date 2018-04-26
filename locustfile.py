from locust import HttpLocust, TaskSet

def existing(conn):
    conn.client.get("/")

def non_existing(conn):
    conn.client.get("/blah")

class UserBehavior(TaskSet):
    tasks = {existing: 2, non_existing: 1}

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 2000
    max_wait = 10000
