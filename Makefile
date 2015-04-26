slave   ?= 1
region  ?= us-east-1
zone    ?= us-east-1a
key     = $(USER)-default
ec2_env = ~/ec2-environment.sh

$(ec2_env):
	bash ~cs61c/ec2-init.sh

genenv: $(ec2_env)

launch: $(ec2_env)
	source $< && \
	spark-ec2 $@ --slaves $(slave) --instance-type=c1.xlarge --region=$(region) --zone=$(zone) $(USER)

get-master: $(ec2_env) 
	source $< && spark-ec2 $@ $(USER) 

login: $(ec2_env)
	source $< && spark-ec2 $@ $(USER)
	
destroy: $(ec2_env) 
	source $< && spark-ec2 destroy $(USER)
	ec2-delete-group -k $(key)

clean:
	rm -rf ~/.aws-* ~/.boto ~/.s3cfg ~/ec2-environment.sh ~/$(USER)-default.pem

.PHONY: genenv launch destory clean
