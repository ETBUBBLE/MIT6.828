
obj/user/testfile.debug：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 f7 05 00 00       	call   800628 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 60 80 00       	push   $0x806000
  800042:	e8 1e 0d 00 00       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 64 80 00    	mov    %ebx,0x806400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 fc 13 00 00       	call   801455 <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 60 80 00       	push   $0x806000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 99 13 00 00       	call   801401 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 1f 13 00 00       	call   801398 <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	55                   	push   %ebp
  80007f:	89 e5                	mov    %esp,%ebp
  800081:	57                   	push   %edi
  800082:	56                   	push   %esi
  800083:	53                   	push   %ebx
  800084:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008a:	ba 00 00 00 00       	mov    $0x0,%edx
  80008f:	b8 c0 28 80 00       	mov    $0x8028c0,%eax
  800094:	e8 9a ff ff ff       	call   800033 <xopen>
  800099:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80009c:	74 1b                	je     8000b9 <umain+0x3b>
  80009e:	89 c2                	mov    %eax,%edx
  8000a0:	c1 ea 1f             	shr    $0x1f,%edx
  8000a3:	84 d2                	test   %dl,%dl
  8000a5:	74 12                	je     8000b9 <umain+0x3b>
		panic("serve_open /not-found: %e", r);
  8000a7:	50                   	push   %eax
  8000a8:	68 cb 28 80 00       	push   $0x8028cb
  8000ad:	6a 20                	push   $0x20
  8000af:	68 e5 28 80 00       	push   $0x8028e5
  8000b4:	e8 cf 05 00 00       	call   800688 <_panic>
	else if (r >= 0)
  8000b9:	85 c0                	test   %eax,%eax
  8000bb:	78 14                	js     8000d1 <umain+0x53>
		panic("serve_open /not-found succeeded!");
  8000bd:	83 ec 04             	sub    $0x4,%esp
  8000c0:	68 80 2a 80 00       	push   $0x802a80
  8000c5:	6a 22                	push   $0x22
  8000c7:	68 e5 28 80 00       	push   $0x8028e5
  8000cc:	e8 b7 05 00 00       	call   800688 <_panic>

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d6:	b8 f5 28 80 00       	mov    $0x8028f5,%eax
  8000db:	e8 53 ff ff ff       	call   800033 <xopen>
  8000e0:	85 c0                	test   %eax,%eax
  8000e2:	79 12                	jns    8000f6 <umain+0x78>
		panic("serve_open /newmotd: %e", r);
  8000e4:	50                   	push   %eax
  8000e5:	68 fe 28 80 00       	push   $0x8028fe
  8000ea:	6a 25                	push   $0x25
  8000ec:	68 e5 28 80 00       	push   $0x8028e5
  8000f1:	e8 92 05 00 00       	call   800688 <_panic>
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000f6:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000fd:	75 12                	jne    800111 <umain+0x93>
  8000ff:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  800106:	75 09                	jne    800111 <umain+0x93>
  800108:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  80010f:	74 14                	je     800125 <umain+0xa7>
		panic("serve_open did not fill struct Fd correctly\n");
  800111:	83 ec 04             	sub    $0x4,%esp
  800114:	68 a4 2a 80 00       	push   $0x802aa4
  800119:	6a 27                	push   $0x27
  80011b:	68 e5 28 80 00       	push   $0x8028e5
  800120:	e8 63 05 00 00       	call   800688 <_panic>
	cprintf("serve_open is good\n");
  800125:	83 ec 0c             	sub    $0xc,%esp
  800128:	68 16 29 80 00       	push   $0x802916
  80012d:	e8 2f 06 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  800132:	83 c4 08             	add    $0x8,%esp
  800135:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  80013b:	50                   	push   %eax
  80013c:	68 00 c0 cc cc       	push   $0xccccc000
  800141:	ff 15 1c 40 80 00    	call   *0x80401c
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	85 c0                	test   %eax,%eax
  80014c:	79 12                	jns    800160 <umain+0xe2>
		panic("file_stat: %e", r);
  80014e:	50                   	push   %eax
  80014f:	68 2a 29 80 00       	push   $0x80292a
  800154:	6a 2b                	push   $0x2b
  800156:	68 e5 28 80 00       	push   $0x8028e5
  80015b:	e8 28 05 00 00       	call   800688 <_panic>
	if (strlen(msg) != st.st_size)
  800160:	83 ec 0c             	sub    $0xc,%esp
  800163:	ff 35 00 40 80 00    	pushl  0x804000
  800169:	e8 be 0b 00 00       	call   800d2c <strlen>
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800174:	74 25                	je     80019b <umain+0x11d>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	ff 35 00 40 80 00    	pushl  0x804000
  80017f:	e8 a8 0b 00 00       	call   800d2c <strlen>
  800184:	89 04 24             	mov    %eax,(%esp)
  800187:	ff 75 cc             	pushl  -0x34(%ebp)
  80018a:	68 d4 2a 80 00       	push   $0x802ad4
  80018f:	6a 2d                	push   $0x2d
  800191:	68 e5 28 80 00       	push   $0x8028e5
  800196:	e8 ed 04 00 00       	call   800688 <_panic>
	cprintf("file_stat is good\n");
  80019b:	83 ec 0c             	sub    $0xc,%esp
  80019e:	68 38 29 80 00       	push   $0x802938
  8001a3:	e8 b9 05 00 00       	call   800761 <cprintf>

	memset(buf, 0, sizeof buf);
  8001a8:	83 c4 0c             	add    $0xc,%esp
  8001ab:	68 00 02 00 00       	push   $0x200
  8001b0:	6a 00                	push   $0x0
  8001b2:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8001b8:	53                   	push   %ebx
  8001b9:	e8 ec 0c 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8001be:	83 c4 0c             	add    $0xc,%esp
  8001c1:	68 00 02 00 00       	push   $0x200
  8001c6:	53                   	push   %ebx
  8001c7:	68 00 c0 cc cc       	push   $0xccccc000
  8001cc:	ff 15 10 40 80 00    	call   *0x804010
  8001d2:	83 c4 10             	add    $0x10,%esp
  8001d5:	85 c0                	test   %eax,%eax
  8001d7:	79 12                	jns    8001eb <umain+0x16d>
		panic("file_read: %e", r);
  8001d9:	50                   	push   %eax
  8001da:	68 4b 29 80 00       	push   $0x80294b
  8001df:	6a 32                	push   $0x32
  8001e1:	68 e5 28 80 00       	push   $0x8028e5
  8001e6:	e8 9d 04 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8001eb:	83 ec 08             	sub    $0x8,%esp
  8001ee:	ff 35 00 40 80 00    	pushl  0x804000
  8001f4:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8001fa:	50                   	push   %eax
  8001fb:	e8 0f 0c 00 00       	call   800e0f <strcmp>
  800200:	83 c4 10             	add    $0x10,%esp
  800203:	85 c0                	test   %eax,%eax
  800205:	74 14                	je     80021b <umain+0x19d>
		panic("file_read returned wrong data");
  800207:	83 ec 04             	sub    $0x4,%esp
  80020a:	68 59 29 80 00       	push   $0x802959
  80020f:	6a 34                	push   $0x34
  800211:	68 e5 28 80 00       	push   $0x8028e5
  800216:	e8 6d 04 00 00       	call   800688 <_panic>
	cprintf("file_read is good\n");
  80021b:	83 ec 0c             	sub    $0xc,%esp
  80021e:	68 77 29 80 00       	push   $0x802977
  800223:	e8 39 05 00 00       	call   800761 <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  800228:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  80022f:	ff 15 18 40 80 00    	call   *0x804018
  800235:	83 c4 10             	add    $0x10,%esp
  800238:	85 c0                	test   %eax,%eax
  80023a:	79 12                	jns    80024e <umain+0x1d0>
		panic("file_close: %e", r);
  80023c:	50                   	push   %eax
  80023d:	68 8a 29 80 00       	push   $0x80298a
  800242:	6a 38                	push   $0x38
  800244:	68 e5 28 80 00       	push   $0x8028e5
  800249:	e8 3a 04 00 00       	call   800688 <_panic>
	cprintf("file_close is good\n");
  80024e:	83 ec 0c             	sub    $0xc,%esp
  800251:	68 99 29 80 00       	push   $0x802999
  800256:	e8 06 05 00 00       	call   800761 <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  80025b:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  800260:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800263:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  800268:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80026b:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  800270:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800273:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  800278:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  80027b:	83 c4 08             	add    $0x8,%esp
  80027e:	68 00 c0 cc cc       	push   $0xccccc000
  800283:	6a 00                	push   $0x0
  800285:	e8 63 0f 00 00       	call   8011ed <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  80028a:	83 c4 0c             	add    $0xc,%esp
  80028d:	68 00 02 00 00       	push   $0x200
  800292:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800298:	50                   	push   %eax
  800299:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80029c:	50                   	push   %eax
  80029d:	ff 15 10 40 80 00    	call   *0x804010
  8002a3:	83 c4 10             	add    $0x10,%esp
  8002a6:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8002a9:	74 12                	je     8002bd <umain+0x23f>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  8002ab:	50                   	push   %eax
  8002ac:	68 fc 2a 80 00       	push   $0x802afc
  8002b1:	6a 43                	push   $0x43
  8002b3:	68 e5 28 80 00       	push   $0x8028e5
  8002b8:	e8 cb 03 00 00       	call   800688 <_panic>
	cprintf("stale fileid is good\n");
  8002bd:	83 ec 0c             	sub    $0xc,%esp
  8002c0:	68 ad 29 80 00       	push   $0x8029ad
  8002c5:	e8 97 04 00 00       	call   800761 <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  8002ca:	ba 02 01 00 00       	mov    $0x102,%edx
  8002cf:	b8 c3 29 80 00       	mov    $0x8029c3,%eax
  8002d4:	e8 5a fd ff ff       	call   800033 <xopen>
  8002d9:	83 c4 10             	add    $0x10,%esp
  8002dc:	85 c0                	test   %eax,%eax
  8002de:	79 12                	jns    8002f2 <umain+0x274>
		panic("serve_open /new-file: %e", r);
  8002e0:	50                   	push   %eax
  8002e1:	68 cd 29 80 00       	push   $0x8029cd
  8002e6:	6a 48                	push   $0x48
  8002e8:	68 e5 28 80 00       	push   $0x8028e5
  8002ed:	e8 96 03 00 00       	call   800688 <_panic>

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  8002f2:	8b 1d 14 40 80 00    	mov    0x804014,%ebx
  8002f8:	83 ec 0c             	sub    $0xc,%esp
  8002fb:	ff 35 00 40 80 00    	pushl  0x804000
  800301:	e8 26 0a 00 00       	call   800d2c <strlen>
  800306:	83 c4 0c             	add    $0xc,%esp
  800309:	50                   	push   %eax
  80030a:	ff 35 00 40 80 00    	pushl  0x804000
  800310:	68 00 c0 cc cc       	push   $0xccccc000
  800315:	ff d3                	call   *%ebx
  800317:	89 c3                	mov    %eax,%ebx
  800319:	83 c4 04             	add    $0x4,%esp
  80031c:	ff 35 00 40 80 00    	pushl  0x804000
  800322:	e8 05 0a 00 00       	call   800d2c <strlen>
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	39 c3                	cmp    %eax,%ebx
  80032c:	74 12                	je     800340 <umain+0x2c2>
		panic("file_write: %e", r);
  80032e:	53                   	push   %ebx
  80032f:	68 e6 29 80 00       	push   $0x8029e6
  800334:	6a 4b                	push   $0x4b
  800336:	68 e5 28 80 00       	push   $0x8028e5
  80033b:	e8 48 03 00 00       	call   800688 <_panic>
	cprintf("file_write is good\n");
  800340:	83 ec 0c             	sub    $0xc,%esp
  800343:	68 f5 29 80 00       	push   $0x8029f5
  800348:	e8 14 04 00 00       	call   800761 <cprintf>

	FVA->fd_offset = 0;
  80034d:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  800354:	00 00 00 
	memset(buf, 0, sizeof buf);
  800357:	83 c4 0c             	add    $0xc,%esp
  80035a:	68 00 02 00 00       	push   $0x200
  80035f:	6a 00                	push   $0x0
  800361:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800367:	53                   	push   %ebx
  800368:	e8 3d 0b 00 00       	call   800eaa <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80036d:	83 c4 0c             	add    $0xc,%esp
  800370:	68 00 02 00 00       	push   $0x200
  800375:	53                   	push   %ebx
  800376:	68 00 c0 cc cc       	push   $0xccccc000
  80037b:	ff 15 10 40 80 00    	call   *0x804010
  800381:	89 c3                	mov    %eax,%ebx
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	85 c0                	test   %eax,%eax
  800388:	79 12                	jns    80039c <umain+0x31e>
		panic("file_read after file_write: %e", r);
  80038a:	50                   	push   %eax
  80038b:	68 34 2b 80 00       	push   $0x802b34
  800390:	6a 51                	push   $0x51
  800392:	68 e5 28 80 00       	push   $0x8028e5
  800397:	e8 ec 02 00 00       	call   800688 <_panic>
	if (r != strlen(msg))
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	ff 35 00 40 80 00    	pushl  0x804000
  8003a5:	e8 82 09 00 00       	call   800d2c <strlen>
  8003aa:	83 c4 10             	add    $0x10,%esp
  8003ad:	39 c3                	cmp    %eax,%ebx
  8003af:	74 12                	je     8003c3 <umain+0x345>
		panic("file_read after file_write returned wrong length: %d", r);
  8003b1:	53                   	push   %ebx
  8003b2:	68 54 2b 80 00       	push   $0x802b54
  8003b7:	6a 53                	push   $0x53
  8003b9:	68 e5 28 80 00       	push   $0x8028e5
  8003be:	e8 c5 02 00 00       	call   800688 <_panic>
	if (strcmp(buf, msg) != 0)
  8003c3:	83 ec 08             	sub    $0x8,%esp
  8003c6:	ff 35 00 40 80 00    	pushl  0x804000
  8003cc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003d2:	50                   	push   %eax
  8003d3:	e8 37 0a 00 00       	call   800e0f <strcmp>
  8003d8:	83 c4 10             	add    $0x10,%esp
  8003db:	85 c0                	test   %eax,%eax
  8003dd:	74 14                	je     8003f3 <umain+0x375>
		panic("file_read after file_write returned wrong data");
  8003df:	83 ec 04             	sub    $0x4,%esp
  8003e2:	68 8c 2b 80 00       	push   $0x802b8c
  8003e7:	6a 55                	push   $0x55
  8003e9:	68 e5 28 80 00       	push   $0x8028e5
  8003ee:	e8 95 02 00 00       	call   800688 <_panic>
	cprintf("file_read after file_write is good\n");
  8003f3:	83 ec 0c             	sub    $0xc,%esp
  8003f6:	68 bc 2b 80 00       	push   $0x802bbc
  8003fb:	e8 61 03 00 00       	call   800761 <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  800400:	83 c4 08             	add    $0x8,%esp
  800403:	6a 00                	push   $0x0
  800405:	68 c0 28 80 00       	push   $0x8028c0
  80040a:	e8 e6 17 00 00       	call   801bf5 <open>
  80040f:	83 c4 10             	add    $0x10,%esp
  800412:	83 f8 f5             	cmp    $0xfffffff5,%eax
  800415:	74 1b                	je     800432 <umain+0x3b4>
  800417:	89 c2                	mov    %eax,%edx
  800419:	c1 ea 1f             	shr    $0x1f,%edx
  80041c:	84 d2                	test   %dl,%dl
  80041e:	74 12                	je     800432 <umain+0x3b4>
		panic("open /not-found: %e", r);
  800420:	50                   	push   %eax
  800421:	68 d1 28 80 00       	push   $0x8028d1
  800426:	6a 5a                	push   $0x5a
  800428:	68 e5 28 80 00       	push   $0x8028e5
  80042d:	e8 56 02 00 00       	call   800688 <_panic>
	else if (r >= 0)
  800432:	85 c0                	test   %eax,%eax
  800434:	78 14                	js     80044a <umain+0x3cc>
		panic("open /not-found succeeded!");
  800436:	83 ec 04             	sub    $0x4,%esp
  800439:	68 09 2a 80 00       	push   $0x802a09
  80043e:	6a 5c                	push   $0x5c
  800440:	68 e5 28 80 00       	push   $0x8028e5
  800445:	e8 3e 02 00 00       	call   800688 <_panic>

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  80044a:	83 ec 08             	sub    $0x8,%esp
  80044d:	6a 00                	push   $0x0
  80044f:	68 f5 28 80 00       	push   $0x8028f5
  800454:	e8 9c 17 00 00       	call   801bf5 <open>
  800459:	83 c4 10             	add    $0x10,%esp
  80045c:	85 c0                	test   %eax,%eax
  80045e:	79 12                	jns    800472 <umain+0x3f4>
		panic("open /newmotd: %e", r);
  800460:	50                   	push   %eax
  800461:	68 04 29 80 00       	push   $0x802904
  800466:	6a 5f                	push   $0x5f
  800468:	68 e5 28 80 00       	push   $0x8028e5
  80046d:	e8 16 02 00 00       	call   800688 <_panic>
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  800472:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  800475:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  80047c:	75 12                	jne    800490 <umain+0x412>
  80047e:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800485:	75 09                	jne    800490 <umain+0x412>
  800487:	83 b8 08 00 00 d0 00 	cmpl   $0x0,-0x2ffffff8(%eax)
  80048e:	74 14                	je     8004a4 <umain+0x426>
		panic("open did not fill struct Fd correctly\n");
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	68 e0 2b 80 00       	push   $0x802be0
  800498:	6a 62                	push   $0x62
  80049a:	68 e5 28 80 00       	push   $0x8028e5
  80049f:	e8 e4 01 00 00       	call   800688 <_panic>
	cprintf("open is good\n");
  8004a4:	83 ec 0c             	sub    $0xc,%esp
  8004a7:	68 1c 29 80 00       	push   $0x80291c
  8004ac:	e8 b0 02 00 00       	call   800761 <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  8004b1:	83 c4 08             	add    $0x8,%esp
  8004b4:	68 01 01 00 00       	push   $0x101
  8004b9:	68 24 2a 80 00       	push   $0x802a24
  8004be:	e8 32 17 00 00       	call   801bf5 <open>
  8004c3:	89 c6                	mov    %eax,%esi
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	79 12                	jns    8004de <umain+0x460>
		panic("creat /big: %e", f);
  8004cc:	50                   	push   %eax
  8004cd:	68 29 2a 80 00       	push   $0x802a29
  8004d2:	6a 67                	push   $0x67
  8004d4:	68 e5 28 80 00       	push   $0x8028e5
  8004d9:	e8 aa 01 00 00       	call   800688 <_panic>
	memset(buf, 0, sizeof(buf));
  8004de:	83 ec 04             	sub    $0x4,%esp
  8004e1:	68 00 02 00 00       	push   $0x200
  8004e6:	6a 00                	push   $0x0
  8004e8:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8004ee:	50                   	push   %eax
  8004ef:	e8 b6 09 00 00       	call   800eaa <memset>
  8004f4:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8004f7:	bb 00 00 00 00       	mov    $0x0,%ebx
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8004fc:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800502:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  800508:	83 ec 04             	sub    $0x4,%esp
  80050b:	68 00 02 00 00       	push   $0x200
  800510:	57                   	push   %edi
  800511:	56                   	push   %esi
  800512:	e8 2d 13 00 00       	call   801844 <write>
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 c0                	test   %eax,%eax
  80051c:	79 16                	jns    800534 <umain+0x4b6>
			panic("write /big@%d: %e", i, r);
  80051e:	83 ec 0c             	sub    $0xc,%esp
  800521:	50                   	push   %eax
  800522:	53                   	push   %ebx
  800523:	68 38 2a 80 00       	push   $0x802a38
  800528:	6a 6c                	push   $0x6c
  80052a:	68 e5 28 80 00       	push   $0x8028e5
  80052f:	e8 54 01 00 00       	call   800688 <_panic>
  800534:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  80053a:	89 c3                	mov    %eax,%ebx

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80053c:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800541:	75 bf                	jne    800502 <umain+0x484>
		*(int*)buf = i;
		if ((r = write(f, buf, sizeof(buf))) < 0)
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800543:	83 ec 0c             	sub    $0xc,%esp
  800546:	56                   	push   %esi
  800547:	e8 e2 10 00 00       	call   80162e <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80054c:	83 c4 08             	add    $0x8,%esp
  80054f:	6a 00                	push   $0x0
  800551:	68 24 2a 80 00       	push   $0x802a24
  800556:	e8 9a 16 00 00       	call   801bf5 <open>
  80055b:	89 c6                	mov    %eax,%esi
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	79 12                	jns    800576 <umain+0x4f8>
		panic("open /big: %e", f);
  800564:	50                   	push   %eax
  800565:	68 4a 2a 80 00       	push   $0x802a4a
  80056a:	6a 71                	push   $0x71
  80056c:	68 e5 28 80 00       	push   $0x8028e5
  800571:	e8 12 01 00 00       	call   800688 <_panic>
  800576:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  80057b:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
  800581:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800587:	83 ec 04             	sub    $0x4,%esp
  80058a:	68 00 02 00 00       	push   $0x200
  80058f:	57                   	push   %edi
  800590:	56                   	push   %esi
  800591:	e8 65 12 00 00       	call   8017fb <readn>
  800596:	83 c4 10             	add    $0x10,%esp
  800599:	85 c0                	test   %eax,%eax
  80059b:	79 16                	jns    8005b3 <umain+0x535>
			panic("read /big@%d: %e", i, r);
  80059d:	83 ec 0c             	sub    $0xc,%esp
  8005a0:	50                   	push   %eax
  8005a1:	53                   	push   %ebx
  8005a2:	68 58 2a 80 00       	push   $0x802a58
  8005a7:	6a 75                	push   $0x75
  8005a9:	68 e5 28 80 00       	push   $0x8028e5
  8005ae:	e8 d5 00 00 00       	call   800688 <_panic>
		if (r != sizeof(buf))
  8005b3:	3d 00 02 00 00       	cmp    $0x200,%eax
  8005b8:	74 1b                	je     8005d5 <umain+0x557>
			panic("read /big from %d returned %d < %d bytes",
  8005ba:	83 ec 08             	sub    $0x8,%esp
  8005bd:	68 00 02 00 00       	push   $0x200
  8005c2:	50                   	push   %eax
  8005c3:	53                   	push   %ebx
  8005c4:	68 08 2c 80 00       	push   $0x802c08
  8005c9:	6a 78                	push   $0x78
  8005cb:	68 e5 28 80 00       	push   $0x8028e5
  8005d0:	e8 b3 00 00 00       	call   800688 <_panic>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  8005d5:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  8005db:	39 d8                	cmp    %ebx,%eax
  8005dd:	74 16                	je     8005f5 <umain+0x577>
			panic("read /big from %d returned bad data %d",
  8005df:	83 ec 0c             	sub    $0xc,%esp
  8005e2:	50                   	push   %eax
  8005e3:	53                   	push   %ebx
  8005e4:	68 34 2c 80 00       	push   $0x802c34
  8005e9:	6a 7b                	push   $0x7b
  8005eb:	68 e5 28 80 00       	push   $0x8028e5
  8005f0:	e8 93 00 00 00       	call   800688 <_panic>
  8005f5:	8d 83 00 02 00 00    	lea    0x200(%ebx),%eax
  8005fb:	89 c3                	mov    %eax,%ebx
	}
	close(f);

	if ((f = open("/big", O_RDONLY)) < 0)
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8005fd:	3d 00 e0 01 00       	cmp    $0x1e000,%eax
  800602:	0f 85 79 ff ff ff    	jne    800581 <umain+0x503>
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800608:	83 ec 0c             	sub    $0xc,%esp
  80060b:	56                   	push   %esi
  80060c:	e8 1d 10 00 00       	call   80162e <close>
	cprintf("large file is good\n");
  800611:	c7 04 24 69 2a 80 00 	movl   $0x802a69,(%esp)
  800618:	e8 44 01 00 00       	call   800761 <cprintf>
}
  80061d:	83 c4 10             	add    $0x10,%esp
  800620:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800623:	5b                   	pop    %ebx
  800624:	5e                   	pop    %esi
  800625:	5f                   	pop    %edi
  800626:	5d                   	pop    %ebp
  800627:	c3                   	ret    

00800628 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800628:	55                   	push   %ebp
  800629:	89 e5                	mov    %esp,%ebp
  80062b:	56                   	push   %esi
  80062c:	53                   	push   %ebx
  80062d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800630:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800633:	e8 f2 0a 00 00       	call   80112a <sys_getenvid>
  800638:	25 ff 03 00 00       	and    $0x3ff,%eax
  80063d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800640:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800645:	a3 08 50 80 00       	mov    %eax,0x805008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  80064a:	85 db                	test   %ebx,%ebx
  80064c:	7e 07                	jle    800655 <libmain+0x2d>
        binaryname = argv[0];
  80064e:	8b 06                	mov    (%esi),%eax
  800650:	a3 04 40 80 00       	mov    %eax,0x804004

    // call user main routine
    umain(argc, argv);
  800655:	83 ec 08             	sub    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	53                   	push   %ebx
  80065a:	e8 1f fa ff ff       	call   80007e <umain>

    // exit gracefully
    exit();
  80065f:	e8 0a 00 00 00       	call   80066e <exit>
}
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5d                   	pop    %ebp
  80066d:	c3                   	ret    

0080066e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80066e:	55                   	push   %ebp
  80066f:	89 e5                	mov    %esp,%ebp
  800671:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800674:	e8 e0 0f 00 00       	call   801659 <close_all>
	sys_env_destroy(0);
  800679:	83 ec 0c             	sub    $0xc,%esp
  80067c:	6a 00                	push   $0x0
  80067e:	e8 66 0a 00 00       	call   8010e9 <sys_env_destroy>
}
  800683:	83 c4 10             	add    $0x10,%esp
  800686:	c9                   	leave  
  800687:	c3                   	ret    

00800688 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	56                   	push   %esi
  80068c:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80068d:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800690:	8b 35 04 40 80 00    	mov    0x804004,%esi
  800696:	e8 8f 0a 00 00       	call   80112a <sys_getenvid>
  80069b:	83 ec 0c             	sub    $0xc,%esp
  80069e:	ff 75 0c             	pushl  0xc(%ebp)
  8006a1:	ff 75 08             	pushl  0x8(%ebp)
  8006a4:	56                   	push   %esi
  8006a5:	50                   	push   %eax
  8006a6:	68 8c 2c 80 00       	push   $0x802c8c
  8006ab:	e8 b1 00 00 00       	call   800761 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8006b0:	83 c4 18             	add    $0x18,%esp
  8006b3:	53                   	push   %ebx
  8006b4:	ff 75 10             	pushl  0x10(%ebp)
  8006b7:	e8 54 00 00 00       	call   800710 <vcprintf>
	cprintf("\n");
  8006bc:	c7 04 24 24 31 80 00 	movl   $0x803124,(%esp)
  8006c3:	e8 99 00 00 00       	call   800761 <cprintf>
  8006c8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8006cb:	cc                   	int3   
  8006cc:	eb fd                	jmp    8006cb <_panic+0x43>

008006ce <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006ce:	55                   	push   %ebp
  8006cf:	89 e5                	mov    %esp,%ebp
  8006d1:	53                   	push   %ebx
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006d8:	8b 13                	mov    (%ebx),%edx
  8006da:	8d 42 01             	lea    0x1(%edx),%eax
  8006dd:	89 03                	mov    %eax,(%ebx)
  8006df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006e2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8006e6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006eb:	75 1a                	jne    800707 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8006ed:	83 ec 08             	sub    $0x8,%esp
  8006f0:	68 ff 00 00 00       	push   $0xff
  8006f5:	8d 43 08             	lea    0x8(%ebx),%eax
  8006f8:	50                   	push   %eax
  8006f9:	e8 ae 09 00 00       	call   8010ac <sys_cputs>
		b->idx = 0;
  8006fe:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800704:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800707:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80070b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80070e:	c9                   	leave  
  80070f:	c3                   	ret    

00800710 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800710:	55                   	push   %ebp
  800711:	89 e5                	mov    %esp,%ebp
  800713:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800719:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800720:	00 00 00 
	b.cnt = 0;
  800723:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80072a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80072d:	ff 75 0c             	pushl  0xc(%ebp)
  800730:	ff 75 08             	pushl  0x8(%ebp)
  800733:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800739:	50                   	push   %eax
  80073a:	68 ce 06 80 00       	push   $0x8006ce
  80073f:	e8 1a 01 00 00       	call   80085e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800744:	83 c4 08             	add    $0x8,%esp
  800747:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80074d:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800753:	50                   	push   %eax
  800754:	e8 53 09 00 00       	call   8010ac <sys_cputs>

	return b.cnt;
}
  800759:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800767:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80076a:	50                   	push   %eax
  80076b:	ff 75 08             	pushl  0x8(%ebp)
  80076e:	e8 9d ff ff ff       	call   800710 <vcprintf>
	va_end(ap);

	return cnt;
}
  800773:	c9                   	leave  
  800774:	c3                   	ret    

00800775 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800775:	55                   	push   %ebp
  800776:	89 e5                	mov    %esp,%ebp
  800778:	57                   	push   %edi
  800779:	56                   	push   %esi
  80077a:	53                   	push   %ebx
  80077b:	83 ec 1c             	sub    $0x1c,%esp
  80077e:	89 c7                	mov    %eax,%edi
  800780:	89 d6                	mov    %edx,%esi
  800782:	8b 45 08             	mov    0x8(%ebp),%eax
  800785:	8b 55 0c             	mov    0xc(%ebp),%edx
  800788:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078b:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80078e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800791:	bb 00 00 00 00       	mov    $0x0,%ebx
  800796:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800799:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80079c:	39 d3                	cmp    %edx,%ebx
  80079e:	72 05                	jb     8007a5 <printnum+0x30>
  8007a0:	39 45 10             	cmp    %eax,0x10(%ebp)
  8007a3:	77 45                	ja     8007ea <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8007a5:	83 ec 0c             	sub    $0xc,%esp
  8007a8:	ff 75 18             	pushl  0x18(%ebp)
  8007ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ae:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8007b1:	53                   	push   %ebx
  8007b2:	ff 75 10             	pushl  0x10(%ebp)
  8007b5:	83 ec 08             	sub    $0x8,%esp
  8007b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007bb:	ff 75 e0             	pushl  -0x20(%ebp)
  8007be:	ff 75 dc             	pushl  -0x24(%ebp)
  8007c1:	ff 75 d8             	pushl  -0x28(%ebp)
  8007c4:	e8 57 1e 00 00       	call   802620 <__udivdi3>
  8007c9:	83 c4 18             	add    $0x18,%esp
  8007cc:	52                   	push   %edx
  8007cd:	50                   	push   %eax
  8007ce:	89 f2                	mov    %esi,%edx
  8007d0:	89 f8                	mov    %edi,%eax
  8007d2:	e8 9e ff ff ff       	call   800775 <printnum>
  8007d7:	83 c4 20             	add    $0x20,%esp
  8007da:	eb 18                	jmp    8007f4 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	56                   	push   %esi
  8007e0:	ff 75 18             	pushl  0x18(%ebp)
  8007e3:	ff d7                	call   *%edi
  8007e5:	83 c4 10             	add    $0x10,%esp
  8007e8:	eb 03                	jmp    8007ed <printnum+0x78>
  8007ea:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007ed:	83 eb 01             	sub    $0x1,%ebx
  8007f0:	85 db                	test   %ebx,%ebx
  8007f2:	7f e8                	jg     8007dc <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007f4:	83 ec 08             	sub    $0x8,%esp
  8007f7:	56                   	push   %esi
  8007f8:	83 ec 04             	sub    $0x4,%esp
  8007fb:	ff 75 e4             	pushl  -0x1c(%ebp)
  8007fe:	ff 75 e0             	pushl  -0x20(%ebp)
  800801:	ff 75 dc             	pushl  -0x24(%ebp)
  800804:	ff 75 d8             	pushl  -0x28(%ebp)
  800807:	e8 44 1f 00 00       	call   802750 <__umoddi3>
  80080c:	83 c4 14             	add    $0x14,%esp
  80080f:	0f be 80 af 2c 80 00 	movsbl 0x802caf(%eax),%eax
  800816:	50                   	push   %eax
  800817:	ff d7                	call   *%edi
}
  800819:	83 c4 10             	add    $0x10,%esp
  80081c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80081f:	5b                   	pop    %ebx
  800820:	5e                   	pop    %esi
  800821:	5f                   	pop    %edi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80082a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	3b 50 04             	cmp    0x4(%eax),%edx
  800833:	73 0a                	jae    80083f <sprintputch+0x1b>
		*b->buf++ = ch;
  800835:	8d 4a 01             	lea    0x1(%edx),%ecx
  800838:	89 08                	mov    %ecx,(%eax)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	88 02                	mov    %al,(%edx)
}
  80083f:	5d                   	pop    %ebp
  800840:	c3                   	ret    

00800841 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800841:	55                   	push   %ebp
  800842:	89 e5                	mov    %esp,%ebp
  800844:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  800847:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80084a:	50                   	push   %eax
  80084b:	ff 75 10             	pushl  0x10(%ebp)
  80084e:	ff 75 0c             	pushl  0xc(%ebp)
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 05 00 00 00       	call   80085e <vprintfmt>
	va_end(ap);
}
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	c9                   	leave  
  80085d:	c3                   	ret    

0080085e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	57                   	push   %edi
  800862:	56                   	push   %esi
  800863:	53                   	push   %ebx
  800864:	83 ec 2c             	sub    $0x2c,%esp
  800867:	8b 75 08             	mov    0x8(%ebp),%esi
  80086a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80086d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800870:	eb 12                	jmp    800884 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800872:	85 c0                	test   %eax,%eax
  800874:	0f 84 42 04 00 00    	je     800cbc <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	50                   	push   %eax
  80087f:	ff d6                	call   *%esi
  800881:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800884:	83 c7 01             	add    $0x1,%edi
  800887:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80088b:	83 f8 25             	cmp    $0x25,%eax
  80088e:	75 e2                	jne    800872 <vprintfmt+0x14>
  800890:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800894:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80089b:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008a2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8008a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ae:	eb 07                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8008b3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008b7:	8d 47 01             	lea    0x1(%edi),%eax
  8008ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008bd:	0f b6 07             	movzbl (%edi),%eax
  8008c0:	0f b6 d0             	movzbl %al,%edx
  8008c3:	83 e8 23             	sub    $0x23,%eax
  8008c6:	3c 55                	cmp    $0x55,%al
  8008c8:	0f 87 d3 03 00 00    	ja     800ca1 <vprintfmt+0x443>
  8008ce:	0f b6 c0             	movzbl %al,%eax
  8008d1:	ff 24 85 00 2e 80 00 	jmp    *0x802e00(,%eax,4)
  8008d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8008db:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8008df:	eb d6                	jmp    8008b7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8008ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8008ef:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8008f3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8008f6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8008f9:	83 f9 09             	cmp    $0x9,%ecx
  8008fc:	77 3f                	ja     80093d <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8008fe:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800901:	eb e9                	jmp    8008ec <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800903:	8b 45 14             	mov    0x14(%ebp),%eax
  800906:	8b 00                	mov    (%eax),%eax
  800908:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80090b:	8b 45 14             	mov    0x14(%ebp),%eax
  80090e:	8d 40 04             	lea    0x4(%eax),%eax
  800911:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800917:	eb 2a                	jmp    800943 <vprintfmt+0xe5>
  800919:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80091c:	85 c0                	test   %eax,%eax
  80091e:	ba 00 00 00 00       	mov    $0x0,%edx
  800923:	0f 49 d0             	cmovns %eax,%edx
  800926:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800929:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80092c:	eb 89                	jmp    8008b7 <vprintfmt+0x59>
  80092e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  800931:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  800938:	e9 7a ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
  80093d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800940:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  800943:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800947:	0f 89 6a ff ff ff    	jns    8008b7 <vprintfmt+0x59>
				width = precision, precision = -1;
  80094d:	8b 45 d0             	mov    -0x30(%ebp),%eax
  800950:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800953:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80095a:	e9 58 ff ff ff       	jmp    8008b7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80095f:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800962:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800965:	e9 4d ff ff ff       	jmp    8008b7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80096a:	8b 45 14             	mov    0x14(%ebp),%eax
  80096d:	8d 78 04             	lea    0x4(%eax),%edi
  800970:	83 ec 08             	sub    $0x8,%esp
  800973:	53                   	push   %ebx
  800974:	ff 30                	pushl  (%eax)
  800976:	ff d6                	call   *%esi
			break;
  800978:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80097b:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80097e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  800981:	e9 fe fe ff ff       	jmp    800884 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800986:	8b 45 14             	mov    0x14(%ebp),%eax
  800989:	8d 78 04             	lea    0x4(%eax),%edi
  80098c:	8b 00                	mov    (%eax),%eax
  80098e:	99                   	cltd   
  80098f:	31 d0                	xor    %edx,%eax
  800991:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800993:	83 f8 0f             	cmp    $0xf,%eax
  800996:	7f 0b                	jg     8009a3 <vprintfmt+0x145>
  800998:	8b 14 85 60 2f 80 00 	mov    0x802f60(,%eax,4),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	75 1b                	jne    8009be <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8009a3:	50                   	push   %eax
  8009a4:	68 c7 2c 80 00       	push   $0x802cc7
  8009a9:	53                   	push   %ebx
  8009aa:	56                   	push   %esi
  8009ab:	e8 91 fe ff ff       	call   800841 <printfmt>
  8009b0:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009b3:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8009b9:	e9 c6 fe ff ff       	jmp    800884 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8009be:	52                   	push   %edx
  8009bf:	68 b9 30 80 00       	push   $0x8030b9
  8009c4:	53                   	push   %ebx
  8009c5:	56                   	push   %esi
  8009c6:	e8 76 fe ff ff       	call   800841 <printfmt>
  8009cb:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009ce:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8009d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009d4:	e9 ab fe ff ff       	jmp    800884 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8009d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8009dc:	83 c0 04             	add    $0x4,%eax
  8009df:	89 45 cc             	mov    %eax,-0x34(%ebp)
  8009e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009e5:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8009e7:	85 ff                	test   %edi,%edi
  8009e9:	b8 c0 2c 80 00       	mov    $0x802cc0,%eax
  8009ee:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8009f1:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009f5:	0f 8e 94 00 00 00    	jle    800a8f <vprintfmt+0x231>
  8009fb:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8009ff:	0f 84 98 00 00 00    	je     800a9d <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800a05:	83 ec 08             	sub    $0x8,%esp
  800a08:	ff 75 d0             	pushl  -0x30(%ebp)
  800a0b:	57                   	push   %edi
  800a0c:	e8 33 03 00 00       	call   800d44 <strnlen>
  800a11:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800a14:	29 c1                	sub    %eax,%ecx
  800a16:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800a19:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800a1c:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  800a20:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a23:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800a26:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a28:	eb 0f                	jmp    800a39 <vprintfmt+0x1db>
					putch(padc, putdat);
  800a2a:	83 ec 08             	sub    $0x8,%esp
  800a2d:	53                   	push   %ebx
  800a2e:	ff 75 e0             	pushl  -0x20(%ebp)
  800a31:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a33:	83 ef 01             	sub    $0x1,%edi
  800a36:	83 c4 10             	add    $0x10,%esp
  800a39:	85 ff                	test   %edi,%edi
  800a3b:	7f ed                	jg     800a2a <vprintfmt+0x1cc>
  800a3d:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  800a40:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  800a43:	85 c9                	test   %ecx,%ecx
  800a45:	b8 00 00 00 00       	mov    $0x0,%eax
  800a4a:	0f 49 c1             	cmovns %ecx,%eax
  800a4d:	29 c1                	sub    %eax,%ecx
  800a4f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a52:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a55:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a58:	89 cb                	mov    %ecx,%ebx
  800a5a:	eb 4d                	jmp    800aa9 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800a5c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800a60:	74 1b                	je     800a7d <vprintfmt+0x21f>
  800a62:	0f be c0             	movsbl %al,%eax
  800a65:	83 e8 20             	sub    $0x20,%eax
  800a68:	83 f8 5e             	cmp    $0x5e,%eax
  800a6b:	76 10                	jbe    800a7d <vprintfmt+0x21f>
					putch('?', putdat);
  800a6d:	83 ec 08             	sub    $0x8,%esp
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	6a 3f                	push   $0x3f
  800a75:	ff 55 08             	call   *0x8(%ebp)
  800a78:	83 c4 10             	add    $0x10,%esp
  800a7b:	eb 0d                	jmp    800a8a <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800a7d:	83 ec 08             	sub    $0x8,%esp
  800a80:	ff 75 0c             	pushl  0xc(%ebp)
  800a83:	52                   	push   %edx
  800a84:	ff 55 08             	call   *0x8(%ebp)
  800a87:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a8a:	83 eb 01             	sub    $0x1,%ebx
  800a8d:	eb 1a                	jmp    800aa9 <vprintfmt+0x24b>
  800a8f:	89 75 08             	mov    %esi,0x8(%ebp)
  800a92:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a95:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a98:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a9b:	eb 0c                	jmp    800aa9 <vprintfmt+0x24b>
  800a9d:	89 75 08             	mov    %esi,0x8(%ebp)
  800aa0:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800aa3:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800aa6:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aa9:	83 c7 01             	add    $0x1,%edi
  800aac:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800ab0:	0f be d0             	movsbl %al,%edx
  800ab3:	85 d2                	test   %edx,%edx
  800ab5:	74 23                	je     800ada <vprintfmt+0x27c>
  800ab7:	85 f6                	test   %esi,%esi
  800ab9:	78 a1                	js     800a5c <vprintfmt+0x1fe>
  800abb:	83 ee 01             	sub    $0x1,%esi
  800abe:	79 9c                	jns    800a5c <vprintfmt+0x1fe>
  800ac0:	89 df                	mov    %ebx,%edi
  800ac2:	8b 75 08             	mov    0x8(%ebp),%esi
  800ac5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac8:	eb 18                	jmp    800ae2 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800aca:	83 ec 08             	sub    $0x8,%esp
  800acd:	53                   	push   %ebx
  800ace:	6a 20                	push   $0x20
  800ad0:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ad2:	83 ef 01             	sub    $0x1,%edi
  800ad5:	83 c4 10             	add    $0x10,%esp
  800ad8:	eb 08                	jmp    800ae2 <vprintfmt+0x284>
  800ada:	89 df                	mov    %ebx,%edi
  800adc:	8b 75 08             	mov    0x8(%ebp),%esi
  800adf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ae2:	85 ff                	test   %edi,%edi
  800ae4:	7f e4                	jg     800aca <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800ae6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ae9:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800aec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800aef:	e9 90 fd ff ff       	jmp    800884 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af4:	83 f9 01             	cmp    $0x1,%ecx
  800af7:	7e 19                	jle    800b12 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800af9:	8b 45 14             	mov    0x14(%ebp),%eax
  800afc:	8b 50 04             	mov    0x4(%eax),%edx
  800aff:	8b 00                	mov    (%eax),%eax
  800b01:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b04:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800b07:	8b 45 14             	mov    0x14(%ebp),%eax
  800b0a:	8d 40 08             	lea    0x8(%eax),%eax
  800b0d:	89 45 14             	mov    %eax,0x14(%ebp)
  800b10:	eb 38                	jmp    800b4a <vprintfmt+0x2ec>
	else if (lflag)
  800b12:	85 c9                	test   %ecx,%ecx
  800b14:	74 1b                	je     800b31 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800b16:	8b 45 14             	mov    0x14(%ebp),%eax
  800b19:	8b 00                	mov    (%eax),%eax
  800b1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b1e:	89 c1                	mov    %eax,%ecx
  800b20:	c1 f9 1f             	sar    $0x1f,%ecx
  800b23:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b26:	8b 45 14             	mov    0x14(%ebp),%eax
  800b29:	8d 40 04             	lea    0x4(%eax),%eax
  800b2c:	89 45 14             	mov    %eax,0x14(%ebp)
  800b2f:	eb 19                	jmp    800b4a <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800b31:	8b 45 14             	mov    0x14(%ebp),%eax
  800b34:	8b 00                	mov    (%eax),%eax
  800b36:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b39:	89 c1                	mov    %eax,%ecx
  800b3b:	c1 f9 1f             	sar    $0x1f,%ecx
  800b3e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b41:	8b 45 14             	mov    0x14(%ebp),%eax
  800b44:	8d 40 04             	lea    0x4(%eax),%eax
  800b47:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b4a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b4d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800b50:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800b55:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800b59:	0f 89 0e 01 00 00    	jns    800c6d <vprintfmt+0x40f>
				putch('-', putdat);
  800b5f:	83 ec 08             	sub    $0x8,%esp
  800b62:	53                   	push   %ebx
  800b63:	6a 2d                	push   $0x2d
  800b65:	ff d6                	call   *%esi
				num = -(long long) num;
  800b67:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b6a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b6d:	f7 da                	neg    %edx
  800b6f:	83 d1 00             	adc    $0x0,%ecx
  800b72:	f7 d9                	neg    %ecx
  800b74:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800b77:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b7c:	e9 ec 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b81:	83 f9 01             	cmp    $0x1,%ecx
  800b84:	7e 18                	jle    800b9e <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800b86:	8b 45 14             	mov    0x14(%ebp),%eax
  800b89:	8b 10                	mov    (%eax),%edx
  800b8b:	8b 48 04             	mov    0x4(%eax),%ecx
  800b8e:	8d 40 08             	lea    0x8(%eax),%eax
  800b91:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b94:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b99:	e9 cf 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b9e:	85 c9                	test   %ecx,%ecx
  800ba0:	74 1a                	je     800bbc <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800ba2:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba5:	8b 10                	mov    (%eax),%edx
  800ba7:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bac:	8d 40 04             	lea    0x4(%eax),%eax
  800baf:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bb2:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bb7:	e9 b1 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800bbf:	8b 10                	mov    (%eax),%edx
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	8d 40 04             	lea    0x4(%eax),%eax
  800bc9:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800bcc:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bd1:	e9 97 00 00 00       	jmp    800c6d <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800bd6:	83 ec 08             	sub    $0x8,%esp
  800bd9:	53                   	push   %ebx
  800bda:	6a 58                	push   $0x58
  800bdc:	ff d6                	call   *%esi
			putch('X', putdat);
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	53                   	push   %ebx
  800be2:	6a 58                	push   $0x58
  800be4:	ff d6                	call   *%esi
			putch('X', putdat);
  800be6:	83 c4 08             	add    $0x8,%esp
  800be9:	53                   	push   %ebx
  800bea:	6a 58                	push   $0x58
  800bec:	ff d6                	call   *%esi
			break;
  800bee:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800bf1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800bf4:	e9 8b fc ff ff       	jmp    800884 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800bf9:	83 ec 08             	sub    $0x8,%esp
  800bfc:	53                   	push   %ebx
  800bfd:	6a 30                	push   $0x30
  800bff:	ff d6                	call   *%esi
			putch('x', putdat);
  800c01:	83 c4 08             	add    $0x8,%esp
  800c04:	53                   	push   %ebx
  800c05:	6a 78                	push   $0x78
  800c07:	ff d6                	call   *%esi
			num = (unsigned long long)
  800c09:	8b 45 14             	mov    0x14(%ebp),%eax
  800c0c:	8b 10                	mov    (%eax),%edx
  800c0e:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c13:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800c16:	8d 40 04             	lea    0x4(%eax),%eax
  800c19:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800c1c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c21:	eb 4a                	jmp    800c6d <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c23:	83 f9 01             	cmp    $0x1,%ecx
  800c26:	7e 15                	jle    800c3d <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800c28:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2b:	8b 10                	mov    (%eax),%edx
  800c2d:	8b 48 04             	mov    0x4(%eax),%ecx
  800c30:	8d 40 08             	lea    0x8(%eax),%eax
  800c33:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c36:	b8 10 00 00 00       	mov    $0x10,%eax
  800c3b:	eb 30                	jmp    800c6d <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c3d:	85 c9                	test   %ecx,%ecx
  800c3f:	74 17                	je     800c58 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800c41:	8b 45 14             	mov    0x14(%ebp),%eax
  800c44:	8b 10                	mov    (%eax),%edx
  800c46:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c4b:	8d 40 04             	lea    0x4(%eax),%eax
  800c4e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c51:	b8 10 00 00 00       	mov    $0x10,%eax
  800c56:	eb 15                	jmp    800c6d <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800c58:	8b 45 14             	mov    0x14(%ebp),%eax
  800c5b:	8b 10                	mov    (%eax),%edx
  800c5d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c62:	8d 40 04             	lea    0x4(%eax),%eax
  800c65:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800c68:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800c74:	57                   	push   %edi
  800c75:	ff 75 e0             	pushl  -0x20(%ebp)
  800c78:	50                   	push   %eax
  800c79:	51                   	push   %ecx
  800c7a:	52                   	push   %edx
  800c7b:	89 da                	mov    %ebx,%edx
  800c7d:	89 f0                	mov    %esi,%eax
  800c7f:	e8 f1 fa ff ff       	call   800775 <printnum>
			break;
  800c84:	83 c4 20             	add    $0x20,%esp
  800c87:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800c8a:	e9 f5 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c8f:	83 ec 08             	sub    $0x8,%esp
  800c92:	53                   	push   %ebx
  800c93:	52                   	push   %edx
  800c94:	ff d6                	call   *%esi
			break;
  800c96:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c99:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c9c:	e9 e3 fb ff ff       	jmp    800884 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ca1:	83 ec 08             	sub    $0x8,%esp
  800ca4:	53                   	push   %ebx
  800ca5:	6a 25                	push   $0x25
  800ca7:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca9:	83 c4 10             	add    $0x10,%esp
  800cac:	eb 03                	jmp    800cb1 <vprintfmt+0x453>
  800cae:	83 ef 01             	sub    $0x1,%edi
  800cb1:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800cb5:	75 f7                	jne    800cae <vprintfmt+0x450>
  800cb7:	e9 c8 fb ff ff       	jmp    800884 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800cbc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbf:	5b                   	pop    %ebx
  800cc0:	5e                   	pop    %esi
  800cc1:	5f                   	pop    %edi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 18             	sub    $0x18,%esp
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cd3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800cd7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cda:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 26                	je     800d0b <vsnprintf+0x47>
  800ce5:	85 d2                	test   %edx,%edx
  800ce7:	7e 22                	jle    800d0b <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ce9:	ff 75 14             	pushl  0x14(%ebp)
  800cec:	ff 75 10             	pushl  0x10(%ebp)
  800cef:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cf2:	50                   	push   %eax
  800cf3:	68 24 08 80 00       	push   $0x800824
  800cf8:	e8 61 fb ff ff       	call   80085e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cfd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d00:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d03:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800d06:	83 c4 10             	add    $0x10,%esp
  800d09:	eb 05                	jmp    800d10 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800d0b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800d10:	c9                   	leave  
  800d11:	c3                   	ret    

00800d12 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d12:	55                   	push   %ebp
  800d13:	89 e5                	mov    %esp,%ebp
  800d15:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800d18:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800d1b:	50                   	push   %eax
  800d1c:	ff 75 10             	pushl  0x10(%ebp)
  800d1f:	ff 75 0c             	pushl  0xc(%ebp)
  800d22:	ff 75 08             	pushl  0x8(%ebp)
  800d25:	e8 9a ff ff ff       	call   800cc4 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d2a:	c9                   	leave  
  800d2b:	c3                   	ret    

00800d2c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d32:	b8 00 00 00 00       	mov    $0x0,%eax
  800d37:	eb 03                	jmp    800d3c <strlen+0x10>
		n++;
  800d39:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d3c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d40:	75 f7                	jne    800d39 <strlen+0xd>
		n++;
	return n;
}
  800d42:	5d                   	pop    %ebp
  800d43:	c3                   	ret    

00800d44 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d4a:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d52:	eb 03                	jmp    800d57 <strnlen+0x13>
		n++;
  800d54:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d57:	39 c2                	cmp    %eax,%edx
  800d59:	74 08                	je     800d63 <strnlen+0x1f>
  800d5b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800d5f:	75 f3                	jne    800d54 <strnlen+0x10>
  800d61:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800d63:	5d                   	pop    %ebp
  800d64:	c3                   	ret    

00800d65 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d65:	55                   	push   %ebp
  800d66:	89 e5                	mov    %esp,%ebp
  800d68:	53                   	push   %ebx
  800d69:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d6f:	89 c2                	mov    %eax,%edx
  800d71:	83 c2 01             	add    $0x1,%edx
  800d74:	83 c1 01             	add    $0x1,%ecx
  800d77:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800d7b:	88 5a ff             	mov    %bl,-0x1(%edx)
  800d7e:	84 db                	test   %bl,%bl
  800d80:	75 ef                	jne    800d71 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800d82:	5b                   	pop    %ebx
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    

00800d85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d85:	55                   	push   %ebp
  800d86:	89 e5                	mov    %esp,%ebp
  800d88:	53                   	push   %ebx
  800d89:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d8c:	53                   	push   %ebx
  800d8d:	e8 9a ff ff ff       	call   800d2c <strlen>
  800d92:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d95:	ff 75 0c             	pushl  0xc(%ebp)
  800d98:	01 d8                	add    %ebx,%eax
  800d9a:	50                   	push   %eax
  800d9b:	e8 c5 ff ff ff       	call   800d65 <strcpy>
	return dst;
}
  800da0:	89 d8                	mov    %ebx,%eax
  800da2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800da5:	c9                   	leave  
  800da6:	c3                   	ret    

00800da7 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800da7:	55                   	push   %ebp
  800da8:	89 e5                	mov    %esp,%ebp
  800daa:	56                   	push   %esi
  800dab:	53                   	push   %ebx
  800dac:	8b 75 08             	mov    0x8(%ebp),%esi
  800daf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db2:	89 f3                	mov    %esi,%ebx
  800db4:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800db7:	89 f2                	mov    %esi,%edx
  800db9:	eb 0f                	jmp    800dca <strncpy+0x23>
		*dst++ = *src;
  800dbb:	83 c2 01             	add    $0x1,%edx
  800dbe:	0f b6 01             	movzbl (%ecx),%eax
  800dc1:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800dc4:	80 39 01             	cmpb   $0x1,(%ecx)
  800dc7:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800dca:	39 da                	cmp    %ebx,%edx
  800dcc:	75 ed                	jne    800dbb <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800dce:	89 f0                	mov    %esi,%eax
  800dd0:	5b                   	pop    %ebx
  800dd1:	5e                   	pop    %esi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    

00800dd4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
  800dd9:	8b 75 08             	mov    0x8(%ebp),%esi
  800ddc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ddf:	8b 55 10             	mov    0x10(%ebp),%edx
  800de2:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800de4:	85 d2                	test   %edx,%edx
  800de6:	74 21                	je     800e09 <strlcpy+0x35>
  800de8:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800dec:	89 f2                	mov    %esi,%edx
  800dee:	eb 09                	jmp    800df9 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800df0:	83 c2 01             	add    $0x1,%edx
  800df3:	83 c1 01             	add    $0x1,%ecx
  800df6:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800df9:	39 c2                	cmp    %eax,%edx
  800dfb:	74 09                	je     800e06 <strlcpy+0x32>
  800dfd:	0f b6 19             	movzbl (%ecx),%ebx
  800e00:	84 db                	test   %bl,%bl
  800e02:	75 ec                	jne    800df0 <strlcpy+0x1c>
  800e04:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e06:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800e09:	29 f0                	sub    %esi,%eax
}
  800e0b:	5b                   	pop    %ebx
  800e0c:	5e                   	pop    %esi
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e15:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e18:	eb 06                	jmp    800e20 <strcmp+0x11>
		p++, q++;
  800e1a:	83 c1 01             	add    $0x1,%ecx
  800e1d:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e20:	0f b6 01             	movzbl (%ecx),%eax
  800e23:	84 c0                	test   %al,%al
  800e25:	74 04                	je     800e2b <strcmp+0x1c>
  800e27:	3a 02                	cmp    (%edx),%al
  800e29:	74 ef                	je     800e1a <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e2b:	0f b6 c0             	movzbl %al,%eax
  800e2e:	0f b6 12             	movzbl (%edx),%edx
  800e31:	29 d0                	sub    %edx,%eax
}
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	53                   	push   %ebx
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	89 c3                	mov    %eax,%ebx
  800e41:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e44:	eb 06                	jmp    800e4c <strncmp+0x17>
		n--, p++, q++;
  800e46:	83 c0 01             	add    $0x1,%eax
  800e49:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800e4c:	39 d8                	cmp    %ebx,%eax
  800e4e:	74 15                	je     800e65 <strncmp+0x30>
  800e50:	0f b6 08             	movzbl (%eax),%ecx
  800e53:	84 c9                	test   %cl,%cl
  800e55:	74 04                	je     800e5b <strncmp+0x26>
  800e57:	3a 0a                	cmp    (%edx),%cl
  800e59:	74 eb                	je     800e46 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e5b:	0f b6 00             	movzbl (%eax),%eax
  800e5e:	0f b6 12             	movzbl (%edx),%edx
  800e61:	29 d0                	sub    %edx,%eax
  800e63:	eb 05                	jmp    800e6a <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800e65:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800e6a:	5b                   	pop    %ebx
  800e6b:	5d                   	pop    %ebp
  800e6c:	c3                   	ret    

00800e6d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6d:	55                   	push   %ebp
  800e6e:	89 e5                	mov    %esp,%ebp
  800e70:	8b 45 08             	mov    0x8(%ebp),%eax
  800e73:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e77:	eb 07                	jmp    800e80 <strchr+0x13>
		if (*s == c)
  800e79:	38 ca                	cmp    %cl,%dl
  800e7b:	74 0f                	je     800e8c <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e7d:	83 c0 01             	add    $0x1,%eax
  800e80:	0f b6 10             	movzbl (%eax),%edx
  800e83:	84 d2                	test   %dl,%dl
  800e85:	75 f2                	jne    800e79 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800e87:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8c:	5d                   	pop    %ebp
  800e8d:	c3                   	ret    

00800e8e <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e8e:	55                   	push   %ebp
  800e8f:	89 e5                	mov    %esp,%ebp
  800e91:	8b 45 08             	mov    0x8(%ebp),%eax
  800e94:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e98:	eb 03                	jmp    800e9d <strfind+0xf>
  800e9a:	83 c0 01             	add    $0x1,%eax
  800e9d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea0:	38 ca                	cmp    %cl,%dl
  800ea2:	74 04                	je     800ea8 <strfind+0x1a>
  800ea4:	84 d2                	test   %dl,%dl
  800ea6:	75 f2                	jne    800e9a <strfind+0xc>
			break;
	return (char *) s;
}
  800ea8:	5d                   	pop    %ebp
  800ea9:	c3                   	ret    

00800eaa <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eaa:	55                   	push   %ebp
  800eab:	89 e5                	mov    %esp,%ebp
  800ead:	57                   	push   %edi
  800eae:	56                   	push   %esi
  800eaf:	53                   	push   %ebx
  800eb0:	8b 7d 08             	mov    0x8(%ebp),%edi
  800eb3:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800eb6:	85 c9                	test   %ecx,%ecx
  800eb8:	74 36                	je     800ef0 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800eba:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ec0:	75 28                	jne    800eea <memset+0x40>
  800ec2:	f6 c1 03             	test   $0x3,%cl
  800ec5:	75 23                	jne    800eea <memset+0x40>
		c &= 0xFF;
  800ec7:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ecb:	89 d3                	mov    %edx,%ebx
  800ecd:	c1 e3 08             	shl    $0x8,%ebx
  800ed0:	89 d6                	mov    %edx,%esi
  800ed2:	c1 e6 18             	shl    $0x18,%esi
  800ed5:	89 d0                	mov    %edx,%eax
  800ed7:	c1 e0 10             	shl    $0x10,%eax
  800eda:	09 f0                	or     %esi,%eax
  800edc:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800ede:	89 d8                	mov    %ebx,%eax
  800ee0:	09 d0                	or     %edx,%eax
  800ee2:	c1 e9 02             	shr    $0x2,%ecx
  800ee5:	fc                   	cld    
  800ee6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ee8:	eb 06                	jmp    800ef0 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eea:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eed:	fc                   	cld    
  800eee:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ef0:	89 f8                	mov    %edi,%eax
  800ef2:	5b                   	pop    %ebx
  800ef3:	5e                   	pop    %esi
  800ef4:	5f                   	pop    %edi
  800ef5:	5d                   	pop    %ebp
  800ef6:	c3                   	ret    

00800ef7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ef7:	55                   	push   %ebp
  800ef8:	89 e5                	mov    %esp,%ebp
  800efa:	57                   	push   %edi
  800efb:	56                   	push   %esi
  800efc:	8b 45 08             	mov    0x8(%ebp),%eax
  800eff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f05:	39 c6                	cmp    %eax,%esi
  800f07:	73 35                	jae    800f3e <memmove+0x47>
  800f09:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f0c:	39 d0                	cmp    %edx,%eax
  800f0e:	73 2e                	jae    800f3e <memmove+0x47>
		s += n;
		d += n;
  800f10:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f13:	89 d6                	mov    %edx,%esi
  800f15:	09 fe                	or     %edi,%esi
  800f17:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f1d:	75 13                	jne    800f32 <memmove+0x3b>
  800f1f:	f6 c1 03             	test   $0x3,%cl
  800f22:	75 0e                	jne    800f32 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800f24:	83 ef 04             	sub    $0x4,%edi
  800f27:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f2a:	c1 e9 02             	shr    $0x2,%ecx
  800f2d:	fd                   	std    
  800f2e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f30:	eb 09                	jmp    800f3b <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f32:	83 ef 01             	sub    $0x1,%edi
  800f35:	8d 72 ff             	lea    -0x1(%edx),%esi
  800f38:	fd                   	std    
  800f39:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f3b:	fc                   	cld    
  800f3c:	eb 1d                	jmp    800f5b <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f3e:	89 f2                	mov    %esi,%edx
  800f40:	09 c2                	or     %eax,%edx
  800f42:	f6 c2 03             	test   $0x3,%dl
  800f45:	75 0f                	jne    800f56 <memmove+0x5f>
  800f47:	f6 c1 03             	test   $0x3,%cl
  800f4a:	75 0a                	jne    800f56 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800f4c:	c1 e9 02             	shr    $0x2,%ecx
  800f4f:	89 c7                	mov    %eax,%edi
  800f51:	fc                   	cld    
  800f52:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f54:	eb 05                	jmp    800f5b <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f56:	89 c7                	mov    %eax,%edi
  800f58:	fc                   	cld    
  800f59:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f5b:	5e                   	pop    %esi
  800f5c:	5f                   	pop    %edi
  800f5d:	5d                   	pop    %ebp
  800f5e:	c3                   	ret    

00800f5f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f5f:	55                   	push   %ebp
  800f60:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800f62:	ff 75 10             	pushl  0x10(%ebp)
  800f65:	ff 75 0c             	pushl  0xc(%ebp)
  800f68:	ff 75 08             	pushl  0x8(%ebp)
  800f6b:	e8 87 ff ff ff       	call   800ef7 <memmove>
}
  800f70:	c9                   	leave  
  800f71:	c3                   	ret    

00800f72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	56                   	push   %esi
  800f76:	53                   	push   %ebx
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f7d:	89 c6                	mov    %eax,%esi
  800f7f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f82:	eb 1a                	jmp    800f9e <memcmp+0x2c>
		if (*s1 != *s2)
  800f84:	0f b6 08             	movzbl (%eax),%ecx
  800f87:	0f b6 1a             	movzbl (%edx),%ebx
  800f8a:	38 d9                	cmp    %bl,%cl
  800f8c:	74 0a                	je     800f98 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800f8e:	0f b6 c1             	movzbl %cl,%eax
  800f91:	0f b6 db             	movzbl %bl,%ebx
  800f94:	29 d8                	sub    %ebx,%eax
  800f96:	eb 0f                	jmp    800fa7 <memcmp+0x35>
		s1++, s2++;
  800f98:	83 c0 01             	add    $0x1,%eax
  800f9b:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f9e:	39 f0                	cmp    %esi,%eax
  800fa0:	75 e2                	jne    800f84 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fa7:	5b                   	pop    %ebx
  800fa8:	5e                   	pop    %esi
  800fa9:	5d                   	pop    %ebp
  800faa:	c3                   	ret    

00800fab <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fab:	55                   	push   %ebp
  800fac:	89 e5                	mov    %esp,%ebp
  800fae:	53                   	push   %ebx
  800faf:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800fb2:	89 c1                	mov    %eax,%ecx
  800fb4:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800fb7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fbb:	eb 0a                	jmp    800fc7 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fbd:	0f b6 10             	movzbl (%eax),%edx
  800fc0:	39 da                	cmp    %ebx,%edx
  800fc2:	74 07                	je     800fcb <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800fc4:	83 c0 01             	add    $0x1,%eax
  800fc7:	39 c8                	cmp    %ecx,%eax
  800fc9:	72 f2                	jb     800fbd <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800fcb:	5b                   	pop    %ebx
  800fcc:	5d                   	pop    %ebp
  800fcd:	c3                   	ret    

00800fce <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	57                   	push   %edi
  800fd2:	56                   	push   %esi
  800fd3:	53                   	push   %ebx
  800fd4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fda:	eb 03                	jmp    800fdf <strtol+0x11>
		s++;
  800fdc:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fdf:	0f b6 01             	movzbl (%ecx),%eax
  800fe2:	3c 20                	cmp    $0x20,%al
  800fe4:	74 f6                	je     800fdc <strtol+0xe>
  800fe6:	3c 09                	cmp    $0x9,%al
  800fe8:	74 f2                	je     800fdc <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800fea:	3c 2b                	cmp    $0x2b,%al
  800fec:	75 0a                	jne    800ff8 <strtol+0x2a>
		s++;
  800fee:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800ff1:	bf 00 00 00 00       	mov    $0x0,%edi
  800ff6:	eb 11                	jmp    801009 <strtol+0x3b>
  800ff8:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800ffd:	3c 2d                	cmp    $0x2d,%al
  800fff:	75 08                	jne    801009 <strtol+0x3b>
		s++, neg = 1;
  801001:	83 c1 01             	add    $0x1,%ecx
  801004:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801009:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100f:	75 15                	jne    801026 <strtol+0x58>
  801011:	80 39 30             	cmpb   $0x30,(%ecx)
  801014:	75 10                	jne    801026 <strtol+0x58>
  801016:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80101a:	75 7c                	jne    801098 <strtol+0xca>
		s += 2, base = 16;
  80101c:	83 c1 02             	add    $0x2,%ecx
  80101f:	bb 10 00 00 00       	mov    $0x10,%ebx
  801024:	eb 16                	jmp    80103c <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801026:	85 db                	test   %ebx,%ebx
  801028:	75 12                	jne    80103c <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80102a:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80102f:	80 39 30             	cmpb   $0x30,(%ecx)
  801032:	75 08                	jne    80103c <strtol+0x6e>
		s++, base = 8;
  801034:	83 c1 01             	add    $0x1,%ecx
  801037:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  80103c:	b8 00 00 00 00       	mov    $0x0,%eax
  801041:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801044:	0f b6 11             	movzbl (%ecx),%edx
  801047:	8d 72 d0             	lea    -0x30(%edx),%esi
  80104a:	89 f3                	mov    %esi,%ebx
  80104c:	80 fb 09             	cmp    $0x9,%bl
  80104f:	77 08                	ja     801059 <strtol+0x8b>
			dig = *s - '0';
  801051:	0f be d2             	movsbl %dl,%edx
  801054:	83 ea 30             	sub    $0x30,%edx
  801057:	eb 22                	jmp    80107b <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801059:	8d 72 9f             	lea    -0x61(%edx),%esi
  80105c:	89 f3                	mov    %esi,%ebx
  80105e:	80 fb 19             	cmp    $0x19,%bl
  801061:	77 08                	ja     80106b <strtol+0x9d>
			dig = *s - 'a' + 10;
  801063:	0f be d2             	movsbl %dl,%edx
  801066:	83 ea 57             	sub    $0x57,%edx
  801069:	eb 10                	jmp    80107b <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  80106b:	8d 72 bf             	lea    -0x41(%edx),%esi
  80106e:	89 f3                	mov    %esi,%ebx
  801070:	80 fb 19             	cmp    $0x19,%bl
  801073:	77 16                	ja     80108b <strtol+0xbd>
			dig = *s - 'A' + 10;
  801075:	0f be d2             	movsbl %dl,%edx
  801078:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  80107b:	3b 55 10             	cmp    0x10(%ebp),%edx
  80107e:	7d 0b                	jge    80108b <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801080:	83 c1 01             	add    $0x1,%ecx
  801083:	0f af 45 10          	imul   0x10(%ebp),%eax
  801087:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801089:	eb b9                	jmp    801044 <strtol+0x76>

	if (endptr)
  80108b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80108f:	74 0d                	je     80109e <strtol+0xd0>
		*endptr = (char *) s;
  801091:	8b 75 0c             	mov    0xc(%ebp),%esi
  801094:	89 0e                	mov    %ecx,(%esi)
  801096:	eb 06                	jmp    80109e <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801098:	85 db                	test   %ebx,%ebx
  80109a:	74 98                	je     801034 <strtol+0x66>
  80109c:	eb 9e                	jmp    80103c <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80109e:	89 c2                	mov    %eax,%edx
  8010a0:	f7 da                	neg    %edx
  8010a2:	85 ff                	test   %edi,%edi
  8010a4:	0f 45 c2             	cmovne %edx,%eax
}
  8010a7:	5b                   	pop    %ebx
  8010a8:	5e                   	pop    %esi
  8010a9:	5f                   	pop    %edi
  8010aa:	5d                   	pop    %ebp
  8010ab:	c3                   	ret    

008010ac <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8010ac:	55                   	push   %ebp
  8010ad:	89 e5                	mov    %esp,%ebp
  8010af:	57                   	push   %edi
  8010b0:	56                   	push   %esi
  8010b1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8010b7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ba:	8b 55 08             	mov    0x8(%ebp),%edx
  8010bd:	89 c3                	mov    %eax,%ebx
  8010bf:	89 c7                	mov    %eax,%edi
  8010c1:	89 c6                	mov    %eax,%esi
  8010c3:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8010c5:	5b                   	pop    %ebx
  8010c6:	5e                   	pop    %esi
  8010c7:	5f                   	pop    %edi
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <sys_cgetc>:

int
sys_cgetc(void)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	57                   	push   %edi
  8010ce:	56                   	push   %esi
  8010cf:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8010d5:	b8 01 00 00 00       	mov    $0x1,%eax
  8010da:	89 d1                	mov    %edx,%ecx
  8010dc:	89 d3                	mov    %edx,%ebx
  8010de:	89 d7                	mov    %edx,%edi
  8010e0:	89 d6                	mov    %edx,%esi
  8010e2:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8010f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8010fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ff:	89 cb                	mov    %ecx,%ebx
  801101:	89 cf                	mov    %ecx,%edi
  801103:	89 ce                	mov    %ecx,%esi
  801105:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801107:	85 c0                	test   %eax,%eax
  801109:	7e 17                	jle    801122 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80110b:	83 ec 0c             	sub    $0xc,%esp
  80110e:	50                   	push   %eax
  80110f:	6a 03                	push   $0x3
  801111:	68 bf 2f 80 00       	push   $0x802fbf
  801116:	6a 23                	push   $0x23
  801118:	68 dc 2f 80 00       	push   $0x802fdc
  80111d:	e8 66 f5 ff ff       	call   800688 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801122:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801125:	5b                   	pop    %ebx
  801126:	5e                   	pop    %esi
  801127:	5f                   	pop    %edi
  801128:	5d                   	pop    %ebp
  801129:	c3                   	ret    

0080112a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80112a:	55                   	push   %ebp
  80112b:	89 e5                	mov    %esp,%ebp
  80112d:	57                   	push   %edi
  80112e:	56                   	push   %esi
  80112f:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801130:	ba 00 00 00 00       	mov    $0x0,%edx
  801135:	b8 02 00 00 00       	mov    $0x2,%eax
  80113a:	89 d1                	mov    %edx,%ecx
  80113c:	89 d3                	mov    %edx,%ebx
  80113e:	89 d7                	mov    %edx,%edi
  801140:	89 d6                	mov    %edx,%esi
  801142:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801144:	5b                   	pop    %ebx
  801145:	5e                   	pop    %esi
  801146:	5f                   	pop    %edi
  801147:	5d                   	pop    %ebp
  801148:	c3                   	ret    

00801149 <sys_yield>:

void
sys_yield(void)
{
  801149:	55                   	push   %ebp
  80114a:	89 e5                	mov    %esp,%ebp
  80114c:	57                   	push   %edi
  80114d:	56                   	push   %esi
  80114e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80114f:	ba 00 00 00 00       	mov    $0x0,%edx
  801154:	b8 0b 00 00 00       	mov    $0xb,%eax
  801159:	89 d1                	mov    %edx,%ecx
  80115b:	89 d3                	mov    %edx,%ebx
  80115d:	89 d7                	mov    %edx,%edi
  80115f:	89 d6                	mov    %edx,%esi
  801161:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801163:	5b                   	pop    %ebx
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    

00801168 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801168:	55                   	push   %ebp
  801169:	89 e5                	mov    %esp,%ebp
  80116b:	57                   	push   %edi
  80116c:	56                   	push   %esi
  80116d:	53                   	push   %ebx
  80116e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801171:	be 00 00 00 00       	mov    $0x0,%esi
  801176:	b8 04 00 00 00       	mov    $0x4,%eax
  80117b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80117e:	8b 55 08             	mov    0x8(%ebp),%edx
  801181:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801184:	89 f7                	mov    %esi,%edi
  801186:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	7e 17                	jle    8011a3 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80118c:	83 ec 0c             	sub    $0xc,%esp
  80118f:	50                   	push   %eax
  801190:	6a 04                	push   $0x4
  801192:	68 bf 2f 80 00       	push   $0x802fbf
  801197:	6a 23                	push   $0x23
  801199:	68 dc 2f 80 00       	push   $0x802fdc
  80119e:	e8 e5 f4 ff ff       	call   800688 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8011a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011a6:	5b                   	pop    %ebx
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    

008011ab <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011ab:	55                   	push   %ebp
  8011ac:	89 e5                	mov    %esp,%ebp
  8011ae:	57                   	push   %edi
  8011af:	56                   	push   %esi
  8011b0:	53                   	push   %ebx
  8011b1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8011b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8011bf:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8011c2:	8b 7d 14             	mov    0x14(%ebp),%edi
  8011c5:	8b 75 18             	mov    0x18(%ebp),%esi
  8011c8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ca:	85 c0                	test   %eax,%eax
  8011cc:	7e 17                	jle    8011e5 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ce:	83 ec 0c             	sub    $0xc,%esp
  8011d1:	50                   	push   %eax
  8011d2:	6a 05                	push   $0x5
  8011d4:	68 bf 2f 80 00       	push   $0x802fbf
  8011d9:	6a 23                	push   $0x23
  8011db:	68 dc 2f 80 00       	push   $0x802fdc
  8011e0:	e8 a3 f4 ff ff       	call   800688 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8011e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e8:	5b                   	pop    %ebx
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    

008011ed <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8011ed:	55                   	push   %ebp
  8011ee:	89 e5                	mov    %esp,%ebp
  8011f0:	57                   	push   %edi
  8011f1:	56                   	push   %esi
  8011f2:	53                   	push   %ebx
  8011f3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011f6:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fb:	b8 06 00 00 00       	mov    $0x6,%eax
  801200:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801203:	8b 55 08             	mov    0x8(%ebp),%edx
  801206:	89 df                	mov    %ebx,%edi
  801208:	89 de                	mov    %ebx,%esi
  80120a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80120c:	85 c0                	test   %eax,%eax
  80120e:	7e 17                	jle    801227 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801210:	83 ec 0c             	sub    $0xc,%esp
  801213:	50                   	push   %eax
  801214:	6a 06                	push   $0x6
  801216:	68 bf 2f 80 00       	push   $0x802fbf
  80121b:	6a 23                	push   $0x23
  80121d:	68 dc 2f 80 00       	push   $0x802fdc
  801222:	e8 61 f4 ff ff       	call   800688 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801227:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80122a:	5b                   	pop    %ebx
  80122b:	5e                   	pop    %esi
  80122c:	5f                   	pop    %edi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    

0080122f <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80122f:	55                   	push   %ebp
  801230:	89 e5                	mov    %esp,%ebp
  801232:	57                   	push   %edi
  801233:	56                   	push   %esi
  801234:	53                   	push   %ebx
  801235:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801238:	bb 00 00 00 00       	mov    $0x0,%ebx
  80123d:	b8 08 00 00 00       	mov    $0x8,%eax
  801242:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801245:	8b 55 08             	mov    0x8(%ebp),%edx
  801248:	89 df                	mov    %ebx,%edi
  80124a:	89 de                	mov    %ebx,%esi
  80124c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80124e:	85 c0                	test   %eax,%eax
  801250:	7e 17                	jle    801269 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801252:	83 ec 0c             	sub    $0xc,%esp
  801255:	50                   	push   %eax
  801256:	6a 08                	push   $0x8
  801258:	68 bf 2f 80 00       	push   $0x802fbf
  80125d:	6a 23                	push   $0x23
  80125f:	68 dc 2f 80 00       	push   $0x802fdc
  801264:	e8 1f f4 ff ff       	call   800688 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801269:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80126c:	5b                   	pop    %ebx
  80126d:	5e                   	pop    %esi
  80126e:	5f                   	pop    %edi
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801271:	55                   	push   %ebp
  801272:	89 e5                	mov    %esp,%ebp
  801274:	57                   	push   %edi
  801275:	56                   	push   %esi
  801276:	53                   	push   %ebx
  801277:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127f:	b8 09 00 00 00       	mov    $0x9,%eax
  801284:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801287:	8b 55 08             	mov    0x8(%ebp),%edx
  80128a:	89 df                	mov    %ebx,%edi
  80128c:	89 de                	mov    %ebx,%esi
  80128e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801290:	85 c0                	test   %eax,%eax
  801292:	7e 17                	jle    8012ab <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801294:	83 ec 0c             	sub    $0xc,%esp
  801297:	50                   	push   %eax
  801298:	6a 09                	push   $0x9
  80129a:	68 bf 2f 80 00       	push   $0x802fbf
  80129f:	6a 23                	push   $0x23
  8012a1:	68 dc 2f 80 00       	push   $0x802fdc
  8012a6:	e8 dd f3 ff ff       	call   800688 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8012ab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012ae:	5b                   	pop    %ebx
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    

008012b3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012b3:	55                   	push   %ebp
  8012b4:	89 e5                	mov    %esp,%ebp
  8012b6:	57                   	push   %edi
  8012b7:	56                   	push   %esi
  8012b8:	53                   	push   %ebx
  8012b9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c9:	8b 55 08             	mov    0x8(%ebp),%edx
  8012cc:	89 df                	mov    %ebx,%edi
  8012ce:	89 de                	mov    %ebx,%esi
  8012d0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012d2:	85 c0                	test   %eax,%eax
  8012d4:	7e 17                	jle    8012ed <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012d6:	83 ec 0c             	sub    $0xc,%esp
  8012d9:	50                   	push   %eax
  8012da:	6a 0a                	push   $0xa
  8012dc:	68 bf 2f 80 00       	push   $0x802fbf
  8012e1:	6a 23                	push   $0x23
  8012e3:	68 dc 2f 80 00       	push   $0x802fdc
  8012e8:	e8 9b f3 ff ff       	call   800688 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012f0:	5b                   	pop    %ebx
  8012f1:	5e                   	pop    %esi
  8012f2:	5f                   	pop    %edi
  8012f3:	5d                   	pop    %ebp
  8012f4:	c3                   	ret    

008012f5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012f5:	55                   	push   %ebp
  8012f6:	89 e5                	mov    %esp,%ebp
  8012f8:	57                   	push   %edi
  8012f9:	56                   	push   %esi
  8012fa:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012fb:	be 00 00 00 00       	mov    $0x0,%esi
  801300:	b8 0c 00 00 00       	mov    $0xc,%eax
  801305:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801308:	8b 55 08             	mov    0x8(%ebp),%edx
  80130b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80130e:	8b 7d 14             	mov    0x14(%ebp),%edi
  801311:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801313:	5b                   	pop    %ebx
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    

00801318 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801318:	55                   	push   %ebp
  801319:	89 e5                	mov    %esp,%ebp
  80131b:	57                   	push   %edi
  80131c:	56                   	push   %esi
  80131d:	53                   	push   %ebx
  80131e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801321:	b9 00 00 00 00       	mov    $0x0,%ecx
  801326:	b8 0d 00 00 00       	mov    $0xd,%eax
  80132b:	8b 55 08             	mov    0x8(%ebp),%edx
  80132e:	89 cb                	mov    %ecx,%ebx
  801330:	89 cf                	mov    %ecx,%edi
  801332:	89 ce                	mov    %ecx,%esi
  801334:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801336:	85 c0                	test   %eax,%eax
  801338:	7e 17                	jle    801351 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80133a:	83 ec 0c             	sub    $0xc,%esp
  80133d:	50                   	push   %eax
  80133e:	6a 0d                	push   $0xd
  801340:	68 bf 2f 80 00       	push   $0x802fbf
  801345:	6a 23                	push   $0x23
  801347:	68 dc 2f 80 00       	push   $0x802fdc
  80134c:	e8 37 f3 ff ff       	call   800688 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801351:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801354:	5b                   	pop    %ebx
  801355:	5e                   	pop    %esi
  801356:	5f                   	pop    %edi
  801357:	5d                   	pop    %ebp
  801358:	c3                   	ret    

00801359 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	57                   	push   %edi
  80135d:	56                   	push   %esi
  80135e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80135f:	ba 00 00 00 00       	mov    $0x0,%edx
  801364:	b8 0e 00 00 00       	mov    $0xe,%eax
  801369:	89 d1                	mov    %edx,%ecx
  80136b:	89 d3                	mov    %edx,%ebx
  80136d:	89 d7                	mov    %edx,%edi
  80136f:	89 d6                	mov    %edx,%esi
  801371:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  801373:	5b                   	pop    %ebx
  801374:	5e                   	pop    %esi
  801375:	5f                   	pop    %edi
  801376:	5d                   	pop    %ebp
  801377:	c3                   	ret    

00801378 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  801378:	55                   	push   %ebp
  801379:	89 e5                	mov    %esp,%ebp
  80137b:	57                   	push   %edi
  80137c:	56                   	push   %esi
  80137d:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80137e:	b9 00 00 00 00       	mov    $0x0,%ecx
  801383:	b8 10 00 00 00       	mov    $0x10,%eax
  801388:	8b 55 08             	mov    0x8(%ebp),%edx
  80138b:	89 cb                	mov    %ecx,%ebx
  80138d:	89 cf                	mov    %ecx,%edi
  80138f:	89 ce                	mov    %ecx,%esi
  801391:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  801393:	5b                   	pop    %ebx
  801394:	5e                   	pop    %esi
  801395:	5f                   	pop    %edi
  801396:	5d                   	pop    %ebp
  801397:	c3                   	ret    

00801398 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801398:	55                   	push   %ebp
  801399:	89 e5                	mov    %esp,%ebp
  80139b:	56                   	push   %esi
  80139c:	53                   	push   %ebx
  80139d:	8b 75 08             	mov    0x8(%ebp),%esi
  8013a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013a3:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8013a6:	85 c0                	test   %eax,%eax
  8013a8:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8013ad:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8013b0:	83 ec 0c             	sub    $0xc,%esp
  8013b3:	50                   	push   %eax
  8013b4:	e8 5f ff ff ff       	call   801318 <sys_ipc_recv>
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	85 c0                	test   %eax,%eax
  8013be:	79 16                	jns    8013d6 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  8013c0:	85 f6                	test   %esi,%esi
  8013c2:	74 06                	je     8013ca <ipc_recv+0x32>
            *from_env_store = 0;
  8013c4:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  8013ca:	85 db                	test   %ebx,%ebx
  8013cc:	74 2c                	je     8013fa <ipc_recv+0x62>
            *perm_store = 0;
  8013ce:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8013d4:	eb 24                	jmp    8013fa <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  8013d6:	85 f6                	test   %esi,%esi
  8013d8:	74 0a                	je     8013e4 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  8013da:	a1 08 50 80 00       	mov    0x805008,%eax
  8013df:	8b 40 74             	mov    0x74(%eax),%eax
  8013e2:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  8013e4:	85 db                	test   %ebx,%ebx
  8013e6:	74 0a                	je     8013f2 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  8013e8:	a1 08 50 80 00       	mov    0x805008,%eax
  8013ed:	8b 40 78             	mov    0x78(%eax),%eax
  8013f0:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  8013f2:	a1 08 50 80 00       	mov    0x805008,%eax
  8013f7:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8013fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5d                   	pop    %ebp
  801400:	c3                   	ret    

00801401 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801401:	55                   	push   %ebp
  801402:	89 e5                	mov    %esp,%ebp
  801404:	57                   	push   %edi
  801405:	56                   	push   %esi
  801406:	53                   	push   %ebx
  801407:	83 ec 0c             	sub    $0xc,%esp
  80140a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80140d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801410:	8b 45 10             	mov    0x10(%ebp),%eax
  801413:	85 c0                	test   %eax,%eax
  801415:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  80141a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80141d:	eb 1c                	jmp    80143b <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  80141f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801422:	74 12                	je     801436 <ipc_send+0x35>
  801424:	50                   	push   %eax
  801425:	68 ea 2f 80 00       	push   $0x802fea
  80142a:	6a 3b                	push   $0x3b
  80142c:	68 00 30 80 00       	push   $0x803000
  801431:	e8 52 f2 ff ff       	call   800688 <_panic>
		sys_yield();
  801436:	e8 0e fd ff ff       	call   801149 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  80143b:	ff 75 14             	pushl  0x14(%ebp)
  80143e:	53                   	push   %ebx
  80143f:	56                   	push   %esi
  801440:	57                   	push   %edi
  801441:	e8 af fe ff ff       	call   8012f5 <sys_ipc_try_send>
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 d2                	js     80141f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  80144d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801450:	5b                   	pop    %ebx
  801451:	5e                   	pop    %esi
  801452:	5f                   	pop    %edi
  801453:	5d                   	pop    %ebp
  801454:	c3                   	ret    

00801455 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801455:	55                   	push   %ebp
  801456:	89 e5                	mov    %esp,%ebp
  801458:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80145b:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801460:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801463:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801469:	8b 52 50             	mov    0x50(%edx),%edx
  80146c:	39 ca                	cmp    %ecx,%edx
  80146e:	75 0d                	jne    80147d <ipc_find_env+0x28>
			return envs[i].env_id;
  801470:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801473:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801478:	8b 40 48             	mov    0x48(%eax),%eax
  80147b:	eb 0f                	jmp    80148c <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80147d:	83 c0 01             	add    $0x1,%eax
  801480:	3d 00 04 00 00       	cmp    $0x400,%eax
  801485:	75 d9                	jne    801460 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801487:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148c:	5d                   	pop    %ebp
  80148d:	c3                   	ret    

0080148e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80148e:	55                   	push   %ebp
  80148f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801491:	8b 45 08             	mov    0x8(%ebp),%eax
  801494:	05 00 00 00 30       	add    $0x30000000,%eax
  801499:	c1 e8 0c             	shr    $0xc,%eax
}
  80149c:	5d                   	pop    %ebp
  80149d:	c3                   	ret    

0080149e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80149e:	55                   	push   %ebp
  80149f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8014a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8014a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8014ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014b3:	5d                   	pop    %ebp
  8014b4:	c3                   	ret    

008014b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014b5:	55                   	push   %ebp
  8014b6:	89 e5                	mov    %esp,%ebp
  8014b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014c0:	89 c2                	mov    %eax,%edx
  8014c2:	c1 ea 16             	shr    $0x16,%edx
  8014c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014cc:	f6 c2 01             	test   $0x1,%dl
  8014cf:	74 11                	je     8014e2 <fd_alloc+0x2d>
  8014d1:	89 c2                	mov    %eax,%edx
  8014d3:	c1 ea 0c             	shr    $0xc,%edx
  8014d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014dd:	f6 c2 01             	test   $0x1,%dl
  8014e0:	75 09                	jne    8014eb <fd_alloc+0x36>
			*fd_store = fd;
  8014e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8014e9:	eb 17                	jmp    801502 <fd_alloc+0x4d>
  8014eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8014f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014f5:	75 c9                	jne    8014c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8014fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801502:	5d                   	pop    %ebp
  801503:	c3                   	ret    

00801504 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801504:	55                   	push   %ebp
  801505:	89 e5                	mov    %esp,%ebp
  801507:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80150a:	83 f8 1f             	cmp    $0x1f,%eax
  80150d:	77 36                	ja     801545 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80150f:	c1 e0 0c             	shl    $0xc,%eax
  801512:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801517:	89 c2                	mov    %eax,%edx
  801519:	c1 ea 16             	shr    $0x16,%edx
  80151c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801523:	f6 c2 01             	test   $0x1,%dl
  801526:	74 24                	je     80154c <fd_lookup+0x48>
  801528:	89 c2                	mov    %eax,%edx
  80152a:	c1 ea 0c             	shr    $0xc,%edx
  80152d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801534:	f6 c2 01             	test   $0x1,%dl
  801537:	74 1a                	je     801553 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801539:	8b 55 0c             	mov    0xc(%ebp),%edx
  80153c:	89 02                	mov    %eax,(%edx)
	return 0;
  80153e:	b8 00 00 00 00       	mov    $0x0,%eax
  801543:	eb 13                	jmp    801558 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801545:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80154a:	eb 0c                	jmp    801558 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80154c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801551:	eb 05                	jmp    801558 <fd_lookup+0x54>
  801553:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801558:	5d                   	pop    %ebp
  801559:	c3                   	ret    

0080155a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80155a:	55                   	push   %ebp
  80155b:	89 e5                	mov    %esp,%ebp
  80155d:	83 ec 08             	sub    $0x8,%esp
  801560:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801563:	ba 8c 30 80 00       	mov    $0x80308c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801568:	eb 13                	jmp    80157d <dev_lookup+0x23>
  80156a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80156d:	39 08                	cmp    %ecx,(%eax)
  80156f:	75 0c                	jne    80157d <dev_lookup+0x23>
			*dev = devtab[i];
  801571:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801574:	89 01                	mov    %eax,(%ecx)
			return 0;
  801576:	b8 00 00 00 00       	mov    $0x0,%eax
  80157b:	eb 2e                	jmp    8015ab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80157d:	8b 02                	mov    (%edx),%eax
  80157f:	85 c0                	test   %eax,%eax
  801581:	75 e7                	jne    80156a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801583:	a1 08 50 80 00       	mov    0x805008,%eax
  801588:	8b 40 48             	mov    0x48(%eax),%eax
  80158b:	83 ec 04             	sub    $0x4,%esp
  80158e:	51                   	push   %ecx
  80158f:	50                   	push   %eax
  801590:	68 0c 30 80 00       	push   $0x80300c
  801595:	e8 c7 f1 ff ff       	call   800761 <cprintf>
	*dev = 0;
  80159a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015a3:	83 c4 10             	add    $0x10,%esp
  8015a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015ab:	c9                   	leave  
  8015ac:	c3                   	ret    

008015ad <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8015ad:	55                   	push   %ebp
  8015ae:	89 e5                	mov    %esp,%ebp
  8015b0:	56                   	push   %esi
  8015b1:	53                   	push   %ebx
  8015b2:	83 ec 10             	sub    $0x10,%esp
  8015b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8015b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8015c5:	c1 e8 0c             	shr    $0xc,%eax
  8015c8:	50                   	push   %eax
  8015c9:	e8 36 ff ff ff       	call   801504 <fd_lookup>
  8015ce:	83 c4 08             	add    $0x8,%esp
  8015d1:	85 c0                	test   %eax,%eax
  8015d3:	78 05                	js     8015da <fd_close+0x2d>
	    || fd != fd2)
  8015d5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8015d8:	74 0c                	je     8015e6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8015da:	84 db                	test   %bl,%bl
  8015dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8015e1:	0f 44 c2             	cmove  %edx,%eax
  8015e4:	eb 41                	jmp    801627 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015e6:	83 ec 08             	sub    $0x8,%esp
  8015e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015ec:	50                   	push   %eax
  8015ed:	ff 36                	pushl  (%esi)
  8015ef:	e8 66 ff ff ff       	call   80155a <dev_lookup>
  8015f4:	89 c3                	mov    %eax,%ebx
  8015f6:	83 c4 10             	add    $0x10,%esp
  8015f9:	85 c0                	test   %eax,%eax
  8015fb:	78 1a                	js     801617 <fd_close+0x6a>
		if (dev->dev_close)
  8015fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801600:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801603:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801608:	85 c0                	test   %eax,%eax
  80160a:	74 0b                	je     801617 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80160c:	83 ec 0c             	sub    $0xc,%esp
  80160f:	56                   	push   %esi
  801610:	ff d0                	call   *%eax
  801612:	89 c3                	mov    %eax,%ebx
  801614:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801617:	83 ec 08             	sub    $0x8,%esp
  80161a:	56                   	push   %esi
  80161b:	6a 00                	push   $0x0
  80161d:	e8 cb fb ff ff       	call   8011ed <sys_page_unmap>
	return r;
  801622:	83 c4 10             	add    $0x10,%esp
  801625:	89 d8                	mov    %ebx,%eax
}
  801627:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80162a:	5b                   	pop    %ebx
  80162b:	5e                   	pop    %esi
  80162c:	5d                   	pop    %ebp
  80162d:	c3                   	ret    

0080162e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80162e:	55                   	push   %ebp
  80162f:	89 e5                	mov    %esp,%ebp
  801631:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801634:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801637:	50                   	push   %eax
  801638:	ff 75 08             	pushl  0x8(%ebp)
  80163b:	e8 c4 fe ff ff       	call   801504 <fd_lookup>
  801640:	83 c4 08             	add    $0x8,%esp
  801643:	85 c0                	test   %eax,%eax
  801645:	78 10                	js     801657 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801647:	83 ec 08             	sub    $0x8,%esp
  80164a:	6a 01                	push   $0x1
  80164c:	ff 75 f4             	pushl  -0xc(%ebp)
  80164f:	e8 59 ff ff ff       	call   8015ad <fd_close>
  801654:	83 c4 10             	add    $0x10,%esp
}
  801657:	c9                   	leave  
  801658:	c3                   	ret    

00801659 <close_all>:

void
close_all(void)
{
  801659:	55                   	push   %ebp
  80165a:	89 e5                	mov    %esp,%ebp
  80165c:	53                   	push   %ebx
  80165d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801660:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801665:	83 ec 0c             	sub    $0xc,%esp
  801668:	53                   	push   %ebx
  801669:	e8 c0 ff ff ff       	call   80162e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80166e:	83 c3 01             	add    $0x1,%ebx
  801671:	83 c4 10             	add    $0x10,%esp
  801674:	83 fb 20             	cmp    $0x20,%ebx
  801677:	75 ec                	jne    801665 <close_all+0xc>
		close(i);
}
  801679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80167c:	c9                   	leave  
  80167d:	c3                   	ret    

0080167e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80167e:	55                   	push   %ebp
  80167f:	89 e5                	mov    %esp,%ebp
  801681:	57                   	push   %edi
  801682:	56                   	push   %esi
  801683:	53                   	push   %ebx
  801684:	83 ec 2c             	sub    $0x2c,%esp
  801687:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80168a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	ff 75 08             	pushl  0x8(%ebp)
  801691:	e8 6e fe ff ff       	call   801504 <fd_lookup>
  801696:	83 c4 08             	add    $0x8,%esp
  801699:	85 c0                	test   %eax,%eax
  80169b:	0f 88 c1 00 00 00    	js     801762 <dup+0xe4>
		return r;
	close(newfdnum);
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	56                   	push   %esi
  8016a5:	e8 84 ff ff ff       	call   80162e <close>

	newfd = INDEX2FD(newfdnum);
  8016aa:	89 f3                	mov    %esi,%ebx
  8016ac:	c1 e3 0c             	shl    $0xc,%ebx
  8016af:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8016b5:	83 c4 04             	add    $0x4,%esp
  8016b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016bb:	e8 de fd ff ff       	call   80149e <fd2data>
  8016c0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8016c2:	89 1c 24             	mov    %ebx,(%esp)
  8016c5:	e8 d4 fd ff ff       	call   80149e <fd2data>
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016d0:	89 f8                	mov    %edi,%eax
  8016d2:	c1 e8 16             	shr    $0x16,%eax
  8016d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016dc:	a8 01                	test   $0x1,%al
  8016de:	74 37                	je     801717 <dup+0x99>
  8016e0:	89 f8                	mov    %edi,%eax
  8016e2:	c1 e8 0c             	shr    $0xc,%eax
  8016e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ec:	f6 c2 01             	test   $0x1,%dl
  8016ef:	74 26                	je     801717 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016f8:	83 ec 0c             	sub    $0xc,%esp
  8016fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801700:	50                   	push   %eax
  801701:	ff 75 d4             	pushl  -0x2c(%ebp)
  801704:	6a 00                	push   $0x0
  801706:	57                   	push   %edi
  801707:	6a 00                	push   $0x0
  801709:	e8 9d fa ff ff       	call   8011ab <sys_page_map>
  80170e:	89 c7                	mov    %eax,%edi
  801710:	83 c4 20             	add    $0x20,%esp
  801713:	85 c0                	test   %eax,%eax
  801715:	78 2e                	js     801745 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801717:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80171a:	89 d0                	mov    %edx,%eax
  80171c:	c1 e8 0c             	shr    $0xc,%eax
  80171f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801726:	83 ec 0c             	sub    $0xc,%esp
  801729:	25 07 0e 00 00       	and    $0xe07,%eax
  80172e:	50                   	push   %eax
  80172f:	53                   	push   %ebx
  801730:	6a 00                	push   $0x0
  801732:	52                   	push   %edx
  801733:	6a 00                	push   $0x0
  801735:	e8 71 fa ff ff       	call   8011ab <sys_page_map>
  80173a:	89 c7                	mov    %eax,%edi
  80173c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80173f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801741:	85 ff                	test   %edi,%edi
  801743:	79 1d                	jns    801762 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801745:	83 ec 08             	sub    $0x8,%esp
  801748:	53                   	push   %ebx
  801749:	6a 00                	push   $0x0
  80174b:	e8 9d fa ff ff       	call   8011ed <sys_page_unmap>
	sys_page_unmap(0, nva);
  801750:	83 c4 08             	add    $0x8,%esp
  801753:	ff 75 d4             	pushl  -0x2c(%ebp)
  801756:	6a 00                	push   $0x0
  801758:	e8 90 fa ff ff       	call   8011ed <sys_page_unmap>
	return r;
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	89 f8                	mov    %edi,%eax
}
  801762:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5f                   	pop    %edi
  801768:	5d                   	pop    %ebp
  801769:	c3                   	ret    

0080176a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80176a:	55                   	push   %ebp
  80176b:	89 e5                	mov    %esp,%ebp
  80176d:	53                   	push   %ebx
  80176e:	83 ec 14             	sub    $0x14,%esp
  801771:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801774:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801777:	50                   	push   %eax
  801778:	53                   	push   %ebx
  801779:	e8 86 fd ff ff       	call   801504 <fd_lookup>
  80177e:	83 c4 08             	add    $0x8,%esp
  801781:	89 c2                	mov    %eax,%edx
  801783:	85 c0                	test   %eax,%eax
  801785:	78 6d                	js     8017f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801787:	83 ec 08             	sub    $0x8,%esp
  80178a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80178d:	50                   	push   %eax
  80178e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801791:	ff 30                	pushl  (%eax)
  801793:	e8 c2 fd ff ff       	call   80155a <dev_lookup>
  801798:	83 c4 10             	add    $0x10,%esp
  80179b:	85 c0                	test   %eax,%eax
  80179d:	78 4c                	js     8017eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80179f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017a2:	8b 42 08             	mov    0x8(%edx),%eax
  8017a5:	83 e0 03             	and    $0x3,%eax
  8017a8:	83 f8 01             	cmp    $0x1,%eax
  8017ab:	75 21                	jne    8017ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ad:	a1 08 50 80 00       	mov    0x805008,%eax
  8017b2:	8b 40 48             	mov    0x48(%eax),%eax
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	53                   	push   %ebx
  8017b9:	50                   	push   %eax
  8017ba:	68 50 30 80 00       	push   $0x803050
  8017bf:	e8 9d ef ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  8017c4:	83 c4 10             	add    $0x10,%esp
  8017c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017cc:	eb 26                	jmp    8017f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8017ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017d1:	8b 40 08             	mov    0x8(%eax),%eax
  8017d4:	85 c0                	test   %eax,%eax
  8017d6:	74 17                	je     8017ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017d8:	83 ec 04             	sub    $0x4,%esp
  8017db:	ff 75 10             	pushl  0x10(%ebp)
  8017de:	ff 75 0c             	pushl  0xc(%ebp)
  8017e1:	52                   	push   %edx
  8017e2:	ff d0                	call   *%eax
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	eb 09                	jmp    8017f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017eb:	89 c2                	mov    %eax,%edx
  8017ed:	eb 05                	jmp    8017f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8017ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8017f4:	89 d0                	mov    %edx,%eax
  8017f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f9:	c9                   	leave  
  8017fa:	c3                   	ret    

008017fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017fb:	55                   	push   %ebp
  8017fc:	89 e5                	mov    %esp,%ebp
  8017fe:	57                   	push   %edi
  8017ff:	56                   	push   %esi
  801800:	53                   	push   %ebx
  801801:	83 ec 0c             	sub    $0xc,%esp
  801804:	8b 7d 08             	mov    0x8(%ebp),%edi
  801807:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80180a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80180f:	eb 21                	jmp    801832 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801811:	83 ec 04             	sub    $0x4,%esp
  801814:	89 f0                	mov    %esi,%eax
  801816:	29 d8                	sub    %ebx,%eax
  801818:	50                   	push   %eax
  801819:	89 d8                	mov    %ebx,%eax
  80181b:	03 45 0c             	add    0xc(%ebp),%eax
  80181e:	50                   	push   %eax
  80181f:	57                   	push   %edi
  801820:	e8 45 ff ff ff       	call   80176a <read>
		if (m < 0)
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	85 c0                	test   %eax,%eax
  80182a:	78 10                	js     80183c <readn+0x41>
			return m;
		if (m == 0)
  80182c:	85 c0                	test   %eax,%eax
  80182e:	74 0a                	je     80183a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801830:	01 c3                	add    %eax,%ebx
  801832:	39 f3                	cmp    %esi,%ebx
  801834:	72 db                	jb     801811 <readn+0x16>
  801836:	89 d8                	mov    %ebx,%eax
  801838:	eb 02                	jmp    80183c <readn+0x41>
  80183a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80183c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80183f:	5b                   	pop    %ebx
  801840:	5e                   	pop    %esi
  801841:	5f                   	pop    %edi
  801842:	5d                   	pop    %ebp
  801843:	c3                   	ret    

00801844 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801844:	55                   	push   %ebp
  801845:	89 e5                	mov    %esp,%ebp
  801847:	53                   	push   %ebx
  801848:	83 ec 14             	sub    $0x14,%esp
  80184b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80184e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801851:	50                   	push   %eax
  801852:	53                   	push   %ebx
  801853:	e8 ac fc ff ff       	call   801504 <fd_lookup>
  801858:	83 c4 08             	add    $0x8,%esp
  80185b:	89 c2                	mov    %eax,%edx
  80185d:	85 c0                	test   %eax,%eax
  80185f:	78 68                	js     8018c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801867:	50                   	push   %eax
  801868:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80186b:	ff 30                	pushl  (%eax)
  80186d:	e8 e8 fc ff ff       	call   80155a <dev_lookup>
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	85 c0                	test   %eax,%eax
  801877:	78 47                	js     8018c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801879:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80187c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801880:	75 21                	jne    8018a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801882:	a1 08 50 80 00       	mov    0x805008,%eax
  801887:	8b 40 48             	mov    0x48(%eax),%eax
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	53                   	push   %ebx
  80188e:	50                   	push   %eax
  80188f:	68 6c 30 80 00       	push   $0x80306c
  801894:	e8 c8 ee ff ff       	call   800761 <cprintf>
		return -E_INVAL;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8018a1:	eb 26                	jmp    8018c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8018a9:	85 d2                	test   %edx,%edx
  8018ab:	74 17                	je     8018c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018ad:	83 ec 04             	sub    $0x4,%esp
  8018b0:	ff 75 10             	pushl  0x10(%ebp)
  8018b3:	ff 75 0c             	pushl  0xc(%ebp)
  8018b6:	50                   	push   %eax
  8018b7:	ff d2                	call   *%edx
  8018b9:	89 c2                	mov    %eax,%edx
  8018bb:	83 c4 10             	add    $0x10,%esp
  8018be:	eb 09                	jmp    8018c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	eb 05                	jmp    8018c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8018c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8018c9:	89 d0                	mov    %edx,%eax
  8018cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ce:	c9                   	leave  
  8018cf:	c3                   	ret    

008018d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8018d9:	50                   	push   %eax
  8018da:	ff 75 08             	pushl  0x8(%ebp)
  8018dd:	e8 22 fc ff ff       	call   801504 <fd_lookup>
  8018e2:	83 c4 08             	add    $0x8,%esp
  8018e5:	85 c0                	test   %eax,%eax
  8018e7:	78 0e                	js     8018f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8018e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8018ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018f7:	c9                   	leave  
  8018f8:	c3                   	ret    

008018f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018f9:	55                   	push   %ebp
  8018fa:	89 e5                	mov    %esp,%ebp
  8018fc:	53                   	push   %ebx
  8018fd:	83 ec 14             	sub    $0x14,%esp
  801900:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801903:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801906:	50                   	push   %eax
  801907:	53                   	push   %ebx
  801908:	e8 f7 fb ff ff       	call   801504 <fd_lookup>
  80190d:	83 c4 08             	add    $0x8,%esp
  801910:	89 c2                	mov    %eax,%edx
  801912:	85 c0                	test   %eax,%eax
  801914:	78 65                	js     80197b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80191c:	50                   	push   %eax
  80191d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801920:	ff 30                	pushl  (%eax)
  801922:	e8 33 fc ff ff       	call   80155a <dev_lookup>
  801927:	83 c4 10             	add    $0x10,%esp
  80192a:	85 c0                	test   %eax,%eax
  80192c:	78 44                	js     801972 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80192e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801931:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801935:	75 21                	jne    801958 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801937:	a1 08 50 80 00       	mov    0x805008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80193c:	8b 40 48             	mov    0x48(%eax),%eax
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	53                   	push   %ebx
  801943:	50                   	push   %eax
  801944:	68 2c 30 80 00       	push   $0x80302c
  801949:	e8 13 ee ff ff       	call   800761 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801956:	eb 23                	jmp    80197b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801958:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80195b:	8b 52 18             	mov    0x18(%edx),%edx
  80195e:	85 d2                	test   %edx,%edx
  801960:	74 14                	je     801976 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801962:	83 ec 08             	sub    $0x8,%esp
  801965:	ff 75 0c             	pushl  0xc(%ebp)
  801968:	50                   	push   %eax
  801969:	ff d2                	call   *%edx
  80196b:	89 c2                	mov    %eax,%edx
  80196d:	83 c4 10             	add    $0x10,%esp
  801970:	eb 09                	jmp    80197b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801972:	89 c2                	mov    %eax,%edx
  801974:	eb 05                	jmp    80197b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801976:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80197b:	89 d0                	mov    %edx,%eax
  80197d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801980:	c9                   	leave  
  801981:	c3                   	ret    

00801982 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801982:	55                   	push   %ebp
  801983:	89 e5                	mov    %esp,%ebp
  801985:	53                   	push   %ebx
  801986:	83 ec 14             	sub    $0x14,%esp
  801989:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80198c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80198f:	50                   	push   %eax
  801990:	ff 75 08             	pushl  0x8(%ebp)
  801993:	e8 6c fb ff ff       	call   801504 <fd_lookup>
  801998:	83 c4 08             	add    $0x8,%esp
  80199b:	89 c2                	mov    %eax,%edx
  80199d:	85 c0                	test   %eax,%eax
  80199f:	78 58                	js     8019f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a1:	83 ec 08             	sub    $0x8,%esp
  8019a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019a7:	50                   	push   %eax
  8019a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ab:	ff 30                	pushl  (%eax)
  8019ad:	e8 a8 fb ff ff       	call   80155a <dev_lookup>
  8019b2:	83 c4 10             	add    $0x10,%esp
  8019b5:	85 c0                	test   %eax,%eax
  8019b7:	78 37                	js     8019f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8019b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019c0:	74 32                	je     8019f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019cc:	00 00 00 
	stat->st_isdir = 0;
  8019cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019d6:	00 00 00 
	stat->st_dev = dev;
  8019d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019df:	83 ec 08             	sub    $0x8,%esp
  8019e2:	53                   	push   %ebx
  8019e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8019e6:	ff 50 14             	call   *0x14(%eax)
  8019e9:	89 c2                	mov    %eax,%edx
  8019eb:	83 c4 10             	add    $0x10,%esp
  8019ee:	eb 09                	jmp    8019f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019f0:	89 c2                	mov    %eax,%edx
  8019f2:	eb 05                	jmp    8019f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8019f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8019f9:	89 d0                	mov    %edx,%eax
  8019fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019fe:	c9                   	leave  
  8019ff:	c3                   	ret    

00801a00 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a00:	55                   	push   %ebp
  801a01:	89 e5                	mov    %esp,%ebp
  801a03:	56                   	push   %esi
  801a04:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a05:	83 ec 08             	sub    $0x8,%esp
  801a08:	6a 00                	push   $0x0
  801a0a:	ff 75 08             	pushl  0x8(%ebp)
  801a0d:	e8 e3 01 00 00       	call   801bf5 <open>
  801a12:	89 c3                	mov    %eax,%ebx
  801a14:	83 c4 10             	add    $0x10,%esp
  801a17:	85 c0                	test   %eax,%eax
  801a19:	78 1b                	js     801a36 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  801a1b:	83 ec 08             	sub    $0x8,%esp
  801a1e:	ff 75 0c             	pushl  0xc(%ebp)
  801a21:	50                   	push   %eax
  801a22:	e8 5b ff ff ff       	call   801982 <fstat>
  801a27:	89 c6                	mov    %eax,%esi
	close(fd);
  801a29:	89 1c 24             	mov    %ebx,(%esp)
  801a2c:	e8 fd fb ff ff       	call   80162e <close>
	return r;
  801a31:	83 c4 10             	add    $0x10,%esp
  801a34:	89 f0                	mov    %esi,%eax
}
  801a36:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a39:	5b                   	pop    %ebx
  801a3a:	5e                   	pop    %esi
  801a3b:	5d                   	pop    %ebp
  801a3c:	c3                   	ret    

00801a3d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a3d:	55                   	push   %ebp
  801a3e:	89 e5                	mov    %esp,%ebp
  801a40:	56                   	push   %esi
  801a41:	53                   	push   %ebx
  801a42:	89 c6                	mov    %eax,%esi
  801a44:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a46:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801a4d:	75 12                	jne    801a61 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	6a 01                	push   $0x1
  801a54:	e8 fc f9 ff ff       	call   801455 <ipc_find_env>
  801a59:	a3 00 50 80 00       	mov    %eax,0x805000
  801a5e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a61:	6a 07                	push   $0x7
  801a63:	68 00 60 80 00       	push   $0x806000
  801a68:	56                   	push   %esi
  801a69:	ff 35 00 50 80 00    	pushl  0x805000
  801a6f:	e8 8d f9 ff ff       	call   801401 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a74:	83 c4 0c             	add    $0xc,%esp
  801a77:	6a 00                	push   $0x0
  801a79:	53                   	push   %ebx
  801a7a:	6a 00                	push   $0x0
  801a7c:	e8 17 f9 ff ff       	call   801398 <ipc_recv>
}
  801a81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a84:	5b                   	pop    %ebx
  801a85:	5e                   	pop    %esi
  801a86:	5d                   	pop    %ebp
  801a87:	c3                   	ret    

00801a88 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  801a91:	8b 40 0c             	mov    0xc(%eax),%eax
  801a94:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a9c:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801aa1:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa6:	b8 02 00 00 00       	mov    $0x2,%eax
  801aab:	e8 8d ff ff ff       	call   801a3d <fsipc>
}
  801ab0:	c9                   	leave  
  801ab1:	c3                   	ret    

00801ab2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  801ab2:	55                   	push   %ebp
  801ab3:	89 e5                	mov    %esp,%ebp
  801ab5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801ab8:	8b 45 08             	mov    0x8(%ebp),%eax
  801abb:	8b 40 0c             	mov    0xc(%eax),%eax
  801abe:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801ac3:	ba 00 00 00 00       	mov    $0x0,%edx
  801ac8:	b8 06 00 00 00       	mov    $0x6,%eax
  801acd:	e8 6b ff ff ff       	call   801a3d <fsipc>
}
  801ad2:	c9                   	leave  
  801ad3:	c3                   	ret    

00801ad4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  801ad4:	55                   	push   %ebp
  801ad5:	89 e5                	mov    %esp,%ebp
  801ad7:	53                   	push   %ebx
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ade:	8b 45 08             	mov    0x8(%ebp),%eax
  801ae1:	8b 40 0c             	mov    0xc(%eax),%eax
  801ae4:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aee:	b8 05 00 00 00       	mov    $0x5,%eax
  801af3:	e8 45 ff ff ff       	call   801a3d <fsipc>
  801af8:	85 c0                	test   %eax,%eax
  801afa:	78 2c                	js     801b28 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	68 00 60 80 00       	push   $0x806000
  801b04:	53                   	push   %ebx
  801b05:	e8 5b f2 ff ff       	call   800d65 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b0a:	a1 80 60 80 00       	mov    0x806080,%eax
  801b0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b15:	a1 84 60 80 00       	mov    0x806084,%eax
  801b1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b20:	83 c4 10             	add    $0x10,%esp
  801b23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b2b:	c9                   	leave  
  801b2c:	c3                   	ret    

00801b2d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801b2d:	55                   	push   %ebp
  801b2e:	89 e5                	mov    %esp,%ebp
  801b30:	83 ec 0c             	sub    $0xc,%esp
  801b33:	8b 45 10             	mov    0x10(%ebp),%eax
  801b36:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b3b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b40:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b43:	8b 55 08             	mov    0x8(%ebp),%edx
  801b46:	8b 52 0c             	mov    0xc(%edx),%edx
  801b49:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801b4f:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801b54:	50                   	push   %eax
  801b55:	ff 75 0c             	pushl  0xc(%ebp)
  801b58:	68 08 60 80 00       	push   $0x806008
  801b5d:	e8 95 f3 ff ff       	call   800ef7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b62:	ba 00 00 00 00       	mov    $0x0,%edx
  801b67:	b8 04 00 00 00       	mov    $0x4,%eax
  801b6c:	e8 cc fe ff ff       	call   801a3d <fsipc>
	//panic("devfile_write not implemented");
}
  801b71:	c9                   	leave  
  801b72:	c3                   	ret    

00801b73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801b73:	55                   	push   %ebp
  801b74:	89 e5                	mov    %esp,%ebp
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801b81:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801b86:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	b8 03 00 00 00       	mov    $0x3,%eax
  801b96:	e8 a2 fe ff ff       	call   801a3d <fsipc>
  801b9b:	89 c3                	mov    %eax,%ebx
  801b9d:	85 c0                	test   %eax,%eax
  801b9f:	78 4b                	js     801bec <devfile_read+0x79>
		return r;
	assert(r <= n);
  801ba1:	39 c6                	cmp    %eax,%esi
  801ba3:	73 16                	jae    801bbb <devfile_read+0x48>
  801ba5:	68 a0 30 80 00       	push   $0x8030a0
  801baa:	68 a7 30 80 00       	push   $0x8030a7
  801baf:	6a 7c                	push   $0x7c
  801bb1:	68 bc 30 80 00       	push   $0x8030bc
  801bb6:	e8 cd ea ff ff       	call   800688 <_panic>
	assert(r <= PGSIZE);
  801bbb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bc0:	7e 16                	jle    801bd8 <devfile_read+0x65>
  801bc2:	68 c7 30 80 00       	push   $0x8030c7
  801bc7:	68 a7 30 80 00       	push   $0x8030a7
  801bcc:	6a 7d                	push   $0x7d
  801bce:	68 bc 30 80 00       	push   $0x8030bc
  801bd3:	e8 b0 ea ff ff       	call   800688 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bd8:	83 ec 04             	sub    $0x4,%esp
  801bdb:	50                   	push   %eax
  801bdc:	68 00 60 80 00       	push   $0x806000
  801be1:	ff 75 0c             	pushl  0xc(%ebp)
  801be4:	e8 0e f3 ff ff       	call   800ef7 <memmove>
	return r;
  801be9:	83 c4 10             	add    $0x10,%esp
}
  801bec:	89 d8                	mov    %ebx,%eax
  801bee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bf1:	5b                   	pop    %ebx
  801bf2:	5e                   	pop    %esi
  801bf3:	5d                   	pop    %ebp
  801bf4:	c3                   	ret    

00801bf5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801bf5:	55                   	push   %ebp
  801bf6:	89 e5                	mov    %esp,%ebp
  801bf8:	53                   	push   %ebx
  801bf9:	83 ec 20             	sub    $0x20,%esp
  801bfc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801bff:	53                   	push   %ebx
  801c00:	e8 27 f1 ff ff       	call   800d2c <strlen>
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c0d:	7f 67                	jg     801c76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c0f:	83 ec 0c             	sub    $0xc,%esp
  801c12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c15:	50                   	push   %eax
  801c16:	e8 9a f8 ff ff       	call   8014b5 <fd_alloc>
  801c1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801c1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801c20:	85 c0                	test   %eax,%eax
  801c22:	78 57                	js     801c7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801c24:	83 ec 08             	sub    $0x8,%esp
  801c27:	53                   	push   %ebx
  801c28:	68 00 60 80 00       	push   $0x806000
  801c2d:	e8 33 f1 ff ff       	call   800d65 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c35:	a3 00 64 80 00       	mov    %eax,0x806400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c42:	e8 f6 fd ff ff       	call   801a3d <fsipc>
  801c47:	89 c3                	mov    %eax,%ebx
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	79 14                	jns    801c64 <open+0x6f>
		fd_close(fd, 0);
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	6a 00                	push   $0x0
  801c55:	ff 75 f4             	pushl  -0xc(%ebp)
  801c58:	e8 50 f9 ff ff       	call   8015ad <fd_close>
		return r;
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	89 da                	mov    %ebx,%edx
  801c62:	eb 17                	jmp    801c7b <open+0x86>
	}

	return fd2num(fd);
  801c64:	83 ec 0c             	sub    $0xc,%esp
  801c67:	ff 75 f4             	pushl  -0xc(%ebp)
  801c6a:	e8 1f f8 ff ff       	call   80148e <fd2num>
  801c6f:	89 c2                	mov    %eax,%edx
  801c71:	83 c4 10             	add    $0x10,%esp
  801c74:	eb 05                	jmp    801c7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801c76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801c7b:	89 d0                	mov    %edx,%eax
  801c7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c80:	c9                   	leave  
  801c81:	c3                   	ret    

00801c82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c82:	55                   	push   %ebp
  801c83:	89 e5                	mov    %esp,%ebp
  801c85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c88:	ba 00 00 00 00       	mov    $0x0,%edx
  801c8d:	b8 08 00 00 00       	mov    $0x8,%eax
  801c92:	e8 a6 fd ff ff       	call   801a3d <fsipc>
}
  801c97:	c9                   	leave  
  801c98:	c3                   	ret    

00801c99 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801c9f:	68 d3 30 80 00       	push   $0x8030d3
  801ca4:	ff 75 0c             	pushl  0xc(%ebp)
  801ca7:	e8 b9 f0 ff ff       	call   800d65 <strcpy>
	return 0;
}
  801cac:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb1:	c9                   	leave  
  801cb2:	c3                   	ret    

00801cb3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801cb3:	55                   	push   %ebp
  801cb4:	89 e5                	mov    %esp,%ebp
  801cb6:	53                   	push   %ebx
  801cb7:	83 ec 10             	sub    $0x10,%esp
  801cba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801cbd:	53                   	push   %ebx
  801cbe:	e8 1c 09 00 00       	call   8025df <pageref>
  801cc3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801cc6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801ccb:	83 f8 01             	cmp    $0x1,%eax
  801cce:	75 10                	jne    801ce0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801cd0:	83 ec 0c             	sub    $0xc,%esp
  801cd3:	ff 73 0c             	pushl  0xc(%ebx)
  801cd6:	e8 c0 02 00 00       	call   801f9b <nsipc_close>
  801cdb:	89 c2                	mov    %eax,%edx
  801cdd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801ce0:	89 d0                	mov    %edx,%eax
  801ce2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce5:	c9                   	leave  
  801ce6:	c3                   	ret    

00801ce7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801ce7:	55                   	push   %ebp
  801ce8:	89 e5                	mov    %esp,%ebp
  801cea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801ced:	6a 00                	push   $0x0
  801cef:	ff 75 10             	pushl  0x10(%ebp)
  801cf2:	ff 75 0c             	pushl  0xc(%ebp)
  801cf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf8:	ff 70 0c             	pushl  0xc(%eax)
  801cfb:	e8 78 03 00 00       	call   802078 <nsipc_send>
}
  801d00:	c9                   	leave  
  801d01:	c3                   	ret    

00801d02 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801d02:	55                   	push   %ebp
  801d03:	89 e5                	mov    %esp,%ebp
  801d05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801d08:	6a 00                	push   $0x0
  801d0a:	ff 75 10             	pushl  0x10(%ebp)
  801d0d:	ff 75 0c             	pushl  0xc(%ebp)
  801d10:	8b 45 08             	mov    0x8(%ebp),%eax
  801d13:	ff 70 0c             	pushl  0xc(%eax)
  801d16:	e8 f1 02 00 00       	call   80200c <nsipc_recv>
}
  801d1b:	c9                   	leave  
  801d1c:	c3                   	ret    

00801d1d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801d1d:	55                   	push   %ebp
  801d1e:	89 e5                	mov    %esp,%ebp
  801d20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801d23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801d26:	52                   	push   %edx
  801d27:	50                   	push   %eax
  801d28:	e8 d7 f7 ff ff       	call   801504 <fd_lookup>
  801d2d:	83 c4 10             	add    $0x10,%esp
  801d30:	85 c0                	test   %eax,%eax
  801d32:	78 17                	js     801d4b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d37:	8b 0d 24 40 80 00    	mov    0x804024,%ecx
  801d3d:	39 08                	cmp    %ecx,(%eax)
  801d3f:	75 05                	jne    801d46 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801d41:	8b 40 0c             	mov    0xc(%eax),%eax
  801d44:	eb 05                	jmp    801d4b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801d46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801d4b:	c9                   	leave  
  801d4c:	c3                   	ret    

00801d4d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801d4d:	55                   	push   %ebp
  801d4e:	89 e5                	mov    %esp,%ebp
  801d50:	56                   	push   %esi
  801d51:	53                   	push   %ebx
  801d52:	83 ec 1c             	sub    $0x1c,%esp
  801d55:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801d57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d5a:	50                   	push   %eax
  801d5b:	e8 55 f7 ff ff       	call   8014b5 <fd_alloc>
  801d60:	89 c3                	mov    %eax,%ebx
  801d62:	83 c4 10             	add    $0x10,%esp
  801d65:	85 c0                	test   %eax,%eax
  801d67:	78 1b                	js     801d84 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801d69:	83 ec 04             	sub    $0x4,%esp
  801d6c:	68 07 04 00 00       	push   $0x407
  801d71:	ff 75 f4             	pushl  -0xc(%ebp)
  801d74:	6a 00                	push   $0x0
  801d76:	e8 ed f3 ff ff       	call   801168 <sys_page_alloc>
  801d7b:	89 c3                	mov    %eax,%ebx
  801d7d:	83 c4 10             	add    $0x10,%esp
  801d80:	85 c0                	test   %eax,%eax
  801d82:	79 10                	jns    801d94 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801d84:	83 ec 0c             	sub    $0xc,%esp
  801d87:	56                   	push   %esi
  801d88:	e8 0e 02 00 00       	call   801f9b <nsipc_close>
		return r;
  801d8d:	83 c4 10             	add    $0x10,%esp
  801d90:	89 d8                	mov    %ebx,%eax
  801d92:	eb 24                	jmp    801db8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801d94:	8b 15 24 40 80 00    	mov    0x804024,%edx
  801d9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d9d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801d9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801da2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801da9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801dac:	83 ec 0c             	sub    $0xc,%esp
  801daf:	50                   	push   %eax
  801db0:	e8 d9 f6 ff ff       	call   80148e <fd2num>
  801db5:	83 c4 10             	add    $0x10,%esp
}
  801db8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dbb:	5b                   	pop    %ebx
  801dbc:	5e                   	pop    %esi
  801dbd:	5d                   	pop    %ebp
  801dbe:	c3                   	ret    

00801dbf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801dbf:	55                   	push   %ebp
  801dc0:	89 e5                	mov    %esp,%ebp
  801dc2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801dc8:	e8 50 ff ff ff       	call   801d1d <fd2sockid>
		return r;
  801dcd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dcf:	85 c0                	test   %eax,%eax
  801dd1:	78 1f                	js     801df2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801dd3:	83 ec 04             	sub    $0x4,%esp
  801dd6:	ff 75 10             	pushl  0x10(%ebp)
  801dd9:	ff 75 0c             	pushl  0xc(%ebp)
  801ddc:	50                   	push   %eax
  801ddd:	e8 12 01 00 00       	call   801ef4 <nsipc_accept>
  801de2:	83 c4 10             	add    $0x10,%esp
		return r;
  801de5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801de7:	85 c0                	test   %eax,%eax
  801de9:	78 07                	js     801df2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801deb:	e8 5d ff ff ff       	call   801d4d <alloc_sockfd>
  801df0:	89 c1                	mov    %eax,%ecx
}
  801df2:	89 c8                	mov    %ecx,%eax
  801df4:	c9                   	leave  
  801df5:	c3                   	ret    

00801df6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801df6:	55                   	push   %ebp
  801df7:	89 e5                	mov    %esp,%ebp
  801df9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	e8 19 ff ff ff       	call   801d1d <fd2sockid>
  801e04:	85 c0                	test   %eax,%eax
  801e06:	78 12                	js     801e1a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801e08:	83 ec 04             	sub    $0x4,%esp
  801e0b:	ff 75 10             	pushl  0x10(%ebp)
  801e0e:	ff 75 0c             	pushl  0xc(%ebp)
  801e11:	50                   	push   %eax
  801e12:	e8 2d 01 00 00       	call   801f44 <nsipc_bind>
  801e17:	83 c4 10             	add    $0x10,%esp
}
  801e1a:	c9                   	leave  
  801e1b:	c3                   	ret    

00801e1c <shutdown>:

int
shutdown(int s, int how)
{
  801e1c:	55                   	push   %ebp
  801e1d:	89 e5                	mov    %esp,%ebp
  801e1f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e22:	8b 45 08             	mov    0x8(%ebp),%eax
  801e25:	e8 f3 fe ff ff       	call   801d1d <fd2sockid>
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	78 0f                	js     801e3d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801e2e:	83 ec 08             	sub    $0x8,%esp
  801e31:	ff 75 0c             	pushl  0xc(%ebp)
  801e34:	50                   	push   %eax
  801e35:	e8 3f 01 00 00       	call   801f79 <nsipc_shutdown>
  801e3a:	83 c4 10             	add    $0x10,%esp
}
  801e3d:	c9                   	leave  
  801e3e:	c3                   	ret    

00801e3f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801e3f:	55                   	push   %ebp
  801e40:	89 e5                	mov    %esp,%ebp
  801e42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e45:	8b 45 08             	mov    0x8(%ebp),%eax
  801e48:	e8 d0 fe ff ff       	call   801d1d <fd2sockid>
  801e4d:	85 c0                	test   %eax,%eax
  801e4f:	78 12                	js     801e63 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801e51:	83 ec 04             	sub    $0x4,%esp
  801e54:	ff 75 10             	pushl  0x10(%ebp)
  801e57:	ff 75 0c             	pushl  0xc(%ebp)
  801e5a:	50                   	push   %eax
  801e5b:	e8 55 01 00 00       	call   801fb5 <nsipc_connect>
  801e60:	83 c4 10             	add    $0x10,%esp
}
  801e63:	c9                   	leave  
  801e64:	c3                   	ret    

00801e65 <listen>:

int
listen(int s, int backlog)
{
  801e65:	55                   	push   %ebp
  801e66:	89 e5                	mov    %esp,%ebp
  801e68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801e6e:	e8 aa fe ff ff       	call   801d1d <fd2sockid>
  801e73:	85 c0                	test   %eax,%eax
  801e75:	78 0f                	js     801e86 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801e77:	83 ec 08             	sub    $0x8,%esp
  801e7a:	ff 75 0c             	pushl  0xc(%ebp)
  801e7d:	50                   	push   %eax
  801e7e:	e8 67 01 00 00       	call   801fea <nsipc_listen>
  801e83:	83 c4 10             	add    $0x10,%esp
}
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801e88:	55                   	push   %ebp
  801e89:	89 e5                	mov    %esp,%ebp
  801e8b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801e8e:	ff 75 10             	pushl  0x10(%ebp)
  801e91:	ff 75 0c             	pushl  0xc(%ebp)
  801e94:	ff 75 08             	pushl  0x8(%ebp)
  801e97:	e8 3a 02 00 00       	call   8020d6 <nsipc_socket>
  801e9c:	83 c4 10             	add    $0x10,%esp
  801e9f:	85 c0                	test   %eax,%eax
  801ea1:	78 05                	js     801ea8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801ea3:	e8 a5 fe ff ff       	call   801d4d <alloc_sockfd>
}
  801ea8:	c9                   	leave  
  801ea9:	c3                   	ret    

00801eaa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801eaa:	55                   	push   %ebp
  801eab:	89 e5                	mov    %esp,%ebp
  801ead:	53                   	push   %ebx
  801eae:	83 ec 04             	sub    $0x4,%esp
  801eb1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801eb3:	83 3d 04 50 80 00 00 	cmpl   $0x0,0x805004
  801eba:	75 12                	jne    801ece <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801ebc:	83 ec 0c             	sub    $0xc,%esp
  801ebf:	6a 02                	push   $0x2
  801ec1:	e8 8f f5 ff ff       	call   801455 <ipc_find_env>
  801ec6:	a3 04 50 80 00       	mov    %eax,0x805004
  801ecb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801ece:	6a 07                	push   $0x7
  801ed0:	68 00 70 80 00       	push   $0x807000
  801ed5:	53                   	push   %ebx
  801ed6:	ff 35 04 50 80 00    	pushl  0x805004
  801edc:	e8 20 f5 ff ff       	call   801401 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801ee1:	83 c4 0c             	add    $0xc,%esp
  801ee4:	6a 00                	push   $0x0
  801ee6:	6a 00                	push   $0x0
  801ee8:	6a 00                	push   $0x0
  801eea:	e8 a9 f4 ff ff       	call   801398 <ipc_recv>
}
  801eef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ef2:	c9                   	leave  
  801ef3:	c3                   	ret    

00801ef4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801ef4:	55                   	push   %ebp
  801ef5:	89 e5                	mov    %esp,%ebp
  801ef7:	56                   	push   %esi
  801ef8:	53                   	push   %ebx
  801ef9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801efc:	8b 45 08             	mov    0x8(%ebp),%eax
  801eff:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801f04:	8b 06                	mov    (%esi),%eax
  801f06:	a3 04 70 80 00       	mov    %eax,0x807004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801f0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801f10:	e8 95 ff ff ff       	call   801eaa <nsipc>
  801f15:	89 c3                	mov    %eax,%ebx
  801f17:	85 c0                	test   %eax,%eax
  801f19:	78 20                	js     801f3b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801f1b:	83 ec 04             	sub    $0x4,%esp
  801f1e:	ff 35 10 70 80 00    	pushl  0x807010
  801f24:	68 00 70 80 00       	push   $0x807000
  801f29:	ff 75 0c             	pushl  0xc(%ebp)
  801f2c:	e8 c6 ef ff ff       	call   800ef7 <memmove>
		*addrlen = ret->ret_addrlen;
  801f31:	a1 10 70 80 00       	mov    0x807010,%eax
  801f36:	89 06                	mov    %eax,(%esi)
  801f38:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801f3b:	89 d8                	mov    %ebx,%eax
  801f3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f40:	5b                   	pop    %ebx
  801f41:	5e                   	pop    %esi
  801f42:	5d                   	pop    %ebp
  801f43:	c3                   	ret    

00801f44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801f44:	55                   	push   %ebp
  801f45:	89 e5                	mov    %esp,%ebp
  801f47:	53                   	push   %ebx
  801f48:	83 ec 08             	sub    $0x8,%esp
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801f4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801f51:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801f56:	53                   	push   %ebx
  801f57:	ff 75 0c             	pushl  0xc(%ebp)
  801f5a:	68 04 70 80 00       	push   $0x807004
  801f5f:	e8 93 ef ff ff       	call   800ef7 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801f64:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_BIND);
  801f6a:	b8 02 00 00 00       	mov    $0x2,%eax
  801f6f:	e8 36 ff ff ff       	call   801eaa <nsipc>
}
  801f74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f77:	c9                   	leave  
  801f78:	c3                   	ret    

00801f79 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801f79:	55                   	push   %ebp
  801f7a:	89 e5                	mov    %esp,%ebp
  801f7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801f82:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.shutdown.req_how = how;
  801f87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f8a:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_SHUTDOWN);
  801f8f:	b8 03 00 00 00       	mov    $0x3,%eax
  801f94:	e8 11 ff ff ff       	call   801eaa <nsipc>
}
  801f99:	c9                   	leave  
  801f9a:	c3                   	ret    

00801f9b <nsipc_close>:

int
nsipc_close(int s)
{
  801f9b:	55                   	push   %ebp
  801f9c:	89 e5                	mov    %esp,%ebp
  801f9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801fa1:	8b 45 08             	mov    0x8(%ebp),%eax
  801fa4:	a3 00 70 80 00       	mov    %eax,0x807000
	return nsipc(NSREQ_CLOSE);
  801fa9:	b8 04 00 00 00       	mov    $0x4,%eax
  801fae:	e8 f7 fe ff ff       	call   801eaa <nsipc>
}
  801fb3:	c9                   	leave  
  801fb4:	c3                   	ret    

00801fb5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801fb5:	55                   	push   %ebp
  801fb6:	89 e5                	mov    %esp,%ebp
  801fb8:	53                   	push   %ebx
  801fb9:	83 ec 08             	sub    $0x8,%esp
  801fbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801fbf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fc2:	a3 00 70 80 00       	mov    %eax,0x807000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801fc7:	53                   	push   %ebx
  801fc8:	ff 75 0c             	pushl  0xc(%ebp)
  801fcb:	68 04 70 80 00       	push   $0x807004
  801fd0:	e8 22 ef ff ff       	call   800ef7 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801fd5:	89 1d 14 70 80 00    	mov    %ebx,0x807014
	return nsipc(NSREQ_CONNECT);
  801fdb:	b8 05 00 00 00       	mov    $0x5,%eax
  801fe0:	e8 c5 fe ff ff       	call   801eaa <nsipc>
}
  801fe5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fe8:	c9                   	leave  
  801fe9:	c3                   	ret    

00801fea <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801fea:	55                   	push   %ebp
  801feb:	89 e5                	mov    %esp,%ebp
  801fed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ff0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ff3:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.listen.req_backlog = backlog;
  801ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ffb:	a3 04 70 80 00       	mov    %eax,0x807004
	return nsipc(NSREQ_LISTEN);
  802000:	b8 06 00 00 00       	mov    $0x6,%eax
  802005:	e8 a0 fe ff ff       	call   801eaa <nsipc>
}
  80200a:	c9                   	leave  
  80200b:	c3                   	ret    

0080200c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	56                   	push   %esi
  802010:	53                   	push   %ebx
  802011:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.recv.req_len = len;
  80201c:	89 35 04 70 80 00    	mov    %esi,0x807004
	nsipcbuf.recv.req_flags = flags;
  802022:	8b 45 14             	mov    0x14(%ebp),%eax
  802025:	a3 08 70 80 00       	mov    %eax,0x807008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  80202a:	b8 07 00 00 00       	mov    $0x7,%eax
  80202f:	e8 76 fe ff ff       	call   801eaa <nsipc>
  802034:	89 c3                	mov    %eax,%ebx
  802036:	85 c0                	test   %eax,%eax
  802038:	78 35                	js     80206f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  80203a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  80203f:	7f 04                	jg     802045 <nsipc_recv+0x39>
  802041:	39 c6                	cmp    %eax,%esi
  802043:	7d 16                	jge    80205b <nsipc_recv+0x4f>
  802045:	68 df 30 80 00       	push   $0x8030df
  80204a:	68 a7 30 80 00       	push   $0x8030a7
  80204f:	6a 62                	push   $0x62
  802051:	68 f4 30 80 00       	push   $0x8030f4
  802056:	e8 2d e6 ff ff       	call   800688 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  80205b:	83 ec 04             	sub    $0x4,%esp
  80205e:	50                   	push   %eax
  80205f:	68 00 70 80 00       	push   $0x807000
  802064:	ff 75 0c             	pushl  0xc(%ebp)
  802067:	e8 8b ee ff ff       	call   800ef7 <memmove>
  80206c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  80206f:	89 d8                	mov    %ebx,%eax
  802071:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802074:	5b                   	pop    %ebx
  802075:	5e                   	pop    %esi
  802076:	5d                   	pop    %ebp
  802077:	c3                   	ret    

00802078 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	53                   	push   %ebx
  80207c:	83 ec 04             	sub    $0x4,%esp
  80207f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  802082:	8b 45 08             	mov    0x8(%ebp),%eax
  802085:	a3 00 70 80 00       	mov    %eax,0x807000
	assert(size < 1600);
  80208a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  802090:	7e 16                	jle    8020a8 <nsipc_send+0x30>
  802092:	68 00 31 80 00       	push   $0x803100
  802097:	68 a7 30 80 00       	push   $0x8030a7
  80209c:	6a 6d                	push   $0x6d
  80209e:	68 f4 30 80 00       	push   $0x8030f4
  8020a3:	e8 e0 e5 ff ff       	call   800688 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  8020a8:	83 ec 04             	sub    $0x4,%esp
  8020ab:	53                   	push   %ebx
  8020ac:	ff 75 0c             	pushl  0xc(%ebp)
  8020af:	68 0c 70 80 00       	push   $0x80700c
  8020b4:	e8 3e ee ff ff       	call   800ef7 <memmove>
	nsipcbuf.send.req_size = size;
  8020b9:	89 1d 04 70 80 00    	mov    %ebx,0x807004
	nsipcbuf.send.req_flags = flags;
  8020bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8020c2:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SEND);
  8020c7:	b8 08 00 00 00       	mov    $0x8,%eax
  8020cc:	e8 d9 fd ff ff       	call   801eaa <nsipc>
}
  8020d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8020d4:	c9                   	leave  
  8020d5:	c3                   	ret    

008020d6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  8020d6:	55                   	push   %ebp
  8020d7:	89 e5                	mov    %esp,%ebp
  8020d9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  8020dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8020df:	a3 00 70 80 00       	mov    %eax,0x807000
	nsipcbuf.socket.req_type = type;
  8020e4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8020e7:	a3 04 70 80 00       	mov    %eax,0x807004
	nsipcbuf.socket.req_protocol = protocol;
  8020ec:	8b 45 10             	mov    0x10(%ebp),%eax
  8020ef:	a3 08 70 80 00       	mov    %eax,0x807008
	return nsipc(NSREQ_SOCKET);
  8020f4:	b8 09 00 00 00       	mov    $0x9,%eax
  8020f9:	e8 ac fd ff ff       	call   801eaa <nsipc>
}
  8020fe:	c9                   	leave  
  8020ff:	c3                   	ret    

00802100 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802100:	55                   	push   %ebp
  802101:	89 e5                	mov    %esp,%ebp
  802103:	56                   	push   %esi
  802104:	53                   	push   %ebx
  802105:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802108:	83 ec 0c             	sub    $0xc,%esp
  80210b:	ff 75 08             	pushl  0x8(%ebp)
  80210e:	e8 8b f3 ff ff       	call   80149e <fd2data>
  802113:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802115:	83 c4 08             	add    $0x8,%esp
  802118:	68 0c 31 80 00       	push   $0x80310c
  80211d:	53                   	push   %ebx
  80211e:	e8 42 ec ff ff       	call   800d65 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802123:	8b 46 04             	mov    0x4(%esi),%eax
  802126:	2b 06                	sub    (%esi),%eax
  802128:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80212e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802135:	00 00 00 
	stat->st_dev = &devpipe;
  802138:	c7 83 88 00 00 00 40 	movl   $0x804040,0x88(%ebx)
  80213f:	40 80 00 
	return 0;
}
  802142:	b8 00 00 00 00       	mov    $0x0,%eax
  802147:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80214a:	5b                   	pop    %ebx
  80214b:	5e                   	pop    %esi
  80214c:	5d                   	pop    %ebp
  80214d:	c3                   	ret    

0080214e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80214e:	55                   	push   %ebp
  80214f:	89 e5                	mov    %esp,%ebp
  802151:	53                   	push   %ebx
  802152:	83 ec 0c             	sub    $0xc,%esp
  802155:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802158:	53                   	push   %ebx
  802159:	6a 00                	push   $0x0
  80215b:	e8 8d f0 ff ff       	call   8011ed <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802160:	89 1c 24             	mov    %ebx,(%esp)
  802163:	e8 36 f3 ff ff       	call   80149e <fd2data>
  802168:	83 c4 08             	add    $0x8,%esp
  80216b:	50                   	push   %eax
  80216c:	6a 00                	push   $0x0
  80216e:	e8 7a f0 ff ff       	call   8011ed <sys_page_unmap>
}
  802173:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802176:	c9                   	leave  
  802177:	c3                   	ret    

00802178 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802178:	55                   	push   %ebp
  802179:	89 e5                	mov    %esp,%ebp
  80217b:	57                   	push   %edi
  80217c:	56                   	push   %esi
  80217d:	53                   	push   %ebx
  80217e:	83 ec 1c             	sub    $0x1c,%esp
  802181:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802184:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802186:	a1 08 50 80 00       	mov    0x805008,%eax
  80218b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80218e:	83 ec 0c             	sub    $0xc,%esp
  802191:	ff 75 e0             	pushl  -0x20(%ebp)
  802194:	e8 46 04 00 00       	call   8025df <pageref>
  802199:	89 c3                	mov    %eax,%ebx
  80219b:	89 3c 24             	mov    %edi,(%esp)
  80219e:	e8 3c 04 00 00       	call   8025df <pageref>
  8021a3:	83 c4 10             	add    $0x10,%esp
  8021a6:	39 c3                	cmp    %eax,%ebx
  8021a8:	0f 94 c1             	sete   %cl
  8021ab:	0f b6 c9             	movzbl %cl,%ecx
  8021ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8021b1:	8b 15 08 50 80 00    	mov    0x805008,%edx
  8021b7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8021ba:	39 ce                	cmp    %ecx,%esi
  8021bc:	74 1b                	je     8021d9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8021be:	39 c3                	cmp    %eax,%ebx
  8021c0:	75 c4                	jne    802186 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8021c2:	8b 42 58             	mov    0x58(%edx),%eax
  8021c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8021c8:	50                   	push   %eax
  8021c9:	56                   	push   %esi
  8021ca:	68 13 31 80 00       	push   $0x803113
  8021cf:	e8 8d e5 ff ff       	call   800761 <cprintf>
  8021d4:	83 c4 10             	add    $0x10,%esp
  8021d7:	eb ad                	jmp    802186 <_pipeisclosed+0xe>
	}
}
  8021d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8021dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021df:	5b                   	pop    %ebx
  8021e0:	5e                   	pop    %esi
  8021e1:	5f                   	pop    %edi
  8021e2:	5d                   	pop    %ebp
  8021e3:	c3                   	ret    

008021e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8021e4:	55                   	push   %ebp
  8021e5:	89 e5                	mov    %esp,%ebp
  8021e7:	57                   	push   %edi
  8021e8:	56                   	push   %esi
  8021e9:	53                   	push   %ebx
  8021ea:	83 ec 28             	sub    $0x28,%esp
  8021ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8021f0:	56                   	push   %esi
  8021f1:	e8 a8 f2 ff ff       	call   80149e <fd2data>
  8021f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021f8:	83 c4 10             	add    $0x10,%esp
  8021fb:	bf 00 00 00 00       	mov    $0x0,%edi
  802200:	eb 4b                	jmp    80224d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802202:	89 da                	mov    %ebx,%edx
  802204:	89 f0                	mov    %esi,%eax
  802206:	e8 6d ff ff ff       	call   802178 <_pipeisclosed>
  80220b:	85 c0                	test   %eax,%eax
  80220d:	75 48                	jne    802257 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80220f:	e8 35 ef ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802214:	8b 43 04             	mov    0x4(%ebx),%eax
  802217:	8b 0b                	mov    (%ebx),%ecx
  802219:	8d 51 20             	lea    0x20(%ecx),%edx
  80221c:	39 d0                	cmp    %edx,%eax
  80221e:	73 e2                	jae    802202 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802220:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802223:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802227:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80222a:	89 c2                	mov    %eax,%edx
  80222c:	c1 fa 1f             	sar    $0x1f,%edx
  80222f:	89 d1                	mov    %edx,%ecx
  802231:	c1 e9 1b             	shr    $0x1b,%ecx
  802234:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802237:	83 e2 1f             	and    $0x1f,%edx
  80223a:	29 ca                	sub    %ecx,%edx
  80223c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802240:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802244:	83 c0 01             	add    $0x1,%eax
  802247:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80224a:	83 c7 01             	add    $0x1,%edi
  80224d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802250:	75 c2                	jne    802214 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802252:	8b 45 10             	mov    0x10(%ebp),%eax
  802255:	eb 05                	jmp    80225c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802257:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80225c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80225f:	5b                   	pop    %ebx
  802260:	5e                   	pop    %esi
  802261:	5f                   	pop    %edi
  802262:	5d                   	pop    %ebp
  802263:	c3                   	ret    

00802264 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802264:	55                   	push   %ebp
  802265:	89 e5                	mov    %esp,%ebp
  802267:	57                   	push   %edi
  802268:	56                   	push   %esi
  802269:	53                   	push   %ebx
  80226a:	83 ec 18             	sub    $0x18,%esp
  80226d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802270:	57                   	push   %edi
  802271:	e8 28 f2 ff ff       	call   80149e <fd2data>
  802276:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802278:	83 c4 10             	add    $0x10,%esp
  80227b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802280:	eb 3d                	jmp    8022bf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802282:	85 db                	test   %ebx,%ebx
  802284:	74 04                	je     80228a <devpipe_read+0x26>
				return i;
  802286:	89 d8                	mov    %ebx,%eax
  802288:	eb 44                	jmp    8022ce <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80228a:	89 f2                	mov    %esi,%edx
  80228c:	89 f8                	mov    %edi,%eax
  80228e:	e8 e5 fe ff ff       	call   802178 <_pipeisclosed>
  802293:	85 c0                	test   %eax,%eax
  802295:	75 32                	jne    8022c9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802297:	e8 ad ee ff ff       	call   801149 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80229c:	8b 06                	mov    (%esi),%eax
  80229e:	3b 46 04             	cmp    0x4(%esi),%eax
  8022a1:	74 df                	je     802282 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8022a3:	99                   	cltd   
  8022a4:	c1 ea 1b             	shr    $0x1b,%edx
  8022a7:	01 d0                	add    %edx,%eax
  8022a9:	83 e0 1f             	and    $0x1f,%eax
  8022ac:	29 d0                	sub    %edx,%eax
  8022ae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8022b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8022b6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8022b9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8022bc:	83 c3 01             	add    $0x1,%ebx
  8022bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8022c2:	75 d8                	jne    80229c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8022c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8022c7:	eb 05                	jmp    8022ce <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8022c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8022ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8022d1:	5b                   	pop    %ebx
  8022d2:	5e                   	pop    %esi
  8022d3:	5f                   	pop    %edi
  8022d4:	5d                   	pop    %ebp
  8022d5:	c3                   	ret    

008022d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8022d6:	55                   	push   %ebp
  8022d7:	89 e5                	mov    %esp,%ebp
  8022d9:	56                   	push   %esi
  8022da:	53                   	push   %ebx
  8022db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8022de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e1:	50                   	push   %eax
  8022e2:	e8 ce f1 ff ff       	call   8014b5 <fd_alloc>
  8022e7:	83 c4 10             	add    $0x10,%esp
  8022ea:	89 c2                	mov    %eax,%edx
  8022ec:	85 c0                	test   %eax,%eax
  8022ee:	0f 88 2c 01 00 00    	js     802420 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8022f4:	83 ec 04             	sub    $0x4,%esp
  8022f7:	68 07 04 00 00       	push   $0x407
  8022fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8022ff:	6a 00                	push   $0x0
  802301:	e8 62 ee ff ff       	call   801168 <sys_page_alloc>
  802306:	83 c4 10             	add    $0x10,%esp
  802309:	89 c2                	mov    %eax,%edx
  80230b:	85 c0                	test   %eax,%eax
  80230d:	0f 88 0d 01 00 00    	js     802420 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802313:	83 ec 0c             	sub    $0xc,%esp
  802316:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802319:	50                   	push   %eax
  80231a:	e8 96 f1 ff ff       	call   8014b5 <fd_alloc>
  80231f:	89 c3                	mov    %eax,%ebx
  802321:	83 c4 10             	add    $0x10,%esp
  802324:	85 c0                	test   %eax,%eax
  802326:	0f 88 e2 00 00 00    	js     80240e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80232c:	83 ec 04             	sub    $0x4,%esp
  80232f:	68 07 04 00 00       	push   $0x407
  802334:	ff 75 f0             	pushl  -0x10(%ebp)
  802337:	6a 00                	push   $0x0
  802339:	e8 2a ee ff ff       	call   801168 <sys_page_alloc>
  80233e:	89 c3                	mov    %eax,%ebx
  802340:	83 c4 10             	add    $0x10,%esp
  802343:	85 c0                	test   %eax,%eax
  802345:	0f 88 c3 00 00 00    	js     80240e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80234b:	83 ec 0c             	sub    $0xc,%esp
  80234e:	ff 75 f4             	pushl  -0xc(%ebp)
  802351:	e8 48 f1 ff ff       	call   80149e <fd2data>
  802356:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802358:	83 c4 0c             	add    $0xc,%esp
  80235b:	68 07 04 00 00       	push   $0x407
  802360:	50                   	push   %eax
  802361:	6a 00                	push   $0x0
  802363:	e8 00 ee ff ff       	call   801168 <sys_page_alloc>
  802368:	89 c3                	mov    %eax,%ebx
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	0f 88 89 00 00 00    	js     8023fe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802375:	83 ec 0c             	sub    $0xc,%esp
  802378:	ff 75 f0             	pushl  -0x10(%ebp)
  80237b:	e8 1e f1 ff ff       	call   80149e <fd2data>
  802380:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802387:	50                   	push   %eax
  802388:	6a 00                	push   $0x0
  80238a:	56                   	push   %esi
  80238b:	6a 00                	push   $0x0
  80238d:	e8 19 ee ff ff       	call   8011ab <sys_page_map>
  802392:	89 c3                	mov    %eax,%ebx
  802394:	83 c4 20             	add    $0x20,%esp
  802397:	85 c0                	test   %eax,%eax
  802399:	78 55                	js     8023f0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80239b:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8023a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8023a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8023b0:	8b 15 40 40 80 00    	mov    0x804040,%edx
  8023b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023b9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8023bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8023be:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8023c5:	83 ec 0c             	sub    $0xc,%esp
  8023c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8023cb:	e8 be f0 ff ff       	call   80148e <fd2num>
  8023d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023d3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8023d5:	83 c4 04             	add    $0x4,%esp
  8023d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8023db:	e8 ae f0 ff ff       	call   80148e <fd2num>
  8023e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8023e3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8023e6:	83 c4 10             	add    $0x10,%esp
  8023e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8023ee:	eb 30                	jmp    802420 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8023f0:	83 ec 08             	sub    $0x8,%esp
  8023f3:	56                   	push   %esi
  8023f4:	6a 00                	push   $0x0
  8023f6:	e8 f2 ed ff ff       	call   8011ed <sys_page_unmap>
  8023fb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8023fe:	83 ec 08             	sub    $0x8,%esp
  802401:	ff 75 f0             	pushl  -0x10(%ebp)
  802404:	6a 00                	push   $0x0
  802406:	e8 e2 ed ff ff       	call   8011ed <sys_page_unmap>
  80240b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80240e:	83 ec 08             	sub    $0x8,%esp
  802411:	ff 75 f4             	pushl  -0xc(%ebp)
  802414:	6a 00                	push   $0x0
  802416:	e8 d2 ed ff ff       	call   8011ed <sys_page_unmap>
  80241b:	83 c4 10             	add    $0x10,%esp
  80241e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802420:	89 d0                	mov    %edx,%eax
  802422:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802425:	5b                   	pop    %ebx
  802426:	5e                   	pop    %esi
  802427:	5d                   	pop    %ebp
  802428:	c3                   	ret    

00802429 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802429:	55                   	push   %ebp
  80242a:	89 e5                	mov    %esp,%ebp
  80242c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80242f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802432:	50                   	push   %eax
  802433:	ff 75 08             	pushl  0x8(%ebp)
  802436:	e8 c9 f0 ff ff       	call   801504 <fd_lookup>
  80243b:	83 c4 10             	add    $0x10,%esp
  80243e:	85 c0                	test   %eax,%eax
  802440:	78 18                	js     80245a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802442:	83 ec 0c             	sub    $0xc,%esp
  802445:	ff 75 f4             	pushl  -0xc(%ebp)
  802448:	e8 51 f0 ff ff       	call   80149e <fd2data>
	return _pipeisclosed(fd, p);
  80244d:	89 c2                	mov    %eax,%edx
  80244f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802452:	e8 21 fd ff ff       	call   802178 <_pipeisclosed>
  802457:	83 c4 10             	add    $0x10,%esp
}
  80245a:	c9                   	leave  
  80245b:	c3                   	ret    

0080245c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80245c:	55                   	push   %ebp
  80245d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80245f:	b8 00 00 00 00       	mov    $0x0,%eax
  802464:	5d                   	pop    %ebp
  802465:	c3                   	ret    

00802466 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802466:	55                   	push   %ebp
  802467:	89 e5                	mov    %esp,%ebp
  802469:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80246c:	68 2b 31 80 00       	push   $0x80312b
  802471:	ff 75 0c             	pushl  0xc(%ebp)
  802474:	e8 ec e8 ff ff       	call   800d65 <strcpy>
	return 0;
}
  802479:	b8 00 00 00 00       	mov    $0x0,%eax
  80247e:	c9                   	leave  
  80247f:	c3                   	ret    

00802480 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802480:	55                   	push   %ebp
  802481:	89 e5                	mov    %esp,%ebp
  802483:	57                   	push   %edi
  802484:	56                   	push   %esi
  802485:	53                   	push   %ebx
  802486:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80248c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802491:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802497:	eb 2d                	jmp    8024c6 <devcons_write+0x46>
		m = n - tot;
  802499:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80249c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80249e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8024a1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8024a6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8024a9:	83 ec 04             	sub    $0x4,%esp
  8024ac:	53                   	push   %ebx
  8024ad:	03 45 0c             	add    0xc(%ebp),%eax
  8024b0:	50                   	push   %eax
  8024b1:	57                   	push   %edi
  8024b2:	e8 40 ea ff ff       	call   800ef7 <memmove>
		sys_cputs(buf, m);
  8024b7:	83 c4 08             	add    $0x8,%esp
  8024ba:	53                   	push   %ebx
  8024bb:	57                   	push   %edi
  8024bc:	e8 eb eb ff ff       	call   8010ac <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8024c1:	01 de                	add    %ebx,%esi
  8024c3:	83 c4 10             	add    $0x10,%esp
  8024c6:	89 f0                	mov    %esi,%eax
  8024c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8024cb:	72 cc                	jb     802499 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8024cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024d0:	5b                   	pop    %ebx
  8024d1:	5e                   	pop    %esi
  8024d2:	5f                   	pop    %edi
  8024d3:	5d                   	pop    %ebp
  8024d4:	c3                   	ret    

008024d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8024d5:	55                   	push   %ebp
  8024d6:	89 e5                	mov    %esp,%ebp
  8024d8:	83 ec 08             	sub    $0x8,%esp
  8024db:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8024e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8024e4:	74 2a                	je     802510 <devcons_read+0x3b>
  8024e6:	eb 05                	jmp    8024ed <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8024e8:	e8 5c ec ff ff       	call   801149 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8024ed:	e8 d8 eb ff ff       	call   8010ca <sys_cgetc>
  8024f2:	85 c0                	test   %eax,%eax
  8024f4:	74 f2                	je     8024e8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8024f6:	85 c0                	test   %eax,%eax
  8024f8:	78 16                	js     802510 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8024fa:	83 f8 04             	cmp    $0x4,%eax
  8024fd:	74 0c                	je     80250b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8024ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  802502:	88 02                	mov    %al,(%edx)
	return 1;
  802504:	b8 01 00 00 00       	mov    $0x1,%eax
  802509:	eb 05                	jmp    802510 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80250b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802510:	c9                   	leave  
  802511:	c3                   	ret    

00802512 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802512:	55                   	push   %ebp
  802513:	89 e5                	mov    %esp,%ebp
  802515:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802518:	8b 45 08             	mov    0x8(%ebp),%eax
  80251b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80251e:	6a 01                	push   $0x1
  802520:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802523:	50                   	push   %eax
  802524:	e8 83 eb ff ff       	call   8010ac <sys_cputs>
}
  802529:	83 c4 10             	add    $0x10,%esp
  80252c:	c9                   	leave  
  80252d:	c3                   	ret    

0080252e <getchar>:

int
getchar(void)
{
  80252e:	55                   	push   %ebp
  80252f:	89 e5                	mov    %esp,%ebp
  802531:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802534:	6a 01                	push   $0x1
  802536:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802539:	50                   	push   %eax
  80253a:	6a 00                	push   $0x0
  80253c:	e8 29 f2 ff ff       	call   80176a <read>
	if (r < 0)
  802541:	83 c4 10             	add    $0x10,%esp
  802544:	85 c0                	test   %eax,%eax
  802546:	78 0f                	js     802557 <getchar+0x29>
		return r;
	if (r < 1)
  802548:	85 c0                	test   %eax,%eax
  80254a:	7e 06                	jle    802552 <getchar+0x24>
		return -E_EOF;
	return c;
  80254c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802550:	eb 05                	jmp    802557 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802552:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802557:	c9                   	leave  
  802558:	c3                   	ret    

00802559 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802559:	55                   	push   %ebp
  80255a:	89 e5                	mov    %esp,%ebp
  80255c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80255f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802562:	50                   	push   %eax
  802563:	ff 75 08             	pushl  0x8(%ebp)
  802566:	e8 99 ef ff ff       	call   801504 <fd_lookup>
  80256b:	83 c4 10             	add    $0x10,%esp
  80256e:	85 c0                	test   %eax,%eax
  802570:	78 11                	js     802583 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802572:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802575:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  80257b:	39 10                	cmp    %edx,(%eax)
  80257d:	0f 94 c0             	sete   %al
  802580:	0f b6 c0             	movzbl %al,%eax
}
  802583:	c9                   	leave  
  802584:	c3                   	ret    

00802585 <opencons>:

int
opencons(void)
{
  802585:	55                   	push   %ebp
  802586:	89 e5                	mov    %esp,%ebp
  802588:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80258b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80258e:	50                   	push   %eax
  80258f:	e8 21 ef ff ff       	call   8014b5 <fd_alloc>
  802594:	83 c4 10             	add    $0x10,%esp
		return r;
  802597:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802599:	85 c0                	test   %eax,%eax
  80259b:	78 3e                	js     8025db <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80259d:	83 ec 04             	sub    $0x4,%esp
  8025a0:	68 07 04 00 00       	push   $0x407
  8025a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8025a8:	6a 00                	push   $0x0
  8025aa:	e8 b9 eb ff ff       	call   801168 <sys_page_alloc>
  8025af:	83 c4 10             	add    $0x10,%esp
		return r;
  8025b2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8025b4:	85 c0                	test   %eax,%eax
  8025b6:	78 23                	js     8025db <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8025b8:	8b 15 5c 40 80 00    	mov    0x80405c,%edx
  8025be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8025c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8025c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8025cd:	83 ec 0c             	sub    $0xc,%esp
  8025d0:	50                   	push   %eax
  8025d1:	e8 b8 ee ff ff       	call   80148e <fd2num>
  8025d6:	89 c2                	mov    %eax,%edx
  8025d8:	83 c4 10             	add    $0x10,%esp
}
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	c9                   	leave  
  8025de:	c3                   	ret    

008025df <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025df:	55                   	push   %ebp
  8025e0:	89 e5                	mov    %esp,%ebp
  8025e2:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025e5:	89 d0                	mov    %edx,%eax
  8025e7:	c1 e8 16             	shr    $0x16,%eax
  8025ea:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025f1:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025f6:	f6 c1 01             	test   $0x1,%cl
  8025f9:	74 1d                	je     802618 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025fb:	c1 ea 0c             	shr    $0xc,%edx
  8025fe:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802605:	f6 c2 01             	test   $0x1,%dl
  802608:	74 0e                	je     802618 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80260a:	c1 ea 0c             	shr    $0xc,%edx
  80260d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802614:	ef 
  802615:	0f b7 c0             	movzwl %ax,%eax
}
  802618:	5d                   	pop    %ebp
  802619:	c3                   	ret    
  80261a:	66 90                	xchg   %ax,%ax
  80261c:	66 90                	xchg   %ax,%ax
  80261e:	66 90                	xchg   %ax,%ax

00802620 <__udivdi3>:
  802620:	55                   	push   %ebp
  802621:	57                   	push   %edi
  802622:	56                   	push   %esi
  802623:	53                   	push   %ebx
  802624:	83 ec 1c             	sub    $0x1c,%esp
  802627:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80262b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80262f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802633:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802637:	85 f6                	test   %esi,%esi
  802639:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80263d:	89 ca                	mov    %ecx,%edx
  80263f:	89 f8                	mov    %edi,%eax
  802641:	75 3d                	jne    802680 <__udivdi3+0x60>
  802643:	39 cf                	cmp    %ecx,%edi
  802645:	0f 87 c5 00 00 00    	ja     802710 <__udivdi3+0xf0>
  80264b:	85 ff                	test   %edi,%edi
  80264d:	89 fd                	mov    %edi,%ebp
  80264f:	75 0b                	jne    80265c <__udivdi3+0x3c>
  802651:	b8 01 00 00 00       	mov    $0x1,%eax
  802656:	31 d2                	xor    %edx,%edx
  802658:	f7 f7                	div    %edi
  80265a:	89 c5                	mov    %eax,%ebp
  80265c:	89 c8                	mov    %ecx,%eax
  80265e:	31 d2                	xor    %edx,%edx
  802660:	f7 f5                	div    %ebp
  802662:	89 c1                	mov    %eax,%ecx
  802664:	89 d8                	mov    %ebx,%eax
  802666:	89 cf                	mov    %ecx,%edi
  802668:	f7 f5                	div    %ebp
  80266a:	89 c3                	mov    %eax,%ebx
  80266c:	89 d8                	mov    %ebx,%eax
  80266e:	89 fa                	mov    %edi,%edx
  802670:	83 c4 1c             	add    $0x1c,%esp
  802673:	5b                   	pop    %ebx
  802674:	5e                   	pop    %esi
  802675:	5f                   	pop    %edi
  802676:	5d                   	pop    %ebp
  802677:	c3                   	ret    
  802678:	90                   	nop
  802679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802680:	39 ce                	cmp    %ecx,%esi
  802682:	77 74                	ja     8026f8 <__udivdi3+0xd8>
  802684:	0f bd fe             	bsr    %esi,%edi
  802687:	83 f7 1f             	xor    $0x1f,%edi
  80268a:	0f 84 98 00 00 00    	je     802728 <__udivdi3+0x108>
  802690:	bb 20 00 00 00       	mov    $0x20,%ebx
  802695:	89 f9                	mov    %edi,%ecx
  802697:	89 c5                	mov    %eax,%ebp
  802699:	29 fb                	sub    %edi,%ebx
  80269b:	d3 e6                	shl    %cl,%esi
  80269d:	89 d9                	mov    %ebx,%ecx
  80269f:	d3 ed                	shr    %cl,%ebp
  8026a1:	89 f9                	mov    %edi,%ecx
  8026a3:	d3 e0                	shl    %cl,%eax
  8026a5:	09 ee                	or     %ebp,%esi
  8026a7:	89 d9                	mov    %ebx,%ecx
  8026a9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8026ad:	89 d5                	mov    %edx,%ebp
  8026af:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026b3:	d3 ed                	shr    %cl,%ebp
  8026b5:	89 f9                	mov    %edi,%ecx
  8026b7:	d3 e2                	shl    %cl,%edx
  8026b9:	89 d9                	mov    %ebx,%ecx
  8026bb:	d3 e8                	shr    %cl,%eax
  8026bd:	09 c2                	or     %eax,%edx
  8026bf:	89 d0                	mov    %edx,%eax
  8026c1:	89 ea                	mov    %ebp,%edx
  8026c3:	f7 f6                	div    %esi
  8026c5:	89 d5                	mov    %edx,%ebp
  8026c7:	89 c3                	mov    %eax,%ebx
  8026c9:	f7 64 24 0c          	mull   0xc(%esp)
  8026cd:	39 d5                	cmp    %edx,%ebp
  8026cf:	72 10                	jb     8026e1 <__udivdi3+0xc1>
  8026d1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026d5:	89 f9                	mov    %edi,%ecx
  8026d7:	d3 e6                	shl    %cl,%esi
  8026d9:	39 c6                	cmp    %eax,%esi
  8026db:	73 07                	jae    8026e4 <__udivdi3+0xc4>
  8026dd:	39 d5                	cmp    %edx,%ebp
  8026df:	75 03                	jne    8026e4 <__udivdi3+0xc4>
  8026e1:	83 eb 01             	sub    $0x1,%ebx
  8026e4:	31 ff                	xor    %edi,%edi
  8026e6:	89 d8                	mov    %ebx,%eax
  8026e8:	89 fa                	mov    %edi,%edx
  8026ea:	83 c4 1c             	add    $0x1c,%esp
  8026ed:	5b                   	pop    %ebx
  8026ee:	5e                   	pop    %esi
  8026ef:	5f                   	pop    %edi
  8026f0:	5d                   	pop    %ebp
  8026f1:	c3                   	ret    
  8026f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026f8:	31 ff                	xor    %edi,%edi
  8026fa:	31 db                	xor    %ebx,%ebx
  8026fc:	89 d8                	mov    %ebx,%eax
  8026fe:	89 fa                	mov    %edi,%edx
  802700:	83 c4 1c             	add    $0x1c,%esp
  802703:	5b                   	pop    %ebx
  802704:	5e                   	pop    %esi
  802705:	5f                   	pop    %edi
  802706:	5d                   	pop    %ebp
  802707:	c3                   	ret    
  802708:	90                   	nop
  802709:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802710:	89 d8                	mov    %ebx,%eax
  802712:	f7 f7                	div    %edi
  802714:	31 ff                	xor    %edi,%edi
  802716:	89 c3                	mov    %eax,%ebx
  802718:	89 d8                	mov    %ebx,%eax
  80271a:	89 fa                	mov    %edi,%edx
  80271c:	83 c4 1c             	add    $0x1c,%esp
  80271f:	5b                   	pop    %ebx
  802720:	5e                   	pop    %esi
  802721:	5f                   	pop    %edi
  802722:	5d                   	pop    %ebp
  802723:	c3                   	ret    
  802724:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802728:	39 ce                	cmp    %ecx,%esi
  80272a:	72 0c                	jb     802738 <__udivdi3+0x118>
  80272c:	31 db                	xor    %ebx,%ebx
  80272e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802732:	0f 87 34 ff ff ff    	ja     80266c <__udivdi3+0x4c>
  802738:	bb 01 00 00 00       	mov    $0x1,%ebx
  80273d:	e9 2a ff ff ff       	jmp    80266c <__udivdi3+0x4c>
  802742:	66 90                	xchg   %ax,%ax
  802744:	66 90                	xchg   %ax,%ax
  802746:	66 90                	xchg   %ax,%ax
  802748:	66 90                	xchg   %ax,%ax
  80274a:	66 90                	xchg   %ax,%ax
  80274c:	66 90                	xchg   %ax,%ax
  80274e:	66 90                	xchg   %ax,%ax

00802750 <__umoddi3>:
  802750:	55                   	push   %ebp
  802751:	57                   	push   %edi
  802752:	56                   	push   %esi
  802753:	53                   	push   %ebx
  802754:	83 ec 1c             	sub    $0x1c,%esp
  802757:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80275b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80275f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802763:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802767:	85 d2                	test   %edx,%edx
  802769:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80276d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802771:	89 f3                	mov    %esi,%ebx
  802773:	89 3c 24             	mov    %edi,(%esp)
  802776:	89 74 24 04          	mov    %esi,0x4(%esp)
  80277a:	75 1c                	jne    802798 <__umoddi3+0x48>
  80277c:	39 f7                	cmp    %esi,%edi
  80277e:	76 50                	jbe    8027d0 <__umoddi3+0x80>
  802780:	89 c8                	mov    %ecx,%eax
  802782:	89 f2                	mov    %esi,%edx
  802784:	f7 f7                	div    %edi
  802786:	89 d0                	mov    %edx,%eax
  802788:	31 d2                	xor    %edx,%edx
  80278a:	83 c4 1c             	add    $0x1c,%esp
  80278d:	5b                   	pop    %ebx
  80278e:	5e                   	pop    %esi
  80278f:	5f                   	pop    %edi
  802790:	5d                   	pop    %ebp
  802791:	c3                   	ret    
  802792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802798:	39 f2                	cmp    %esi,%edx
  80279a:	89 d0                	mov    %edx,%eax
  80279c:	77 52                	ja     8027f0 <__umoddi3+0xa0>
  80279e:	0f bd ea             	bsr    %edx,%ebp
  8027a1:	83 f5 1f             	xor    $0x1f,%ebp
  8027a4:	75 5a                	jne    802800 <__umoddi3+0xb0>
  8027a6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8027aa:	0f 82 e0 00 00 00    	jb     802890 <__umoddi3+0x140>
  8027b0:	39 0c 24             	cmp    %ecx,(%esp)
  8027b3:	0f 86 d7 00 00 00    	jbe    802890 <__umoddi3+0x140>
  8027b9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027bd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027c1:	83 c4 1c             	add    $0x1c,%esp
  8027c4:	5b                   	pop    %ebx
  8027c5:	5e                   	pop    %esi
  8027c6:	5f                   	pop    %edi
  8027c7:	5d                   	pop    %ebp
  8027c8:	c3                   	ret    
  8027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027d0:	85 ff                	test   %edi,%edi
  8027d2:	89 fd                	mov    %edi,%ebp
  8027d4:	75 0b                	jne    8027e1 <__umoddi3+0x91>
  8027d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027db:	31 d2                	xor    %edx,%edx
  8027dd:	f7 f7                	div    %edi
  8027df:	89 c5                	mov    %eax,%ebp
  8027e1:	89 f0                	mov    %esi,%eax
  8027e3:	31 d2                	xor    %edx,%edx
  8027e5:	f7 f5                	div    %ebp
  8027e7:	89 c8                	mov    %ecx,%eax
  8027e9:	f7 f5                	div    %ebp
  8027eb:	89 d0                	mov    %edx,%eax
  8027ed:	eb 99                	jmp    802788 <__umoddi3+0x38>
  8027ef:	90                   	nop
  8027f0:	89 c8                	mov    %ecx,%eax
  8027f2:	89 f2                	mov    %esi,%edx
  8027f4:	83 c4 1c             	add    $0x1c,%esp
  8027f7:	5b                   	pop    %ebx
  8027f8:	5e                   	pop    %esi
  8027f9:	5f                   	pop    %edi
  8027fa:	5d                   	pop    %ebp
  8027fb:	c3                   	ret    
  8027fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802800:	8b 34 24             	mov    (%esp),%esi
  802803:	bf 20 00 00 00       	mov    $0x20,%edi
  802808:	89 e9                	mov    %ebp,%ecx
  80280a:	29 ef                	sub    %ebp,%edi
  80280c:	d3 e0                	shl    %cl,%eax
  80280e:	89 f9                	mov    %edi,%ecx
  802810:	89 f2                	mov    %esi,%edx
  802812:	d3 ea                	shr    %cl,%edx
  802814:	89 e9                	mov    %ebp,%ecx
  802816:	09 c2                	or     %eax,%edx
  802818:	89 d8                	mov    %ebx,%eax
  80281a:	89 14 24             	mov    %edx,(%esp)
  80281d:	89 f2                	mov    %esi,%edx
  80281f:	d3 e2                	shl    %cl,%edx
  802821:	89 f9                	mov    %edi,%ecx
  802823:	89 54 24 04          	mov    %edx,0x4(%esp)
  802827:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80282b:	d3 e8                	shr    %cl,%eax
  80282d:	89 e9                	mov    %ebp,%ecx
  80282f:	89 c6                	mov    %eax,%esi
  802831:	d3 e3                	shl    %cl,%ebx
  802833:	89 f9                	mov    %edi,%ecx
  802835:	89 d0                	mov    %edx,%eax
  802837:	d3 e8                	shr    %cl,%eax
  802839:	89 e9                	mov    %ebp,%ecx
  80283b:	09 d8                	or     %ebx,%eax
  80283d:	89 d3                	mov    %edx,%ebx
  80283f:	89 f2                	mov    %esi,%edx
  802841:	f7 34 24             	divl   (%esp)
  802844:	89 d6                	mov    %edx,%esi
  802846:	d3 e3                	shl    %cl,%ebx
  802848:	f7 64 24 04          	mull   0x4(%esp)
  80284c:	39 d6                	cmp    %edx,%esi
  80284e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802852:	89 d1                	mov    %edx,%ecx
  802854:	89 c3                	mov    %eax,%ebx
  802856:	72 08                	jb     802860 <__umoddi3+0x110>
  802858:	75 11                	jne    80286b <__umoddi3+0x11b>
  80285a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80285e:	73 0b                	jae    80286b <__umoddi3+0x11b>
  802860:	2b 44 24 04          	sub    0x4(%esp),%eax
  802864:	1b 14 24             	sbb    (%esp),%edx
  802867:	89 d1                	mov    %edx,%ecx
  802869:	89 c3                	mov    %eax,%ebx
  80286b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80286f:	29 da                	sub    %ebx,%edx
  802871:	19 ce                	sbb    %ecx,%esi
  802873:	89 f9                	mov    %edi,%ecx
  802875:	89 f0                	mov    %esi,%eax
  802877:	d3 e0                	shl    %cl,%eax
  802879:	89 e9                	mov    %ebp,%ecx
  80287b:	d3 ea                	shr    %cl,%edx
  80287d:	89 e9                	mov    %ebp,%ecx
  80287f:	d3 ee                	shr    %cl,%esi
  802881:	09 d0                	or     %edx,%eax
  802883:	89 f2                	mov    %esi,%edx
  802885:	83 c4 1c             	add    $0x1c,%esp
  802888:	5b                   	pop    %ebx
  802889:	5e                   	pop    %esi
  80288a:	5f                   	pop    %edi
  80288b:	5d                   	pop    %ebp
  80288c:	c3                   	ret    
  80288d:	8d 76 00             	lea    0x0(%esi),%esi
  802890:	29 f9                	sub    %edi,%ecx
  802892:	19 d6                	sbb    %edx,%esi
  802894:	89 74 24 04          	mov    %esi,0x4(%esp)
  802898:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80289c:	e9 18 ff ff ff       	jmp    8027b9 <__umoddi3+0x69>
