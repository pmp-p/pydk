# bpo-30386 patched for api19, running as root from bash under h3droid 1.3.2
```
323 tests OK.

3 tests failed:
    test_asyncio test_unicode test_warnings

16 tests skipped:
    test_asdl_parser test_startfile test_timeout test_tix test_tk
    test_ttk_guionly test_ttk_textonly test_turtle test_urllib2net
    test_urllibnet test_wait3 test_winconsoleio test_winreg
    test_winsound test_xmlrpc_net test_zipfile64

Total duration: 46 min 29 sec
```

# hacked linker, compiled on debian jessie armhf from master, running as root from bash under h3droid 1.3.2 

Python 3.7.0a4+ (default, Jan 24 2018, 17:24:13) 
[GCC 4.9.2] on linux

```
338 tests OK.

30 tests failed:
    test_asyncore test_ctypes test_distutils test_docxmlrpc test_eintr
    test_ftplib test_gdb test_getpass test_grp test_imaplib
    test_nntplib test_os test_pathlib test_poplib test_posix
    test_posixpath test_pwd test_robotparser test_shutil test_smtpd
    test_smtplib test_socket test_ssl test_support test_tarfile
    test_telnetlib test_urllib test_urllib2 test_urllib2_localnet
    test_wsgiref

37 tests skipped:
    test_asdl_parser test_bz2 test_concurrent_futures test_crypt
    test_curses test_dbm_gnu test_dbm_ndbm test_devpoll test_idle
    test_kqueue test_lzma test_msilib test_multiprocessing_fork
    test_multiprocessing_forkserver test_multiprocessing_main_handling
    test_multiprocessing_spawn test_nis test_ossaudiodev test_readline
    test_smtpnet test_socketserver test_sqlite test_startfile test_tcl
    test_timeout test_tix test_tk test_ttk_guionly test_ttk_textonly
    test_turtle test_urllib2net test_urllibnet test_winconsoleio
    test_winreg test_winsound test_xmlrpc_net test_zipfile64

Total duration: 54 min 21 sec
```

ARCHIVES : 
# bpo-30386 patched for api19, running as root from bash under h3droid 1.3.2

```
317 tests OK.

9 tests failed:
    test_asyncio test_strftime test_unicode test_venv test_warnings
    test_xmlrpc test_xmlrpc_net test_zipfile test_zlib

15 tests skipped:
    test_asdl_parser test_startfile test_timeout test_tix test_tk
    test_ttk_guionly test_ttk_textonly test_turtle test_urllib2net
    test_urllibnet test_wait3 test_winconsoleio test_winreg
    test_winsound test_zipfile64

Total duration: 50 min 59 sec
```
