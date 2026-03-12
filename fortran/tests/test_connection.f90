program test_connection
    use sqlitecloud_wrapper
    implicit none

    call sc_init("https://cc8ixq0fdz.g2.sqlite.cloud", "apikey=uHobQuLxBLUsBsuLjJRMz4uartdbJDPF40A49i4IvFs")

    print *, "Test connexion..."
    print *, sc_query("SELECT 1;")

end program test_connection
