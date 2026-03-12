program test_download
    use net_http
    implicit none

    character(len=:), allocatable :: data

    print *, "Téléchargement d'un fichier test..."
    data = http_get("https://example.com")

    if (len_trim(data) > 0) then
        print *, "OK: ", len_trim(data), " octets"
    else
        print *, "Échec du téléchargement"
    end if

end program test_download
