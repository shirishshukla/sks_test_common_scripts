#

define lfg_wh_common_scripts::gitpull( $scriptdir = $title ) {

   $giturl = 'https://github.com/puppetlabs/puppetlabs-apache.git'
   $gitdir = 'files'

  if ($::kernel == 'windows') {
     $dirsep = '\\'
     Exec { path => [ 'D:\Windows\system32', 'D:\Program Files\Git\cmd' ] }
  }
  else {
     $dirsep = '/'
     Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }
  }


  # git init
  exec {"git init ${scriptdir}":
    command  => 'git init',
    cwd      => $scriptdir,
    creates  => "${scriptdir}${dirsep}.git"
  }


  # remote remote add
  exec {"git remote add ${scriptdir}":
    command     => "git remote add origin -f ${giturl}",
    cwd         => $scriptdir,
    refreshonly => true,
    subscribe   => Exec["git init ${scriptdir}"],
  }


  # git config
  exec {'git enable core.sparsecheckout':
    command   => 'git config core.sparsecheckout true',
    cwd       => $scriptdir,
    refreshonly => true,
    subscribe => Exec["git init ${scriptdir}"],
  }


  # Create sparse-checkout and Add gitdir entry in that
  $sparseFile = "${scriptdir}${dirsep}.git${dirsep}info${dirsep}sparse-checkout"

  file { "${sparseFile}":
    ensure   => file,
    mode     => '0644',
    content  => "${gitdir}/*",
    require  => [
                 Exec['git enable core.sparsecheckout'],
                 Exec["git remote add ${scriptdir}"]
                ]
  }


  # Git pull
  exec {'git pull':
    command => 'git pull origin master',
    cwd     => $scriptdir,
    require => File["${sparseFile}"]
  }

}
## END ## 
