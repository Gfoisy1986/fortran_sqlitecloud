module net_http
    use iso_c_binding
    implicit none

    character(len=:), allocatable :: http_buffer

    interface
        function curl_easy_init() bind(c)
            import :: c_ptr
            type(c_ptr) :: curl_easy_init
        end function

        function curl_easy_perform(curl) bind(c)
            import :: c_ptr, c_int
            type(c_ptr), value :: curl
            integer(c_int) :: curl_easy_perform
        end function

        subroutine curl_easy_cleanup(curl) bind(c)
            import :: c_ptr
            type(c_ptr), value :: curl
        end subroutine

        function curl_easy_setopt_ptr(curl, option, value) bind(c, name="curl_easy_setopt")
            import :: c_ptr, c_int
            type(c_ptr), value :: curl
            integer(c_int), value :: option
            type(c_ptr), value :: value
            integer(c_int) :: curl_easy_setopt_ptr
        end function

        function curl_easy_setopt_str(curl, option, value) bind(c, name="curl_easy_setopt")
            import :: c_ptr, c_int, c_char
            type(c_ptr), value :: curl
            integer(c_int), value :: option
            character(kind=c_char), dimension(*) :: value
            integer(c_int) :: curl_easy_setopt_str
        end function

        function curl_easy_setopt_fun(curl, option, func) bind(c, name="curl_easy_setopt")
            import :: c_ptr, c_int
            type(c_ptr), value :: curl
            integer(c_int), value :: option
            type(c_ptr), value :: func
            integer(c_int) :: curl_easy_setopt_fun
        end function
    end interface

contains

    function write_callback(ptr, size, nmemb, userdata) bind(c)
        use iso_c_binding
        implicit none
        type(c_ptr), value :: ptr, userdata
        integer(c_size_t), value :: size, nmemb
        integer(c_size_t) :: write_callback

        integer :: n, i
        character(len=1, kind=c_char), pointer :: cbuf(:)
        character(len=:), allocatable :: chunk

        n = size * nmemb
        call c_f_pointer(ptr, cbuf, [n])

        allocate(character(len=n) :: chunk)
        do i = 1, n
            chunk(i:i) = cbuf(i)
        end do

        if (.not. allocated(http_buffer)) then
            http_buffer = chunk
        else
            http_buffer = http_buffer // chunk
        end if

        write_callback = n
    end function write_callback

    function http_get(url) result(body)
        character(*), intent(in) :: url
        character(len=:), allocatable :: body

        type(c_ptr) :: curl
        integer :: rc

        http_buffer = ""

        curl = curl_easy_init()
        if (.not. c_associated(curl)) then
            body = ""
            return
        end if

        rc = curl_easy_setopt_str(curl, 10002, trim(url)//c_null_char)
        rc = curl_easy_setopt_fun(curl, 20011, c_funloc(write_callback))

        rc = curl_easy_perform(curl)
        call curl_easy_cleanup(curl)

        if (rc /= 0) then
            body = ""
        else
            body = http_buffer
        end if
    end function http_get

end module net_http
