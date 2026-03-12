module utils
    implicit none
contains

    subroutine die(msg)
        character(*), intent(in) :: msg
        print *, "[FATAL] ", trim(msg)
        stop 1
    end subroutine die

    function trim_nl(s) result(out)
        character(*), intent(in) :: s
        character(len(s)) :: out
        out = adjustl(s)
    end function trim_nl

end module utils
