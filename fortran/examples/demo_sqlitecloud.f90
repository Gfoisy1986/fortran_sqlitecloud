program demo_sqlitecloud
    use sqlitecloud_wrapper
    implicit none

    call sc_init("https://mycluster.sqlitecloud.io", "apikey123")

    print *, "Version SQLiteCloud:"
    print *, sc_query_value("SELECT sqlite_version();", "result")

end program demo_sqlitecloud
