slaves  ?= 5
inst    ?= c3.8xlarge
region  ?= us-east-1
zone    ?= us-east-1a
key     = $(USER)-default
ec2_env = ~/ec2-environment.sh
p_key   = ~/$(USER)-default.pem

$(ec2_env):
	cd ~ && bash ~cs61c/ec2-init.sh

account: $(ec2_env)

launch: $(ec2_env)
	source $< && \
	spark-ec2 $@ --slaves $(slaves) --instance-type=$(inst) --region=$(region) --zone=$(zone) $(USER)

resume: $(ec2_env)
	source $< && spark-ec2 launch --resume $(USER)

master: $(ec2_env) 
	source $< && spark-ec2 get-$@ $(USER) | tail -n 1 | tee $@

login: $(ec2_env) master
	python scp_env.py $(p_key) $<
	source $< && spark-ec2 $@ $(USER)
	
destroy: $(ec2_env) 
	source $< && spark-ec2 destroy $(USER)

clean:
	rm -rf master ~/.aws-* ~/.boto ~/.s3cfg $(ec2_env) $(p_key) 

.PHONY: genenv launch master destory clean
