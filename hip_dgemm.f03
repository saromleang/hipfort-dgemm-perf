program hip_dgemm

  use iso_c_binding
  use, intrinsic :: ISO_FORTRAN_ENV, only: error_unit, output_unit
  use hipfort
  use hipfort_check
  use hipfort_hipblas
  use ftime

  implicit none

  integer, parameter :: arg_count = 6
  character(len=32) :: arg
  integer :: argc

  integer(kind(HIPBLAS_OP_N)) :: transa, transb
  double precision, parameter ::  alpha = 1.0d0, beta = 0.0d0;

  integer :: reps
  integer :: m, n, k;
  integer :: lda, ldb, ldc, size_a, size_b, size_c;

  double precision, allocatable, target, dimension(:) :: ha, hb, hc

  type(c_ptr) :: da = c_null_ptr, db = c_null_ptr, dc = c_null_ptr
  type(c_ptr) :: handle = c_null_ptr

  integer, parameter :: bytes_per_element = 8 !double precision
  integer(c_size_t) :: Nabytes, Nbbytes, Ncbytes

  integer :: i
  double precision :: dgemm_time
  double precision :: gflops

  call ftime_init()

  call hipblasCheck(hipblasCreate(handle))

  argc = command_argument_count()
  if (argc /= arg_count) then
    write (error_unit, *) "Need 6 arguments: m k n reps [T|N] [T|N]"
    error stop
  end if
  
  call get_command_argument(1, arg)
  read(arg, *) m
  call get_command_argument(2, arg)
  read(arg, *) k
  call get_command_argument(3, arg)
  read(arg, *) n
  call get_command_argument(4, arg)
  read(arg, *) reps

  call get_command_argument(5, arg)
  if (arg(1:1) == "T") then
    transa = HIPBLAS_OP_T
  else
    transa = HIPBLAS_OP_N
  end if

  call get_command_argument(6, arg)
  if (arg(1:1) == "T") then
    transb = HIPBLAS_OP_T
  else
    transb = HIPBLAS_OP_N
  end if

  if (transa == HIPBLAS_OP_N) then
     lda = m
  else
     lda = k
  end if
  size_a = m * k;
  Nabytes = size_a*bytes_per_element

  if (transb == HIPBLAS_OP_N) then
     ldb = k
  else
     ldb = n
  end if
  size_b = n * k;
  Nbbytes = size_b*bytes_per_element

  ldc = m;
  size_c = m * n;
  Ncbytes = size_c*bytes_per_element

  allocate(ha(size_a))
  allocate(hb(size_b))
  allocate(hc(size_c))

  do i=1, m*k
    ha(i)=dble(i)
  end do  

  do i=1, k*n
    hb(i)=dble(i)
  end do  

  call hipCheck(hipMalloc(da,Nabytes))
  call hipCheck(hipMalloc(db,Nbbytes))
  call hipCheck(hipMalloc(dc,Ncbytes))

  call hipCheck(hipMemcpy(da, c_loc(ha(1)), Nabytes, hipMemcpyHostToDevice))
  call hipCheck(hipMemcpy(db, c_loc(hb(1)), Nbbytes, hipMemcpyHostToDevice))
  call hipCheck(hipMemcpy(dc, c_loc(hc(1)), Ncbytes, hipMemcpyHostToDevice))

  call hipblasCheck(hipblasDgemm(handle,transa,transb,m,n,k,alpha,da,lda,db,ldb,beta,dc,ldc))

  call hipCheck(hipDeviceSynchronize())

  write(*,*) "Performing",reps,"repetitions of",m,"*",k,"by",k,"*",n

  call ftime_start('dgemm')

  do i=1, reps
     call hipblasCheck(hipblasDgemm(handle,transa,transb,m,n,k,alpha,da,lda,db,ldb,beta,dc,ldc))
  end do

  call hipCheck(hipDeviceSynchronize())

  call ftime_stop('dgemm')
  dgemm_time = ftime_time('dgemm')

  gflops = dble(2)*dble(m)*dble(k)*dble(n)*dble(reps)/1.0d9/dble(dgemm_time)

  write(*,'(A7,A,F15.3)') "Time(s)",":",dgemm_time
  write(*,'(A7,A,F15.3)') "GFLOP/s",":",gflops

  call hipCheck(hipFree(da))
  call hipCheck(hipFree(db))
  call hipCheck(hipFree(dc))

  call hipblasCheck(hipblasDestroy(handle))

  deallocate(ha)
  deallocate(hb)
  deallocate(hc)

  call ftime_cleanup()

end program hip_dgemm
