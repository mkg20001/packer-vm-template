build: prepare
	packer build -var-file=../variables.json packer.json

prepare:
	# create prov
	rm -rf provision
	mkdir provision
	# pack repo
	cd .. && git clone . --bare shared/provision/.git && git clone shared/ --bare shared/provision/.git/modules/shared && cd shared
	cd provision && tar cvfzp git.tar.gz .git && cd ..
	# create deploy in main folder
	rm -rf node_modules package-lock.json
	npm i
	OVERRIDE_LOCATION=/usr/lib/$(VM_NAME) npx dpl-tool ../deploy.yaml > provision/deploy.sh
	# run custom prov
	PROV=$(PWD)/shared/provision make -C $(PWD) prepare
	# prepare
	tar cvfz provision.tar.gz provision/
	mv provision.tar.gz provision/bundle.tar.gz
export:
	bash scripts/post-process.sh
	tar cvf vm.tar.xz --lzma vm-$(VM_NAME)
	mv vm.tar.xz ..

dev:
	cp Vagrantfile ..
	sed -s "s|VMNAME|$(VM_NAME)|g" -i ../Vagrantfile
	cd .. && rm -rf node_modules package-lock.json && npm i && OVERRIDE_LOCATION=/usr/lib/$(VM_NAME) npx dpl-tool deploy.yaml > deploy.sh && vagrant up

dist: build export
