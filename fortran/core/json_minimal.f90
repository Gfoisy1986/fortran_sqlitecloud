module json_minimal
    implicit none
contains

    function json_get_value(json, key) result(val)
        character(*), intent(in) :: json, key
        character(len=:), allocatable :: val
        integer :: p1, p2

        val = ""

        p1 = index(json, '"'//trim(key)//'":')
        if (p1 == 0) return

        p1 = index(json(p1:), ":") + p1
        p2 = index(json(p1:), ",")
        if (p2 == 0) p2 = index(json(p1:), "}")

        val = adjustl(json(p1+1:p1+p2-2))
    end function json_get_value

end module json_minimal
