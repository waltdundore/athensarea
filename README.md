# AthensArea

AthensArea is a small demo of serving a static news site with a few infrastructure helpers. The focus is on showing how Docker, Ansible and Vagrant can work together.

## Repository layout

- **public/** – HTML and CSS for the demo site
- **Dockerfile** – builds a tiny Node container to serve the files
- **docker-compose.yml** – runs the app container alongside an example Postgres service
- **ansible/** – inventory and playbook for deploying the stack to a server
- **Vagrantfile** – local VM with Docker and Ansible preinstalled
- **bootstrap.sh** – script that installs Ansible and clones a configuration repo

## Running locally with Docker

To view the site immediately, build and start the containers:

```bash
docker-compose up --build
```

Visit `http://localhost:3000` to see the page. Stop the stack with:

```bash
docker-compose down
```

## Automated deployment with Ansible

The Ansible playbook installs Docker on the target host and launches the same compose setup. Run it with:

```bash
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbook.yml --ask-become-pass
```

## Development VM with Vagrant

The provided `Vagrantfile` brings up a Debian-based VM that already has Docker and Ansible installed.

```bash
vagrant up
```

Log in with `vagrant ssh` to experiment inside the VM.

## License

This project is licensed under the GNU General Public License v3.0. See the [LICENSE](LICENSE) file for details.
