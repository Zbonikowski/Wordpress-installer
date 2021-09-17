#!/bin/bash


#help func
Help()
{
        echo "Usage: `basename $0` <domain eg. asd.com> '<site name>' <username> <email>"
}

#install func
Install(){
        export databasePass=$(openssl rand -base64 12)
        export databaseUser=$1UserDB
        export databaseName=$1Wordpress
        export databaseHost='localhost'
        export siteUrl=$1
        export siteTitle=$2
        export adminUser=$3
        export adminPass=$(openssl rand -base64 8)
        export adminEmail=$4

        echo $databasePass
        echo $databaseUser
        echo $databaseName
        echo $siteTitle
        echo $adminUser
        echo $adminPass
        echo $adminEmail

        #Get all data
        wget http://wordpress.org/latest.tar.gz
        wget -O ./wp.keys https://api.wordpress.org/secret-key/1.1/salt/

        #untar and move
        tar zxf ./latest.tar.gz
        mv wordpress/* ./

        #change wp-config.php
        sed -e "s/localhost/"$mysqlhost"/" -e "s/database_name_here/"$mysqldb"/" -e "s/username_here/"$mysqluser"/" -e "s/password_here/"$mysqlpass"/" wp-config-sample.php > wp-config.php
        sed -i '/#@-/r ./wp.keys' wp-config.php
        sed -i "/#@+/,/#@-/d" wp-config.php

        #run installer
        curl -d "weblog_title=$siteTitle&user_name=$adminUser&admin_password=$adminPass&admin_password2=$adminPass&admin_email=$adminEmail" http://$siteUrl/wp-admin/install.php?step=2

        #remove files
        rm ./latest.tar.gz
        rm ./wp.keys
}

while getopts ":hi:" option; do
                case $option in
                        h) # display Help
                                Help
                                exit;;
                        i) #run install
                                Install $2 "$3" $4 $5
                                exit;;
                        :) printf "missing argument for -%s\n" "$OPTARG" >&2
                                echo "$usage" >&2
                                exit 1;;
                        \?) # incorrect option
                                echo "Error: Invalid option"
                                exit 1;;
                esac
done
