module sqlitecloud_wrapper
    use net_http
    use json_minimal
    use utils
    implicit none

    character(len=:), allocatable :: base_url
    character(len=:), allocatable :: api_key

contains

    subroutine sc_init(url, key)
        character(*), intent(in) :: url, key
        base_url = trim(url)
        api_key  = trim(key)
    end subroutine sc_init

    function sc_query(sql) result(response)
        character(*), intent(in) :: sql
        character(len=:), allocatable :: response
        character(len=:), allocatable :: url
        character(len=:), allocatable :: raw

        url = base_url // "/v1/sql?apikey=" // api_key // "&q=" // sql

        raw = http_get(url)
        if (len_trim(raw) == 0) then
            response = "ERROR: HTTP request failed"
            return
        end if

        response = raw
    end function sc_query

    function sc_query_value(sql, field) result(val)
        character(*), intent(in) :: sql, field
        character(len=:), allocatable :: val
        character(len=:), allocatable :: raw

        raw = sc_query(sql)
        val = json_get_value(raw, field)
    end function sc_query_value

end module sqlitecloud_wrapper
