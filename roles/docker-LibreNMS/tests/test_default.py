import testinfra.utils.ansible_runner

testinfra_hosts = testinfra.utils.ansible_runner.AnsibleRunner(
    '.molecule/ansible_inventory').get_hosts('all')

def test_service(Service):
    present = [
        "docker"
    ]

if present:
        for service in present:
            s = Service(service)
            assert s.is_running
            assert s.is_enabled

# def test_files(File):
#     present = [
#         "/etc/nginx/nginx.conf",
#     ]

# if present:
#         for file in present:
#             f = File(file)
#             assert f.exists
#             assert f.is_file

def test_packages(Package):
    present = [
        "docker"
    ]

if present:
        for package in present:
            p = Package(package)
            assert p.is_installed

def test_directories(File):
    present = [
        "/tank/docker/",
        "/tank/docker/containers/",
        "/tank/docker/containers/transmission/",
        "/tank/docker/containers/transmission/data/",
        "/tank/docker/containers/transmission/data/watch",
        "/tank/docker/containers/transmission/config/",
    ]
absent = [
        "/var/www/html",
        "/etc/nginx/sites-enabled/default",
        "/etc/nginx/sites-available/default",
    ]
    
if present:
        for directory in present:
            d = File(directory)
            assert d.is_directory
            assert d.exists

if absent:
        for directory in absent:
            d = File(directory)
            assert not d.exists