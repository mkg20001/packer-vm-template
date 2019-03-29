#!/bin/bash

set -e

# TODO: integrate into packer.json (call after build as a post processor)

NAME=$(dir -w 1 | grep ^vm-)
NAME=${NAME/"vm-"/""}

cd "$(dir -w 1 | grep ^vm-)"

XML_SOUNDCARD="      <Item>
        <rasd:AddressOnParent>3</rasd:AddressOnParent>
        <rasd:AutomaticAllocation>false</rasd:AutomaticAllocation>
        <rasd:Caption>sound</rasd:Caption>
        <rasd:Description>Sound Card</rasd:Description>
        <rasd:ElementName>sound</rasd:ElementName>
        <rasd:InstanceID>6</rasd:InstanceID>
        <rasd:ResourceSubType>ensoniq1371</rasd:ResourceSubType>
        <rasd:ResourceType>35</rasd:ResourceType>
      </Item>"

XML_AHCI="        <rasd:ResourceSubType>AHCI</rasd:ResourceSubType>
        <rasd:ResourceType>20</rasd:ResourceType>"

XML_LSCI="        <rasd:ResourceSubType>lsilogic</rasd:ResourceSubType>
        <rasd:ResourceType>6</rasd:ResourceType>"

mv $NAME.ovf $NAME-vbox.ovf
VMWARE=$(cat $NAME-vbox.ovf | sed "s|<vssd:VirtualSystemType>virtualbox-2.2</vssd:VirtualSystemType>|<vssd:VirtualSystemType>vmx-08</vssd:VirtualSystemType>|g")
VMWARE=${VMWARE/"$XML_SOUNDCARD"/""}
VMWARE=${VMWARE/"$XML_AHCI"/"$XML_LSCI"}
echo "$VMWARE" > $NAME-vmware.ovf
