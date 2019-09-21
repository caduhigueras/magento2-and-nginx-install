# magento2-and-nginx-install

<p><strong>1. First go to /m2files/magento2 and change the paths to the name of the site that you will use.</strong></p>
<p>Exs:<br>
server_name <strong>mysitemagento2.test</strong>;<br>
set $MAGE_ROOT /var/www/html/<strong>mysitemagento2.test</strong>;<br>
include /var/www/html/<strong>mysitemagento2.test</strong>/nginx.conf.sample;</p>

<p><strong>2. Go to the bootstrap.sh and define the setup infos as you want:</strong><br>
(just remember to use for magentourl and magentourlnohttp the same name you chose on step 1)<br>
dbname=magento2 <br>
dbpass=bnm196922<br>
magentourl=http://<strong>mysitemagento2.test</strong><br>
magentourlnohttp=<strong>mysitemagento2.test</strong> <br>
magentoadminname=admin <br>
magentoadminlastname=admin <br>
magentoadminpassword=yourpassword<br>
backendfrontname=admin <br>
adminemail=admin@admin.com <br>
adminuser=admin<br>
language=en_US <br>
currency=EUR #currency - USD, EUR, BRL etc<br>
timezone=Europe/Madrid<br>
################################################<br>
############ End of Initital setup  ############<br>
################################################<br>
</p>

<p><strong>3. Go to /m2files/auth.json and add your magento keys.</strong><br>
If you don't have it, there is a tutorial on how to get it <a href="https://devdocs.magento.com/guides/v2.3/install-gde/prereq/connect-auth.html">here</a>. 
</p>

<p><strong>4. Make the bootstrap.sh writeable:</strong><br>
sudo chmod 777 bootstrap.sh</p>

<p><strong>5. Run the bootstrap.sh:</strong><br>
./bootstrap.sh
</p>
