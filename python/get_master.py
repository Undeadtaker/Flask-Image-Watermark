import boto3


def search_main(role):
	ec2 = boto3.resource('ec2')
	instances = ec2.instances.filter(Filters=[{'Name': 'instance-state-name', 'Values': ['running']}])
	print([instance.public_ip_address for instance in instances for tag in instance.tags if tag.get('Value') == role][0])


if __name__ == "__main__":
	search_main("vpc master")