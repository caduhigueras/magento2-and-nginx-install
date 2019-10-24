#items necessary for magento install
dbname=magento2 #database name to install magento 2
dbpass=yourdbpassword #user will be root
magentourl=http://m2.one #url will you put also on hosts file and use to access the website locally
magentourlnohttp=m2.one #necessary to setup etc/hosts on nginx
magentoadminname=admin #first name of magento admin - please use just one word
magentoadminlastname=admin #last name of magento admin - please use just one word
magentoadminpassword=youradminpassword #pwd to login on magento 2 and on the database
backendfrontname=admin #path to magento's backend example: http://yourmagento2.test/admin
adminemail=admin@admin.com #magento admin email
adminuser=admin #magento admin user - used to login on the backend
language=en_US #languages @Magento\Framework\Locale\Config.php: af_ZA, ar_DZ, ar_EG, ar_KW, ar_MA, ar_SA, az_Latn_AZ, be_BY, bg_BG, bn_BD, bs_Latn_BA, ca_ES, cs_CZ, cy_GB, da_DK, de_AT, de_CH, de_DE, el_GR, en_AU, en_CA, en_GB, en_NZ, en_US, es_AR, es_CO, es_PA, gl_ES, es_CR, es_ES, es_MX, eu_ES, es_PE, et_EE, fa_IR, fi_FI, fil_PH, fr_CA, fr_FR, gu_IN, he_IL, hi_IN, hr_HR, hu_HU, id_ID, is_IS, it_CH, it_IT, ja_JP, ka_GE, km_KH, ko_KR, lo_LA, lt_LT, lv_LV, mk_MK, mn_Cyrl_MN, ms_Latn_MY, nl_NL, nb_NO, nn_NO, pl_PL, pt_BR, pt_PT, ro_RO, ru_RU, sk_SK, sl_SI, sq_AL, sr_Cyrl_RS, sv_SE, sw_KE, th_TH, tr_TR, uk_UA, vi_VN, zh_Hans_CN, zh_Hant_HK, zh_Hant_TW, es_CL, lo_LA, es_VE, en_IE
currency=EUR #currency - USD, EUR, BRL etc
timezone=Europe/Madrid #timezones: Europe/Lisbon, Europe/London, Europe/Madrid, Europe/Paris, America/Chicago, America/Sao_Paulo

################################################
############ End of Initital setup  ############
################################################

# update
echo "################################"
echo "##### PREPARING FOR PHP7.2 #####"
echo "################################"
add-apt-repository -y ppa:ondrej/php


# update
echo ""
echo ""
echo "########################"
echo "##### UPDATING APT #####"
echo "########################"
sudo apt-get -y update

# Install Nginx
echo ""
echo ""
echo "#############################"
echo "##### INSTALLING Nginx #####"
echo "#############################"
sudo apt-get -y install nginx

# Install Mysql
echo ""
echo ""
echo "#############################"
echo "##### INSTALLING MySQL #####"
echo "#############################"
# Setting MySQL root user password root/root
debconf-set-selections <<< "mysql-server mysql-server/root_password password $dbpass"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $dbpass"

# Installing packages
apt-get install -y mysql-server mysql-workbench

# Install PHP
echo ""
echo ""
echo "###########################################"
echo "##### INSTALLING PHP and Dependencies #####"
echo "###########################################"
sudo sudo apt-get -y install php7.2-fpm php7.2-gd php7.2-mysql php7.2-curl php7.2-soap php7.2-xml php-xdebug
sudo apt-get -y install php-pear
sudo apt-get -y install php-oauth php7.2-intl php7.2-mbstring php7.2-zip openssl php7.2-bcmath
sudo apt-get -y install zip unzip
sudo apt install -y curl
sudo apt install -y git

# variables for mysql
echo ""
echo ""
echo "###########################################"
echo "##### CREATING DATABASE #####"
echo "###########################################"

mysql -u root -p$dbpass -e "CREATE DATABASE IF NOT EXISTS $dbname;"

## nginx conf file
echo ""
echo ""
echo "#########################################"
echo "##### NGINX CONF FILE #####"
echo "#########################################"

sudo cp ./m2files/magento2  /etc/nginx/sites-available/${magentourlnohttp}

sudo bash -c 'echo "127.0.0.1  ${magentourlnohttp}" >> /etc/hosts'

sudo rm /etc/nginx/sites-available/default
sudo rm /etc/nginx/sites-enabled/default

echo ""
echo ""
echo "#########################################"
echo "##### Creating Symlink #####"
echo "#########################################"

sudo ln -s /etc/nginx/sites-available/${magentourlnohttp} /etc/nginx/sites-enabled/

# Composer Installation
echo ""
echo ""
echo "###############################"
echo "##### INSTALLING COMPOSER #####"
echo "###############################"

curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

# Changing php.ini for magento 2
echo ""
echo ""
echo "#########################################"
echo "##### CHANGING PHP.INI FOR MAGENTO 2#####"
echo "#########################################"
sudo rm /etc/php/7.2/fpm/php.ini
sudo rm /etc/php/7.2/cli/php.ini
sudo cp ./m2files/php.ini /etc/php/7.2/fpm/
sudo cp ./m2files/php2.ini /etc/php/cli/php.ini
#sudo rm -rf php.ini
sudo service php7.2-fpm reload
sudo service php7.2-fpm restart

# auth.json
echo ""
echo ""
echo "################################################"
echo "##### PREPARING COMPOSER FOR MAGENTO2 KEYS #####"
echo "################################################"
sudo mkdir ~/.composer/
sudo cp ./m2files/auth.json  ~/.composer/

# Composer creating Magento 2 project
echo ""
echo ""
echo "##############################################"
echo "##### CREATING COMPOSER PROJECT MAGENTO2 #####"
echo "##############################################"
cd /var/www/html
composer create-project --repository=https://repo.magento.com/ magento/project-community-edition ${magentourlnohttp}

# PERMISSIONS Magento 2
echo ""
echo ""
echo "###########################################"
echo "##### SETTINP UP PERMISSIONS MAGENTO2 #####"
echo "###########################################"
cd /var/www/html/${magentourlnohttp}
sudo find var generated vendor pub/static pub/media app/etc -type f -exec chmod g+w {} +
sudo find var generated vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} +
sudo chown -R :www-data . # Ubuntu
#sudo chmod u+x bin/magento

# install Magento 2 project
echo ""
echo ""
echo "###############################"
echo "##### INSTALLING MAGENTO2 #####"
echo "###############################"
bin/magento setup:install --base-url=$magentourl --db-host=localhost --db-name=$dbname --db-user=root --db-password=$dbpass --backend-frontname=$backendfrontname --admin-firstname=$magentoadminname --admin-lastname=$magentoadminlastname --admin-email=$adminemail --admin-user=$adminuser --admin-password=$magentoadminpassword --language=$language --currency=$currency --timezone=$timezone --use-rewrites=1

# set developer
echo ""
echo ""
echo "#######################################"
echo "##### MAGENTO2 SET DEVELOPER MODE #####"
echo "#######################################"
bin/magento deploy:mode:set developer

# clean cache
echo ""
echo ""
echo "#######################################"
echo "##### MAGENTO2 CLEAN CACHE #####"
echo "#######################################"
bin/magento c:c

# reindex
echo ""
echo ""
echo "#######################################"
echo "##### MAGENTO2 REINDEX #####"
echo "#######################################"
bin/magento indexer:reindex

echo ""
echo ""
echo "#######################################"
echo "##### MAGENTO2 RUN DI COMPILE #####"
echo "#######################################"
# compile
bin/magento setup:di:compile

echo ""
echo ""
echo "#########################################"
echo "##### MAGENTO2 FORCE DEPLOY CONTENT #####"
echo "#########################################"
# compile
bin/magento setup:static-content:deploy -f

echo ""
echo ""
echo "###################################"
echo "##### Adding configure xdebug #####"
echo "###################################"
#sudo rm /etc/php/7.2/mods-available/xdebug.ini
#sudo cp ./xdebug.ini /etc/php/7.2/mods-available

echo ""
echo ""
echo "#########################################"
echo "##### restarting NGINX / PHP #####"
echo "#########################################"

sudo service nginx reload
sudo service nginx restart
sudo service php7.2-fpm reload
sudo service php7.2-fpm restart

echo ""
echo ""
echo "#######################################"
echo "##### installing / NODE JS Latest #####"
echo "#######################################"
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt-get -y install nodejs


echo ""
echo ""
echo "##################################"
echo "##### installing / PHP STORM #####"
echo "##################################"
sudo snap install phpstorm --classic

echo ""
echo ""
echo "####################################################################"
echo "##### installing GNOME TWEAK TOOL to enhance ubuntu workspaces #####"
echo "####################################################################"
sudo add-apt-repository universe
sudo apt -y install gnome-tweak-tool
gsettings set org.gnome.shell.extensions.dash-to-dock isolate-workspaces true


echo ""
echo ""
echo "############################################"
echo "##### You are all set! Don't forget to #####"
echo "############################################"
echo "#####################################################################"
echo "1. Check if ${magentourlnohttp} is added on your etc/hosts."
echo "2. Check if the ${magentourlnohttp} was created at /etc/nginx/sites-available and at /etc/nginx/sites-enabled"
echo "3. You can access your site at: ${magentourl}"
echo "4. You can access the backend at: ${magentourl}/${backendfrontname}"
echo "5. Important commands u may need: service nginx reload | service nginx restart | service php7.2-fpm reload | service php7.2-fpm restart"
echo "6. After you create a new project with PHP Storm, cd to: /var/www/html/${magentourlnohttp} and run: bin/magento dev:urn-catalog:generate .idea/misc.xml"
#echo "2. download xdebug helper with your favorite browser and set it to: $xdebugidename"
echo "7. Confirm that ${magentourlnohttp} is set at your /etc/nginx/sites-available/${magentourlnohttp} file and the paths on this file are /var/www/html/${magentourlnohttp}"
echo "8. Have fun!"
echo "######################################################################"
