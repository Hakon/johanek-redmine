# Class redmine::download
class redmine::download {

    # Install dependencies

    $generic_packages = [ 'wget', 'tar', 'make', 'gcc' ]
    $debian_packages  = [ 'libmysql++-dev', 'libmysqlclient-dev', 'libmagickcore-dev', 'libmagickwand-dev', 'ruby-dev' ]
    $default_packages = ['postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', 'mysql-devel' ]

    case $::osfamily {
        'Debian':   { $packages = concat($generic_packages, $debian_packages) }
        'RedHat':   {
            case $::operatingsystem {
                'Fedora': {
                    if is_integer($::operatingsystemrelease) and $::operatingsystemrelease >= 19 or $::operatingsystemrelease == 'Rawhide' {
                        $provider = 'mariadb-devel'
                    } else {
                        $provider = 'mysql-devel'
                    }
                }
                /^(RedHat|CentOS|Scientific)$/: {
                    if $::operatingsystemmajrelease >= 7 {
                        $provider = 'mariadb-devel'
                    } else {
                        $provider = 'mysql-devel'
                    }
                }
                default: {
                    $provider = 'mysql-devel'
                }
            }
            $redhat_packages = ['postgresql-devel', 'sqlite-devel', 'ImageMagick-devel', 'ruby-devel', $provider ]
            $packages = concat($generic_packages, $redhat_packages)
        }
        default:    { $packages = concat($generic_packages, $default_packages) }
    }

    ensure_packages($packages)

    # Install redmine from source

    Exec {
        cwd  => '/usr/src',
        path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/', '/usr/local/bin/' ]
    }

    if $redmine::provider != 'wget' {
        vcsrepo { 'redmine_source':
            revision => "${redmine::version}",
            source   => "${redmine::download_url}",
            provider => "${redmine::provider}",
            path     => "/usr/src/redmine-${redmine::version}"
        }
    }
    else {
        exec { 'redmine_source':
            command => "wget ${redmine::download_url}",
            creates => "/usr/src/redmine-${redmine::version}.tar.gz",
            require => Package['wget'],
        } ->
        exec { 'extract_redmine':
            command => "tar xvzf redmine-${redmine::version}.tar.gz",
            creates => "/usr/src/redmine-${redmine::version}",
            require => Package['tar'],
        }
    }
}
