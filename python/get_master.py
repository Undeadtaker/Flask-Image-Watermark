import boto3


def search_main(role):
	ec2 = boto3.resource('ec2')
	instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])

	for instance in instances:
		if instance.tags[0].get('Value') == role:
			print(instance.public_ip_address)


if __name__ == "__main__":
	search_main("vpc master")