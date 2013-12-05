# Class redmine::config
class redmine::config {

  require 'apache'

  File {
    owner => $redmine::params::apache_user,
    group => $redmine::params::apache_group,
    mode  => '0644'
  }

  file { '/var/www/html/redmine':
    ensure => link,
    target => "/usr/src/redmine-${redmine::version}"
  }

  Exec {
    cmd => "/bin/chown -R ${redmine::params::apache_user}.${redmine::params::apache_group} /usr/src/redmine-${redmine::version}"
  }

  file { '/var/www/html/redmine/config/database.yml':
    ensure  => present,
    content => template('redmine/database.yml.erb'),
    require => File['/var/www/html/redmine']
  }

  file { '/var/www/html/redmine/config/configuration.yml':
    ensure  => present,
    content => template('redmine/configuration.yml.erb'),
    require => File['/var/www/html/redmine']
  }

  apache::vhost { 'redmine':
    port          => '80',
    docroot       => '/var/www/html/redmine/public',
    servername    => $::fqdn,
    serveraliases => $redmine::vhost_aliases,
    options       => 'Indexes FollowSymlinks ExecCGI'
  }

  # Log rotation
  file { '/etc/logrotate.d/redmine':
    ensure => present,
    source => 'puppet:///modules/redmine/redmine-logrotate',
    owner  => 'root',
    group  => 'root'
  }

}