# Backup-script-S3
Easy and scalable solution for mysql database backup to AWS S3 bucket.
We have been working with a client who has a website based on SocialEngine with fairly heavy user traffic and lots of data. As a popular website and data changing on daily basis, we have to take data backup every day just in case something happens and we need to restore it. Storing the backup on a local server needs more space which is a costlier approach in terms of hardware. So we were exploring the other options to store the data securely, efficiently and in relatively cheaper.

We researched and found that Amazon S3 option is the best for our requirements.  The costing for S3 is much cheaper than storing in the SSD hard drive and won't require any maintenance. We didn't find any third party plugin who can handle our requirements to take the backup of our website. There were few backup plugins but failed to take backup properly.

Amazon S3 saves the data as secure object storage. It lets you preserve, retrieve and restore every version of every object in an Amazon S3 bucket. So, you can easily recover if something is accidentally deleted by users or applications failure. With Amazon S3 you only pay for the storage you actually use. There is no minimum fee and no setup cost. So we decided to use this option to store data for the website.

The best thing about using s3 is that AWS provides S3 utility which can take care of storing the data in the relevant bucket. You just need to run the command in the shell script and data is stored in S3 bucket without any hassle. So we are sharing the script on Github so that you can directly use it for your SocialEngine website.

&nbsp;
<h2>Steps to take back up of website based on SocialEngine</h2>
We are going to go through the steps in details to take the backup of the database. If you would like then you can skip the next steps and directly download the script for your website though we would like you to read the full article.

Here is the checklist for your server:
<ul>
 	<li style="font-weight: 400;"><b>S3cmd  command line configures on the server.</b></li>
 	<li style="font-weight: 400;"><b>A bucket over S3 to store dump file (<a href="https://docs.aws.amazon.com/quickstarts/latest/s3backup/step-1-create-bucket.html">click to create S3 bucket</a>).</b></li>
 	<li><b>Make Bash Script i.e Contains MySQL Credential ( Hostname, Username, Password, DBName ), Location on your server where you want to store dump (PATH), Log Path.</b></li>
 	<li><b>Give chmod +x on mysql backup Script (mysql_script.sh).</b></li>
 	<li><b>Test it and check S3 bucket</b></li>
 	<li><b><b><b><b>Schedule backup MySQL database with crontab as per your requirement.</b></b></b></b></li>
</ul>
&nbsp;

<img class="size-full wp-image-23169 aligncenter" src="http://www.ipragmatech.com/wp-content/uploads/2018/09/Steemit-Socialengine-Wordpress-Integration-Infographic-3.png" alt="MySQL Database Backup" width="600" height="1500" />
<h2><em><strong>Step 1. Install S3cmd:</strong></em></h2>
<span style="font-weight: 400;" title="backup mysql database">Download the latest version of the s3cmd using this link '</span><a href="https://sourceforge.net/projects/s3tools/?source=typ_redirect"><span style="font-weight: 400;">https://sourceforge.net/projects/s3tools/?source=typ_redirect</span></a><span style="font-weight: 400;">'</span>
<pre style="background: #f2f2f2; overflow-x: scroll; padding: 10px;"><span style="font-weight: 400;">sudo apt-get -y install python-setuptools</span>
<span style="font-weight: 400;">wget http://netix.dl.sourceforge.net/project/s3tools/s3cmd/1.6.0/s3cmd-1.6.0.tar.gz</span>
<span style="font-weight: 400;">tar xvfz s3cmd-1.6.0.tar.gz</span>
<span style="font-weight: 400;">cd s3cmd-1.6.0</span>
<span style="font-weight: 400;">sudo python setup.py install</span>
</pre>


<span style="font-weight: 400;">In which You will be asked for the two keys (Access key and Secret key are your identifiers for Amazon S3.) – copy and paste them from your confirmation email or from your Amazon account page.</span>

<span style="font-weight: 400;">They are case sensitive and must be entered accurately or you’ll keep getting errors about invalid signatures or similar.</span>

<span style="font-weight: 400;">You can optionally enter a GPG encryption key that will be used for encrypting your files before sending them to Amazon. Using GPG encryption will protect your data against reading by Amazon staff or anyone who may get access to your them while they’re stored at Amazon S3.</span>

<span style="font-weight: 400;">Other advanced settings can be changed (if needed) by editing the config file manually. Some of the settings contain the default values for s3cmd to use.</span>

<span style="font-weight: 400;">The following is an example of an s3cmd config file: (.s3cfg).</span>
<pre style="background: #f2f2f2; overflow-x: scroll; padding: 10px;"><span style="font-weight: 400;">[default]</span>

<span style="font-weight: 400;">access_key = &lt;your key&gt;</span>
<span style="font-weight: 400;">access_token = </span>
<span style="font-weight: 400;">add_encoding_exts = </span>
<span style="font-weight: 400;">add_headers = </span>
<span style="font-weight: 400;">bucket_location = Mumbai </span>
<span style="font-weight: 400;">ca_certs_file = </span>
<span style="font-weight: 400;">cache_file = </span>
<span style="font-weight: 400;">check_ssl_certificate = True</span>
<span style="font-weight: 400;">check_ssl_hostname = True</span>
<span style="font-weight: 400;">cloudfront_host = cloudfront.amazonaws.com</span>
<span style="font-weight: 400;">default_mime_type = binary/octet-stream</span>
<span style="font-weight: 400;">delay_updates = False</span>
<span style="font-weight: 400;">delete_after = False</span>
<span style="font-weight: 400;">delete_after_fetch = False</span>
<span style="font-weight: 400;">delete_removed = False</span>
<span style="font-weight: 400;">dry_run = False</span>
<span style="font-weight: 400;">enable_multipart = True</span>
<span style="font-weight: 400;">encoding = UTF-8</span>
<span style="font-weight: 400;">encrypt = False</span>
<span style="font-weight: 400;">expiry_date = </span>
<span style="font-weight: 400;">expiry_days = </span>
<span style="font-weight: 400;">expiry_prefix = </span>
<span style="font-weight: 400;">follow_symlinks = False</span>
<span style="font-weight: 400;">force = False</span>
<span style="font-weight: 400;">get_continue = False</span>
<span style="font-weight: 400;">gpg_command = /usr/bin/gpg</span>
<span style="font-weight: 400;">gpg_decrypt = %(gpg_command)s -d --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s</span>
<span style="font-weight: 400;">gpg_encrypt = %(gpg_command)s -c --verbose --no-use-agent --batch --yes --passphrase-fd %(passphrase_fd)s -o %(output_file)s %(input_file)s</span>
<span style="font-weight: 400;">gpg_passphrase = </span>
<span style="font-weight: 400;">guess_mime_type = True</span>
<span style="font-weight: 400;">host_base = s3.amazonaws.com</span>
<span style="font-weight: 400;">host_bucket = %(bucket)s.s3.amazonaws.com</span>
<span style="font-weight: 400;">human_readable_sizes = False</span>
<span style="font-weight: 400;">etc.............
</span>
</pre>

<h2><em><strong>Step 2. MySql Database Backup Script S3:</strong></em></h2>
The shell script used to back up your database and upload it to S3.

The idea is to create the following script and run it with the appropriate environment variables, and what it does is actually pretty simple, and then uses <a href="https://dev.mysql.com/doc/refman/5.1/en/mysqldump.html"><b>mysqldump</b></a> to dump the database to a temporary file, and It uploads the file to S3 by using the <a href="http://docs.aws.amazon.com/cli/latest/reference/s3/index.html">AWS CLI Tools for S3</a>.
<pre style="background: #f2f2f2; overflow-x: scroll; padding: 10px;"><span style="font-weight: 400;">#Save dbbacku.sh 

#!/bin/bash</span>
<span style="font-weight: 400;">## Specify the name of the database that you want to backup</span>

<span style="font-weight: 400;"># Database credentials</span>
USER="DB-USER"
<span style="font-weight: 400;">PASSWORD="PASSWORD"</span>
<span style="font-weight: 400;">HOST="DB-host-name"</span>
<span style="font-weight: 400;">DB_NAME="Database-name"</span>

<span style="font-weight: 400;">#Backup_Directory_Locations</span>
<span style="font-weight: 400;">BACKUPROOT="/tmp/backups"</span>
<span style="font-weight: 400;">TSTAMP=$(date +"%d-%b-%Y-%H-%M-%S")</span>
<span style="font-weight: 400;">S3BUCKET="s3://s3bucket"</span>
<span style="font-weight: 400;">#LOG_ROOT="logs/dump.log"
</span>
<span style="font-weight: 400;">#</span><span style="font-weight: 400;">mysqldump</span><span style="font-weight: 400;">  -h </span><span style="font-weight: 400;">&lt;HOST&gt;</span><span style="font-weight: 400;">  -u </span><span style="font-weight: 400;">&lt;USER&gt;</span><span style="font-weight: 400;">  </span><span style="font-weight: 400;">--database</span><span style="font-weight: 400;"> &lt;DB_NAME&gt;</span><span style="font-weight: 400;">  -p"</span><span style="font-weight: 400;">password</span><span style="font-weight: 400;">" &gt; </span><span style="font-weight: 400;">$BACKUPROOT</span><span style="font-weight: 400;">/</span><span style="font-weight: 400;">$DB_NAME</span><span style="font-weight: 400;">-</span><span style="font-weight: 400;">$TSTAMP.sql</span>

<span style="font-weight: 400;">#or</span>

<span style="font-weight: 400;">mysqldump -h$HOST -u$USER $DB_NAME -p$PASSWORD | gzip -9 &gt; $BACKUPROOT/$DB_NAME-$TSTAMP.sql.gz</span>

<span style="font-weight: 400;">if [ $? -ne 0 ]</span>
<span style="font-weight: 400;"> then</span>
<span style="font-weight: 400;"> mkdir /tmp/$TSTAMP</span>
<span style="font-weight: 400;"> s3cmd put -r /tmp/$TSTAMP $S3BUCKET/</span>
<span style="font-weight: 400;"> s3cmd sync -r $BACKUPROOT/ $S3BUCKET/$TSTAMP/</span>
<span style="font-weight: 400;"> rm -rf $BACKUPROOT/*</span>
<span style="font-weight: 400;">else</span>
<span style="font-weight: 400;"> s3cmd sync -r $BACKUPROOT/ $S3BUCKET/$TSTAMP/</span>
<span style="font-weight: 400;"> rm -rf $BACKUPROOT/*</span>
<span style="font-weight: 400;">fi

</span></pre>
<h2><em><strong>Step 3.  Let's run the script now:</strong></em></h2>
Make can be called in various ways. For example:
<pre style="background: #f2f2f2; overflow-x: scroll; padding: 10px;"><span style="font-weight: 400;">
# chmod +x dbbackup.sh</span>
<span style="font-weight: 400;"># Run the script to make sure it's all good</span>
<span style="font-weight: 400;"># bash dbbackup.sh
</span>
</pre>
<h3>Backup script Output:-</h3>
&nbsp;

<img class="alignnone wp-image-22477" src="http://www.ipragmatech.com/wp-content/uploads/2018/05/Screen-Shot-2018-05-31-at-11.49.52-AM-300x181.png" alt="" width="872" height="526" />

<h2><em><strong>Step 4. Schedule IT With CRONTAB:</strong></em></h2>
<span style="font-weight: 400;">Assuming the backup script is stored in /opt/scripts  directory we need to add a crontab task to run it automatically on weekly basis:</span>
<pre style="background: #f2f2f2; overflow-x: scroll; padding: 10px;"><span style="font-weight: 400;"> So we have to edit the crontab  file </span>

<span style="font-weight: 400;"> #vim /etc/crontab</span>
<span style="font-weight: 400;"> #Add the following lines:</span>
<span style="font-weight: 400;"> #Run the database backup script on every week at 12.00
</span>
<span style="font-weight: 400;"> 0 0 * * 0  bash /opt/scripts/mysqlbackupS3.sh to  &gt;/dev/null 2&gt;&amp;1

</span>
</pre>
&nbsp;
<h2>Conclusion</h2>
In this article, we have explained how to automate the backup process  MySQL directly on AWS S3 Bucket.  Just schedule and configure the script on you MySql server and you are done. This service runs the process on regular basis according to your pre-configured schedule. Feel free to ask any query, glad to hear from you.
<h2>References</h2>
<ul>
 	<li><a href="https://docs.aws.amazon.com/quickstarts/latest/s3backup/step-1-create-bucket.html" target="_blank" rel="noopener">Amazon S3 Bucket</a></li>
 	<li><a href="https://sourceforge.net/projects/s3tools/?source=typ_redirect" target="_blank" rel="noopener">S3cmd</a></li>
 	<li><a href="https://dev.mysql.com/doc/refman/5.7/en/mysqldump.html" target="_blank" rel="noopener">Mysql dump</a></li>
 	<li><a href="https://www.socialengine.com/" target="_blank" rel="noopener">SocialEngine</a></li>
</ul>
<h2>For further reading</h2>
<ul>
 	<li class="title"><a href="https://dev.mysql.com/doc/refman/5.7/en/mysqldump-sql-format.html" target="_blank" rel="noopener">Dumping Data in SQL Format with mysqldump</a></li>
 	<li id="UsingBucket" class="topictitle"><a href="https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html">Working with Amazon S3 Buckets</a></li>
</ul>
