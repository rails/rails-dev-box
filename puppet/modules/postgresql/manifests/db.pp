define postgresql::db (
    $password,
    $owner = $name,
    $encoding = 'UTF8',
    $locale = 'en_US.UTF-8',
) {

    pg_user {$owner:
        ensure      => present,
        password    => $password,
    }

    pg_database {$name:
        ensure      => present,
        owner       => $owner,
        require     => Pg_user[$owner],
        encoding    => $encoding,
        locale      => $locale,
    }
}
