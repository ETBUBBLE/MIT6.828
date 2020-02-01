
obj/user/testpipe.debug：     文件格式 elf32-i386


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
  80002c:	e8 81 02 00 00       	call   8002b2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003b:	c7 05 04 30 80 00 20 	movl   $0x802420,0x803004
  800042:	24 80 00 

	if ((i = pipe(p)) < 0)
  800045:	8d 45 8c             	lea    -0x74(%ebp),%eax
  800048:	50                   	push   %eax
  800049:	e8 15 1c 00 00       	call   801c63 <pipe>
  80004e:	89 c6                	mov    %eax,%esi
  800050:	83 c4 10             	add    $0x10,%esp
  800053:	85 c0                	test   %eax,%eax
  800055:	79 12                	jns    800069 <umain+0x36>
		panic("pipe: %e", i);
  800057:	50                   	push   %eax
  800058:	68 2c 24 80 00       	push   $0x80242c
  80005d:	6a 0e                	push   $0xe
  80005f:	68 35 24 80 00       	push   $0x802435
  800064:	e8 a9 02 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800069:	e8 67 10 00 00       	call   8010d5 <fork>
  80006e:	89 c3                	mov    %eax,%ebx
  800070:	85 c0                	test   %eax,%eax
  800072:	79 12                	jns    800086 <umain+0x53>
		panic("fork: %e", i);
  800074:	56                   	push   %esi
  800075:	68 45 24 80 00       	push   $0x802445
  80007a:	6a 11                	push   $0x11
  80007c:	68 35 24 80 00       	push   $0x802435
  800081:	e8 8c 02 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800086:	85 c0                	test   %eax,%eax
  800088:	0f 85 b8 00 00 00    	jne    800146 <umain+0x113>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  80008e:	a1 04 40 80 00       	mov    0x804004,%eax
  800093:	8b 40 48             	mov    0x48(%eax),%eax
  800096:	83 ec 04             	sub    $0x4,%esp
  800099:	ff 75 90             	pushl  -0x70(%ebp)
  80009c:	50                   	push   %eax
  80009d:	68 4e 24 80 00       	push   $0x80244e
  8000a2:	e8 44 03 00 00       	call   8003eb <cprintf>
		close(p[1]);
  8000a7:	83 c4 04             	add    $0x4,%esp
  8000aa:	ff 75 90             	pushl  -0x70(%ebp)
  8000ad:	e8 70 13 00 00       	call   801422 <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  8000b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8000b7:	8b 40 48             	mov    0x48(%eax),%eax
  8000ba:	83 c4 0c             	add    $0xc,%esp
  8000bd:	ff 75 8c             	pushl  -0x74(%ebp)
  8000c0:	50                   	push   %eax
  8000c1:	68 6b 24 80 00       	push   $0x80246b
  8000c6:	e8 20 03 00 00       	call   8003eb <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000cb:	83 c4 0c             	add    $0xc,%esp
  8000ce:	6a 63                	push   $0x63
  8000d0:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000d3:	50                   	push   %eax
  8000d4:	ff 75 8c             	pushl  -0x74(%ebp)
  8000d7:	e8 13 15 00 00       	call   8015ef <readn>
  8000dc:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000de:	83 c4 10             	add    $0x10,%esp
  8000e1:	85 c0                	test   %eax,%eax
  8000e3:	79 12                	jns    8000f7 <umain+0xc4>
			panic("read: %e", i);
  8000e5:	50                   	push   %eax
  8000e6:	68 88 24 80 00       	push   $0x802488
  8000eb:	6a 19                	push   $0x19
  8000ed:	68 35 24 80 00       	push   $0x802435
  8000f2:	e8 1b 02 00 00       	call   800312 <_panic>
		buf[i] = 0;
  8000f7:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000fc:	83 ec 08             	sub    $0x8,%esp
  8000ff:	ff 35 00 30 80 00    	pushl  0x803000
  800105:	8d 45 94             	lea    -0x6c(%ebp),%eax
  800108:	50                   	push   %eax
  800109:	e8 8b 09 00 00       	call   800a99 <strcmp>
  80010e:	83 c4 10             	add    $0x10,%esp
  800111:	85 c0                	test   %eax,%eax
  800113:	75 12                	jne    800127 <umain+0xf4>
			cprintf("\npipe read closed properly\n");
  800115:	83 ec 0c             	sub    $0xc,%esp
  800118:	68 91 24 80 00       	push   $0x802491
  80011d:	e8 c9 02 00 00       	call   8003eb <cprintf>
  800122:	83 c4 10             	add    $0x10,%esp
  800125:	eb 15                	jmp    80013c <umain+0x109>
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
  800127:	83 ec 04             	sub    $0x4,%esp
  80012a:	8d 45 94             	lea    -0x6c(%ebp),%eax
  80012d:	50                   	push   %eax
  80012e:	56                   	push   %esi
  80012f:	68 ad 24 80 00       	push   $0x8024ad
  800134:	e8 b2 02 00 00       	call   8003eb <cprintf>
  800139:	83 c4 10             	add    $0x10,%esp
		exit();
  80013c:	e8 b7 01 00 00       	call   8002f8 <exit>
  800141:	e9 94 00 00 00       	jmp    8001da <umain+0x1a7>
	} else {
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  800146:	a1 04 40 80 00       	mov    0x804004,%eax
  80014b:	8b 40 48             	mov    0x48(%eax),%eax
  80014e:	83 ec 04             	sub    $0x4,%esp
  800151:	ff 75 8c             	pushl  -0x74(%ebp)
  800154:	50                   	push   %eax
  800155:	68 4e 24 80 00       	push   $0x80244e
  80015a:	e8 8c 02 00 00       	call   8003eb <cprintf>
		close(p[0]);
  80015f:	83 c4 04             	add    $0x4,%esp
  800162:	ff 75 8c             	pushl  -0x74(%ebp)
  800165:	e8 b8 12 00 00       	call   801422 <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  80016a:	a1 04 40 80 00       	mov    0x804004,%eax
  80016f:	8b 40 48             	mov    0x48(%eax),%eax
  800172:	83 c4 0c             	add    $0xc,%esp
  800175:	ff 75 90             	pushl  -0x70(%ebp)
  800178:	50                   	push   %eax
  800179:	68 c0 24 80 00       	push   $0x8024c0
  80017e:	e8 68 02 00 00       	call   8003eb <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800183:	83 c4 04             	add    $0x4,%esp
  800186:	ff 35 00 30 80 00    	pushl  0x803000
  80018c:	e8 25 08 00 00       	call   8009b6 <strlen>
  800191:	83 c4 0c             	add    $0xc,%esp
  800194:	50                   	push   %eax
  800195:	ff 35 00 30 80 00    	pushl  0x803000
  80019b:	ff 75 90             	pushl  -0x70(%ebp)
  80019e:	e8 95 14 00 00       	call   801638 <write>
  8001a3:	89 c6                	mov    %eax,%esi
  8001a5:	83 c4 04             	add    $0x4,%esp
  8001a8:	ff 35 00 30 80 00    	pushl  0x803000
  8001ae:	e8 03 08 00 00       	call   8009b6 <strlen>
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	39 c6                	cmp    %eax,%esi
  8001b8:	74 12                	je     8001cc <umain+0x199>
			panic("write: %e", i);
  8001ba:	56                   	push   %esi
  8001bb:	68 dd 24 80 00       	push   $0x8024dd
  8001c0:	6a 25                	push   $0x25
  8001c2:	68 35 24 80 00       	push   $0x802435
  8001c7:	e8 46 01 00 00       	call   800312 <_panic>
		close(p[1]);
  8001cc:	83 ec 0c             	sub    $0xc,%esp
  8001cf:	ff 75 90             	pushl  -0x70(%ebp)
  8001d2:	e8 4b 12 00 00       	call   801422 <close>
  8001d7:	83 c4 10             	add    $0x10,%esp
	}
	wait(pid);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	53                   	push   %ebx
  8001de:	e8 06 1c 00 00       	call   801de9 <wait>

	binaryname = "pipewriteeof";
  8001e3:	c7 05 04 30 80 00 e7 	movl   $0x8024e7,0x803004
  8001ea:	24 80 00 
	if ((i = pipe(p)) < 0)
  8001ed:	8d 45 8c             	lea    -0x74(%ebp),%eax
  8001f0:	89 04 24             	mov    %eax,(%esp)
  8001f3:	e8 6b 1a 00 00       	call   801c63 <pipe>
  8001f8:	89 c6                	mov    %eax,%esi
  8001fa:	83 c4 10             	add    $0x10,%esp
  8001fd:	85 c0                	test   %eax,%eax
  8001ff:	79 12                	jns    800213 <umain+0x1e0>
		panic("pipe: %e", i);
  800201:	50                   	push   %eax
  800202:	68 2c 24 80 00       	push   $0x80242c
  800207:	6a 2c                	push   $0x2c
  800209:	68 35 24 80 00       	push   $0x802435
  80020e:	e8 ff 00 00 00       	call   800312 <_panic>

	if ((pid = fork()) < 0)
  800213:	e8 bd 0e 00 00       	call   8010d5 <fork>
  800218:	89 c3                	mov    %eax,%ebx
  80021a:	85 c0                	test   %eax,%eax
  80021c:	79 12                	jns    800230 <umain+0x1fd>
		panic("fork: %e", i);
  80021e:	56                   	push   %esi
  80021f:	68 45 24 80 00       	push   $0x802445
  800224:	6a 2f                	push   $0x2f
  800226:	68 35 24 80 00       	push   $0x802435
  80022b:	e8 e2 00 00 00       	call   800312 <_panic>

	if (pid == 0) {
  800230:	85 c0                	test   %eax,%eax
  800232:	75 4a                	jne    80027e <umain+0x24b>
		close(p[0]);
  800234:	83 ec 0c             	sub    $0xc,%esp
  800237:	ff 75 8c             	pushl  -0x74(%ebp)
  80023a:	e8 e3 11 00 00       	call   801422 <close>
  80023f:	83 c4 10             	add    $0x10,%esp
		while (1) {
			cprintf(".");
  800242:	83 ec 0c             	sub    $0xc,%esp
  800245:	68 f4 24 80 00       	push   $0x8024f4
  80024a:	e8 9c 01 00 00       	call   8003eb <cprintf>
			if (write(p[1], "x", 1) != 1)
  80024f:	83 c4 0c             	add    $0xc,%esp
  800252:	6a 01                	push   $0x1
  800254:	68 f6 24 80 00       	push   $0x8024f6
  800259:	ff 75 90             	pushl  -0x70(%ebp)
  80025c:	e8 d7 13 00 00       	call   801638 <write>
  800261:	83 c4 10             	add    $0x10,%esp
  800264:	83 f8 01             	cmp    $0x1,%eax
  800267:	74 d9                	je     800242 <umain+0x20f>
				break;
		}
		cprintf("\npipe write closed properly\n");
  800269:	83 ec 0c             	sub    $0xc,%esp
  80026c:	68 f8 24 80 00       	push   $0x8024f8
  800271:	e8 75 01 00 00       	call   8003eb <cprintf>
		exit();
  800276:	e8 7d 00 00 00       	call   8002f8 <exit>
  80027b:	83 c4 10             	add    $0x10,%esp
	}
	close(p[0]);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	ff 75 8c             	pushl  -0x74(%ebp)
  800284:	e8 99 11 00 00       	call   801422 <close>
	close(p[1]);
  800289:	83 c4 04             	add    $0x4,%esp
  80028c:	ff 75 90             	pushl  -0x70(%ebp)
  80028f:	e8 8e 11 00 00       	call   801422 <close>
	wait(pid);
  800294:	89 1c 24             	mov    %ebx,(%esp)
  800297:	e8 4d 1b 00 00       	call   801de9 <wait>

	cprintf("pipe tests passed\n");
  80029c:	c7 04 24 15 25 80 00 	movl   $0x802515,(%esp)
  8002a3:	e8 43 01 00 00       	call   8003eb <cprintf>
}
  8002a8:	83 c4 10             	add    $0x10,%esp
  8002ab:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002ae:	5b                   	pop    %ebx
  8002af:	5e                   	pop    %esi
  8002b0:	5d                   	pop    %ebp
  8002b1:	c3                   	ret    

008002b2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	56                   	push   %esi
  8002b6:	53                   	push   %ebx
  8002b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002ba:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8002bd:	e8 f2 0a 00 00       	call   800db4 <sys_getenvid>
  8002c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002cf:	a3 04 40 80 00       	mov    %eax,0x804004

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8002d4:	85 db                	test   %ebx,%ebx
  8002d6:	7e 07                	jle    8002df <libmain+0x2d>
        binaryname = argv[0];
  8002d8:	8b 06                	mov    (%esi),%eax
  8002da:	a3 04 30 80 00       	mov    %eax,0x803004

    // call user main routine
    umain(argc, argv);
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	56                   	push   %esi
  8002e3:	53                   	push   %ebx
  8002e4:	e8 4a fd ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  8002e9:	e8 0a 00 00 00       	call   8002f8 <exit>
}
  8002ee:	83 c4 10             	add    $0x10,%esp
  8002f1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002f4:	5b                   	pop    %ebx
  8002f5:	5e                   	pop    %esi
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002fe:	e8 4a 11 00 00       	call   80144d <close_all>
	sys_env_destroy(0);
  800303:	83 ec 0c             	sub    $0xc,%esp
  800306:	6a 00                	push   $0x0
  800308:	e8 66 0a 00 00       	call   800d73 <sys_env_destroy>
}
  80030d:	83 c4 10             	add    $0x10,%esp
  800310:	c9                   	leave  
  800311:	c3                   	ret    

00800312 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800312:	55                   	push   %ebp
  800313:	89 e5                	mov    %esp,%ebp
  800315:	56                   	push   %esi
  800316:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800317:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80031a:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800320:	e8 8f 0a 00 00       	call   800db4 <sys_getenvid>
  800325:	83 ec 0c             	sub    $0xc,%esp
  800328:	ff 75 0c             	pushl  0xc(%ebp)
  80032b:	ff 75 08             	pushl  0x8(%ebp)
  80032e:	56                   	push   %esi
  80032f:	50                   	push   %eax
  800330:	68 78 25 80 00       	push   $0x802578
  800335:	e8 b1 00 00 00       	call   8003eb <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80033a:	83 c4 18             	add    $0x18,%esp
  80033d:	53                   	push   %ebx
  80033e:	ff 75 10             	pushl  0x10(%ebp)
  800341:	e8 54 00 00 00       	call   80039a <vcprintf>
	cprintf("\n");
  800346:	c7 04 24 69 24 80 00 	movl   $0x802469,(%esp)
  80034d:	e8 99 00 00 00       	call   8003eb <cprintf>
  800352:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800355:	cc                   	int3   
  800356:	eb fd                	jmp    800355 <_panic+0x43>

00800358 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	53                   	push   %ebx
  80035c:	83 ec 04             	sub    $0x4,%esp
  80035f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800362:	8b 13                	mov    (%ebx),%edx
  800364:	8d 42 01             	lea    0x1(%edx),%eax
  800367:	89 03                	mov    %eax,(%ebx)
  800369:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800370:	3d ff 00 00 00       	cmp    $0xff,%eax
  800375:	75 1a                	jne    800391 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800377:	83 ec 08             	sub    $0x8,%esp
  80037a:	68 ff 00 00 00       	push   $0xff
  80037f:	8d 43 08             	lea    0x8(%ebx),%eax
  800382:	50                   	push   %eax
  800383:	e8 ae 09 00 00       	call   800d36 <sys_cputs>
		b->idx = 0;
  800388:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038e:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800391:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800395:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003a3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003aa:	00 00 00 
	b.cnt = 0;
  8003ad:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b7:	ff 75 0c             	pushl  0xc(%ebp)
  8003ba:	ff 75 08             	pushl  0x8(%ebp)
  8003bd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	68 58 03 80 00       	push   $0x800358
  8003c9:	e8 1a 01 00 00       	call   8004e8 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003ce:	83 c4 08             	add    $0x8,%esp
  8003d1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dd:	50                   	push   %eax
  8003de:	e8 53 09 00 00       	call   800d36 <sys_cputs>

	return b.cnt;
}
  8003e3:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f1:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f4:	50                   	push   %eax
  8003f5:	ff 75 08             	pushl  0x8(%ebp)
  8003f8:	e8 9d ff ff ff       	call   80039a <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fd:	c9                   	leave  
  8003fe:	c3                   	ret    

008003ff <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ff:	55                   	push   %ebp
  800400:	89 e5                	mov    %esp,%ebp
  800402:	57                   	push   %edi
  800403:	56                   	push   %esi
  800404:	53                   	push   %ebx
  800405:	83 ec 1c             	sub    $0x1c,%esp
  800408:	89 c7                	mov    %eax,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
  80040f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800412:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800415:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800418:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800420:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800423:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800426:	39 d3                	cmp    %edx,%ebx
  800428:	72 05                	jb     80042f <printnum+0x30>
  80042a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042d:	77 45                	ja     800474 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042f:	83 ec 0c             	sub    $0xc,%esp
  800432:	ff 75 18             	pushl  0x18(%ebp)
  800435:	8b 45 14             	mov    0x14(%ebp),%eax
  800438:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043b:	53                   	push   %ebx
  80043c:	ff 75 10             	pushl  0x10(%ebp)
  80043f:	83 ec 08             	sub    $0x8,%esp
  800442:	ff 75 e4             	pushl  -0x1c(%ebp)
  800445:	ff 75 e0             	pushl  -0x20(%ebp)
  800448:	ff 75 dc             	pushl  -0x24(%ebp)
  80044b:	ff 75 d8             	pushl  -0x28(%ebp)
  80044e:	e8 2d 1d 00 00       	call   802180 <__udivdi3>
  800453:	83 c4 18             	add    $0x18,%esp
  800456:	52                   	push   %edx
  800457:	50                   	push   %eax
  800458:	89 f2                	mov    %esi,%edx
  80045a:	89 f8                	mov    %edi,%eax
  80045c:	e8 9e ff ff ff       	call   8003ff <printnum>
  800461:	83 c4 20             	add    $0x20,%esp
  800464:	eb 18                	jmp    80047e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800466:	83 ec 08             	sub    $0x8,%esp
  800469:	56                   	push   %esi
  80046a:	ff 75 18             	pushl  0x18(%ebp)
  80046d:	ff d7                	call   *%edi
  80046f:	83 c4 10             	add    $0x10,%esp
  800472:	eb 03                	jmp    800477 <printnum+0x78>
  800474:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800477:	83 eb 01             	sub    $0x1,%ebx
  80047a:	85 db                	test   %ebx,%ebx
  80047c:	7f e8                	jg     800466 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047e:	83 ec 08             	sub    $0x8,%esp
  800481:	56                   	push   %esi
  800482:	83 ec 04             	sub    $0x4,%esp
  800485:	ff 75 e4             	pushl  -0x1c(%ebp)
  800488:	ff 75 e0             	pushl  -0x20(%ebp)
  80048b:	ff 75 dc             	pushl  -0x24(%ebp)
  80048e:	ff 75 d8             	pushl  -0x28(%ebp)
  800491:	e8 1a 1e 00 00       	call   8022b0 <__umoddi3>
  800496:	83 c4 14             	add    $0x14,%esp
  800499:	0f be 80 9b 25 80 00 	movsbl 0x80259b(%eax),%eax
  8004a0:	50                   	push   %eax
  8004a1:	ff d7                	call   *%edi
}
  8004a3:	83 c4 10             	add    $0x10,%esp
  8004a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a9:	5b                   	pop    %ebx
  8004aa:	5e                   	pop    %esi
  8004ab:	5f                   	pop    %edi
  8004ac:	5d                   	pop    %ebp
  8004ad:	c3                   	ret    

008004ae <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ae:	55                   	push   %ebp
  8004af:	89 e5                	mov    %esp,%ebp
  8004b1:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b4:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004b8:	8b 10                	mov    (%eax),%edx
  8004ba:	3b 50 04             	cmp    0x4(%eax),%edx
  8004bd:	73 0a                	jae    8004c9 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004bf:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c2:	89 08                	mov    %ecx,(%eax)
  8004c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004c7:	88 02                	mov    %al,(%edx)
}
  8004c9:	5d                   	pop    %ebp
  8004ca:	c3                   	ret    

008004cb <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004cb:	55                   	push   %ebp
  8004cc:	89 e5                	mov    %esp,%ebp
  8004ce:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004d1:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004d4:	50                   	push   %eax
  8004d5:	ff 75 10             	pushl  0x10(%ebp)
  8004d8:	ff 75 0c             	pushl  0xc(%ebp)
  8004db:	ff 75 08             	pushl  0x8(%ebp)
  8004de:	e8 05 00 00 00       	call   8004e8 <vprintfmt>
	va_end(ap);
}
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	c9                   	leave  
  8004e7:	c3                   	ret    

008004e8 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8004e8:	55                   	push   %ebp
  8004e9:	89 e5                	mov    %esp,%ebp
  8004eb:	57                   	push   %edi
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	83 ec 2c             	sub    $0x2c,%esp
  8004f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8004f4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8004f7:	8b 7d 10             	mov    0x10(%ebp),%edi
  8004fa:	eb 12                	jmp    80050e <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8004fc:	85 c0                	test   %eax,%eax
  8004fe:	0f 84 42 04 00 00    	je     800946 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	53                   	push   %ebx
  800508:	50                   	push   %eax
  800509:	ff d6                	call   *%esi
  80050b:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80050e:	83 c7 01             	add    $0x1,%edi
  800511:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800515:	83 f8 25             	cmp    $0x25,%eax
  800518:	75 e2                	jne    8004fc <vprintfmt+0x14>
  80051a:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80051e:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  800525:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  80052c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800533:	b9 00 00 00 00       	mov    $0x0,%ecx
  800538:	eb 07                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80053a:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80053d:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800541:	8d 47 01             	lea    0x1(%edi),%eax
  800544:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800547:	0f b6 07             	movzbl (%edi),%eax
  80054a:	0f b6 d0             	movzbl %al,%edx
  80054d:	83 e8 23             	sub    $0x23,%eax
  800550:	3c 55                	cmp    $0x55,%al
  800552:	0f 87 d3 03 00 00    	ja     80092b <vprintfmt+0x443>
  800558:	0f b6 c0             	movzbl %al,%eax
  80055b:	ff 24 85 e0 26 80 00 	jmp    *0x8026e0(,%eax,4)
  800562:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800565:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800569:	eb d6                	jmp    800541 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80056e:	b8 00 00 00 00       	mov    $0x0,%eax
  800573:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800576:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800579:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80057d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800580:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800583:	83 f9 09             	cmp    $0x9,%ecx
  800586:	77 3f                	ja     8005c7 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800588:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80058b:	eb e9                	jmp    800576 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80058d:	8b 45 14             	mov    0x14(%ebp),%eax
  800590:	8b 00                	mov    (%eax),%eax
  800592:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800595:	8b 45 14             	mov    0x14(%ebp),%eax
  800598:	8d 40 04             	lea    0x4(%eax),%eax
  80059b:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80059e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005a1:	eb 2a                	jmp    8005cd <vprintfmt+0xe5>
  8005a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a6:	85 c0                	test   %eax,%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	0f 49 d0             	cmovns %eax,%edx
  8005b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005b6:	eb 89                	jmp    800541 <vprintfmt+0x59>
  8005b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005bb:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005c2:	e9 7a ff ff ff       	jmp    800541 <vprintfmt+0x59>
  8005c7:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005ca:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8005cd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d1:	0f 89 6a ff ff ff    	jns    800541 <vprintfmt+0x59>
				width = precision, precision = -1;
  8005d7:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005dd:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8005e4:	e9 58 ff ff ff       	jmp    800541 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8005e9:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005ec:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8005ef:	e9 4d ff ff ff       	jmp    800541 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8005f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005f7:	8d 78 04             	lea    0x4(%eax),%edi
  8005fa:	83 ec 08             	sub    $0x8,%esp
  8005fd:	53                   	push   %ebx
  8005fe:	ff 30                	pushl  (%eax)
  800600:	ff d6                	call   *%esi
			break;
  800602:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800605:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80060b:	e9 fe fe ff ff       	jmp    80050e <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800610:	8b 45 14             	mov    0x14(%ebp),%eax
  800613:	8d 78 04             	lea    0x4(%eax),%edi
  800616:	8b 00                	mov    (%eax),%eax
  800618:	99                   	cltd   
  800619:	31 d0                	xor    %edx,%eax
  80061b:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80061d:	83 f8 0f             	cmp    $0xf,%eax
  800620:	7f 0b                	jg     80062d <vprintfmt+0x145>
  800622:	8b 14 85 40 28 80 00 	mov    0x802840(,%eax,4),%edx
  800629:	85 d2                	test   %edx,%edx
  80062b:	75 1b                	jne    800648 <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  80062d:	50                   	push   %eax
  80062e:	68 b3 25 80 00       	push   $0x8025b3
  800633:	53                   	push   %ebx
  800634:	56                   	push   %esi
  800635:	e8 91 fe ff ff       	call   8004cb <printfmt>
  80063a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80063d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800640:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800643:	e9 c6 fe ff ff       	jmp    80050e <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  800648:	52                   	push   %edx
  800649:	68 19 2a 80 00       	push   $0x802a19
  80064e:	53                   	push   %ebx
  80064f:	56                   	push   %esi
  800650:	e8 76 fe ff ff       	call   8004cb <printfmt>
  800655:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800658:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80065b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80065e:	e9 ab fe ff ff       	jmp    80050e <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800663:	8b 45 14             	mov    0x14(%ebp),%eax
  800666:	83 c0 04             	add    $0x4,%eax
  800669:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80066c:	8b 45 14             	mov    0x14(%ebp),%eax
  80066f:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800671:	85 ff                	test   %edi,%edi
  800673:	b8 ac 25 80 00       	mov    $0x8025ac,%eax
  800678:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80067b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80067f:	0f 8e 94 00 00 00    	jle    800719 <vprintfmt+0x231>
  800685:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  800689:	0f 84 98 00 00 00    	je     800727 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	ff 75 d0             	pushl  -0x30(%ebp)
  800695:	57                   	push   %edi
  800696:	e8 33 03 00 00       	call   8009ce <strnlen>
  80069b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80069e:	29 c1                	sub    %eax,%ecx
  8006a0:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  8006a3:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006a6:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ad:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006b0:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006b2:	eb 0f                	jmp    8006c3 <vprintfmt+0x1db>
					putch(padc, putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	53                   	push   %ebx
  8006b8:	ff 75 e0             	pushl  -0x20(%ebp)
  8006bb:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bd:	83 ef 01             	sub    $0x1,%edi
  8006c0:	83 c4 10             	add    $0x10,%esp
  8006c3:	85 ff                	test   %edi,%edi
  8006c5:	7f ed                	jg     8006b4 <vprintfmt+0x1cc>
  8006c7:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006ca:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8006cd:	85 c9                	test   %ecx,%ecx
  8006cf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006d4:	0f 49 c1             	cmovns %ecx,%eax
  8006d7:	29 c1                	sub    %eax,%ecx
  8006d9:	89 75 08             	mov    %esi,0x8(%ebp)
  8006dc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8006df:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006e2:	89 cb                	mov    %ecx,%ebx
  8006e4:	eb 4d                	jmp    800733 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8006e6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006ea:	74 1b                	je     800707 <vprintfmt+0x21f>
  8006ec:	0f be c0             	movsbl %al,%eax
  8006ef:	83 e8 20             	sub    $0x20,%eax
  8006f2:	83 f8 5e             	cmp    $0x5e,%eax
  8006f5:	76 10                	jbe    800707 <vprintfmt+0x21f>
					putch('?', putdat);
  8006f7:	83 ec 08             	sub    $0x8,%esp
  8006fa:	ff 75 0c             	pushl  0xc(%ebp)
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff 55 08             	call   *0x8(%ebp)
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	eb 0d                	jmp    800714 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	ff 75 0c             	pushl  0xc(%ebp)
  80070d:	52                   	push   %edx
  80070e:	ff 55 08             	call   *0x8(%ebp)
  800711:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800714:	83 eb 01             	sub    $0x1,%ebx
  800717:	eb 1a                	jmp    800733 <vprintfmt+0x24b>
  800719:	89 75 08             	mov    %esi,0x8(%ebp)
  80071c:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80071f:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800722:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800725:	eb 0c                	jmp    800733 <vprintfmt+0x24b>
  800727:	89 75 08             	mov    %esi,0x8(%ebp)
  80072a:	8b 75 d0             	mov    -0x30(%ebp),%esi
  80072d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800730:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800733:	83 c7 01             	add    $0x1,%edi
  800736:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80073a:	0f be d0             	movsbl %al,%edx
  80073d:	85 d2                	test   %edx,%edx
  80073f:	74 23                	je     800764 <vprintfmt+0x27c>
  800741:	85 f6                	test   %esi,%esi
  800743:	78 a1                	js     8006e6 <vprintfmt+0x1fe>
  800745:	83 ee 01             	sub    $0x1,%esi
  800748:	79 9c                	jns    8006e6 <vprintfmt+0x1fe>
  80074a:	89 df                	mov    %ebx,%edi
  80074c:	8b 75 08             	mov    0x8(%ebp),%esi
  80074f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800752:	eb 18                	jmp    80076c <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800754:	83 ec 08             	sub    $0x8,%esp
  800757:	53                   	push   %ebx
  800758:	6a 20                	push   $0x20
  80075a:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80075c:	83 ef 01             	sub    $0x1,%edi
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	eb 08                	jmp    80076c <vprintfmt+0x284>
  800764:	89 df                	mov    %ebx,%edi
  800766:	8b 75 08             	mov    0x8(%ebp),%esi
  800769:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076c:	85 ff                	test   %edi,%edi
  80076e:	7f e4                	jg     800754 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800770:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800773:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800776:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800779:	e9 90 fd ff ff       	jmp    80050e <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80077e:	83 f9 01             	cmp    $0x1,%ecx
  800781:	7e 19                	jle    80079c <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800783:	8b 45 14             	mov    0x14(%ebp),%eax
  800786:	8b 50 04             	mov    0x4(%eax),%edx
  800789:	8b 00                	mov    (%eax),%eax
  80078b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80078e:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800791:	8b 45 14             	mov    0x14(%ebp),%eax
  800794:	8d 40 08             	lea    0x8(%eax),%eax
  800797:	89 45 14             	mov    %eax,0x14(%ebp)
  80079a:	eb 38                	jmp    8007d4 <vprintfmt+0x2ec>
	else if (lflag)
  80079c:	85 c9                	test   %ecx,%ecx
  80079e:	74 1b                	je     8007bb <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  8007a0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a3:	8b 00                	mov    (%eax),%eax
  8007a5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007a8:	89 c1                	mov    %eax,%ecx
  8007aa:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b3:	8d 40 04             	lea    0x4(%eax),%eax
  8007b6:	89 45 14             	mov    %eax,0x14(%ebp)
  8007b9:	eb 19                	jmp    8007d4 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  8007bb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007be:	8b 00                	mov    (%eax),%eax
  8007c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007c3:	89 c1                	mov    %eax,%ecx
  8007c5:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c8:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8007cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ce:	8d 40 04             	lea    0x4(%eax),%eax
  8007d1:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007d4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007d7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007da:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007df:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8007e3:	0f 89 0e 01 00 00    	jns    8008f7 <vprintfmt+0x40f>
				putch('-', putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	6a 2d                	push   $0x2d
  8007ef:	ff d6                	call   *%esi
				num = -(long long) num;
  8007f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007f4:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007f7:	f7 da                	neg    %edx
  8007f9:	83 d1 00             	adc    $0x0,%ecx
  8007fc:	f7 d9                	neg    %ecx
  8007fe:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800801:	b8 0a 00 00 00       	mov    $0xa,%eax
  800806:	e9 ec 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80080b:	83 f9 01             	cmp    $0x1,%ecx
  80080e:	7e 18                	jle    800828 <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8b 10                	mov    (%eax),%edx
  800815:	8b 48 04             	mov    0x4(%eax),%ecx
  800818:	8d 40 08             	lea    0x8(%eax),%eax
  80081b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80081e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800823:	e9 cf 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800828:	85 c9                	test   %ecx,%ecx
  80082a:	74 1a                	je     800846 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  80082c:	8b 45 14             	mov    0x14(%ebp),%eax
  80082f:	8b 10                	mov    (%eax),%edx
  800831:	b9 00 00 00 00       	mov    $0x0,%ecx
  800836:	8d 40 04             	lea    0x4(%eax),%eax
  800839:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  80083c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800841:	e9 b1 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800846:	8b 45 14             	mov    0x14(%ebp),%eax
  800849:	8b 10                	mov    (%eax),%edx
  80084b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800850:	8d 40 04             	lea    0x4(%eax),%eax
  800853:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800856:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085b:	e9 97 00 00 00       	jmp    8008f7 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 58                	push   $0x58
  800866:	ff d6                	call   *%esi
			putch('X', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 58                	push   $0x58
  80086e:	ff d6                	call   *%esi
			putch('X', putdat);
  800870:	83 c4 08             	add    $0x8,%esp
  800873:	53                   	push   %ebx
  800874:	6a 58                	push   $0x58
  800876:	ff d6                	call   *%esi
			break;
  800878:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80087b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  80087e:	e9 8b fc ff ff       	jmp    80050e <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800883:	83 ec 08             	sub    $0x8,%esp
  800886:	53                   	push   %ebx
  800887:	6a 30                	push   $0x30
  800889:	ff d6                	call   *%esi
			putch('x', putdat);
  80088b:	83 c4 08             	add    $0x8,%esp
  80088e:	53                   	push   %ebx
  80088f:	6a 78                	push   $0x78
  800891:	ff d6                	call   *%esi
			num = (unsigned long long)
  800893:	8b 45 14             	mov    0x14(%ebp),%eax
  800896:	8b 10                	mov    (%eax),%edx
  800898:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80089d:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8008a0:	8d 40 04             	lea    0x4(%eax),%eax
  8008a3:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  8008a6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008ab:	eb 4a                	jmp    8008f7 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008ad:	83 f9 01             	cmp    $0x1,%ecx
  8008b0:	7e 15                	jle    8008c7 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  8008b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8b 48 04             	mov    0x4(%eax),%ecx
  8008ba:	8d 40 08             	lea    0x8(%eax),%eax
  8008bd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008c0:	b8 10 00 00 00       	mov    $0x10,%eax
  8008c5:	eb 30                	jmp    8008f7 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	74 17                	je     8008e2 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  8008cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8008ce:	8b 10                	mov    (%eax),%edx
  8008d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008d5:	8d 40 04             	lea    0x4(%eax),%eax
  8008d8:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008db:	b8 10 00 00 00       	mov    $0x10,%eax
  8008e0:	eb 15                	jmp    8008f7 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  8008e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008ec:	8d 40 04             	lea    0x4(%eax),%eax
  8008ef:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f7:	83 ec 0c             	sub    $0xc,%esp
  8008fa:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  8008fe:	57                   	push   %edi
  8008ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800902:	50                   	push   %eax
  800903:	51                   	push   %ecx
  800904:	52                   	push   %edx
  800905:	89 da                	mov    %ebx,%edx
  800907:	89 f0                	mov    %esi,%eax
  800909:	e8 f1 fa ff ff       	call   8003ff <printnum>
			break;
  80090e:	83 c4 20             	add    $0x20,%esp
  800911:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800914:	e9 f5 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800919:	83 ec 08             	sub    $0x8,%esp
  80091c:	53                   	push   %ebx
  80091d:	52                   	push   %edx
  80091e:	ff d6                	call   *%esi
			break;
  800920:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800923:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800926:	e9 e3 fb ff ff       	jmp    80050e <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80092b:	83 ec 08             	sub    $0x8,%esp
  80092e:	53                   	push   %ebx
  80092f:	6a 25                	push   $0x25
  800931:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800933:	83 c4 10             	add    $0x10,%esp
  800936:	eb 03                	jmp    80093b <vprintfmt+0x453>
  800938:	83 ef 01             	sub    $0x1,%edi
  80093b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80093f:	75 f7                	jne    800938 <vprintfmt+0x450>
  800941:	e9 c8 fb ff ff       	jmp    80050e <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800946:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800949:	5b                   	pop    %ebx
  80094a:	5e                   	pop    %esi
  80094b:	5f                   	pop    %edi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 18             	sub    $0x18,%esp
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80095a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80095d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800961:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800964:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80096b:	85 c0                	test   %eax,%eax
  80096d:	74 26                	je     800995 <vsnprintf+0x47>
  80096f:	85 d2                	test   %edx,%edx
  800971:	7e 22                	jle    800995 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800973:	ff 75 14             	pushl  0x14(%ebp)
  800976:	ff 75 10             	pushl  0x10(%ebp)
  800979:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80097c:	50                   	push   %eax
  80097d:	68 ae 04 80 00       	push   $0x8004ae
  800982:	e8 61 fb ff ff       	call   8004e8 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800987:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80098a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80098d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	eb 05                	jmp    80099a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800995:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80099a:	c9                   	leave  
  80099b:	c3                   	ret    

0080099c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8009a2:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8009a5:	50                   	push   %eax
  8009a6:	ff 75 10             	pushl  0x10(%ebp)
  8009a9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ac:	ff 75 08             	pushl  0x8(%ebp)
  8009af:	e8 9a ff ff ff       	call   80094e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8009c1:	eb 03                	jmp    8009c6 <strlen+0x10>
		n++;
  8009c3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8009c6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ca:	75 f7                	jne    8009c3 <strlen+0xd>
		n++;
	return n;
}
  8009cc:	5d                   	pop    %ebp
  8009cd:	c3                   	ret    

008009ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009d4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009dc:	eb 03                	jmp    8009e1 <strnlen+0x13>
		n++;
  8009de:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009e1:	39 c2                	cmp    %eax,%edx
  8009e3:	74 08                	je     8009ed <strnlen+0x1f>
  8009e5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009e9:	75 f3                	jne    8009de <strnlen+0x10>
  8009eb:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009ef:	55                   	push   %ebp
  8009f0:	89 e5                	mov    %esp,%ebp
  8009f2:	53                   	push   %ebx
  8009f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009f9:	89 c2                	mov    %eax,%edx
  8009fb:	83 c2 01             	add    $0x1,%edx
  8009fe:	83 c1 01             	add    $0x1,%ecx
  800a01:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800a05:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a08:	84 db                	test   %bl,%bl
  800a0a:	75 ef                	jne    8009fb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800a0c:	5b                   	pop    %ebx
  800a0d:	5d                   	pop    %ebp
  800a0e:	c3                   	ret    

00800a0f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a0f:	55                   	push   %ebp
  800a10:	89 e5                	mov    %esp,%ebp
  800a12:	53                   	push   %ebx
  800a13:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a16:	53                   	push   %ebx
  800a17:	e8 9a ff ff ff       	call   8009b6 <strlen>
  800a1c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800a1f:	ff 75 0c             	pushl  0xc(%ebp)
  800a22:	01 d8                	add    %ebx,%eax
  800a24:	50                   	push   %eax
  800a25:	e8 c5 ff ff ff       	call   8009ef <strcpy>
	return dst;
}
  800a2a:	89 d8                	mov    %ebx,%eax
  800a2c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a2f:	c9                   	leave  
  800a30:	c3                   	ret    

00800a31 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 75 08             	mov    0x8(%ebp),%esi
  800a39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a3c:	89 f3                	mov    %esi,%ebx
  800a3e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a41:	89 f2                	mov    %esi,%edx
  800a43:	eb 0f                	jmp    800a54 <strncpy+0x23>
		*dst++ = *src;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	0f b6 01             	movzbl (%ecx),%eax
  800a4b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a4e:	80 39 01             	cmpb   $0x1,(%ecx)
  800a51:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a54:	39 da                	cmp    %ebx,%edx
  800a56:	75 ed                	jne    800a45 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a58:	89 f0                	mov    %esi,%eax
  800a5a:	5b                   	pop    %ebx
  800a5b:	5e                   	pop    %esi
  800a5c:	5d                   	pop    %ebp
  800a5d:	c3                   	ret    

00800a5e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a5e:	55                   	push   %ebp
  800a5f:	89 e5                	mov    %esp,%ebp
  800a61:	56                   	push   %esi
  800a62:	53                   	push   %ebx
  800a63:	8b 75 08             	mov    0x8(%ebp),%esi
  800a66:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a69:	8b 55 10             	mov    0x10(%ebp),%edx
  800a6c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a6e:	85 d2                	test   %edx,%edx
  800a70:	74 21                	je     800a93 <strlcpy+0x35>
  800a72:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a76:	89 f2                	mov    %esi,%edx
  800a78:	eb 09                	jmp    800a83 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a7a:	83 c2 01             	add    $0x1,%edx
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a83:	39 c2                	cmp    %eax,%edx
  800a85:	74 09                	je     800a90 <strlcpy+0x32>
  800a87:	0f b6 19             	movzbl (%ecx),%ebx
  800a8a:	84 db                	test   %bl,%bl
  800a8c:	75 ec                	jne    800a7a <strlcpy+0x1c>
  800a8e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a90:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a93:	29 f0                	sub    %esi,%eax
}
  800a95:	5b                   	pop    %ebx
  800a96:	5e                   	pop    %esi
  800a97:	5d                   	pop    %ebp
  800a98:	c3                   	ret    

00800a99 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a99:	55                   	push   %ebp
  800a9a:	89 e5                	mov    %esp,%ebp
  800a9c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a9f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800aa2:	eb 06                	jmp    800aaa <strcmp+0x11>
		p++, q++;
  800aa4:	83 c1 01             	add    $0x1,%ecx
  800aa7:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800aaa:	0f b6 01             	movzbl (%ecx),%eax
  800aad:	84 c0                	test   %al,%al
  800aaf:	74 04                	je     800ab5 <strcmp+0x1c>
  800ab1:	3a 02                	cmp    (%edx),%al
  800ab3:	74 ef                	je     800aa4 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800ab5:	0f b6 c0             	movzbl %al,%eax
  800ab8:	0f b6 12             	movzbl (%edx),%edx
  800abb:	29 d0                	sub    %edx,%eax
}
  800abd:	5d                   	pop    %ebp
  800abe:	c3                   	ret    

00800abf <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800abf:	55                   	push   %ebp
  800ac0:	89 e5                	mov    %esp,%ebp
  800ac2:	53                   	push   %ebx
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ac9:	89 c3                	mov    %eax,%ebx
  800acb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800ace:	eb 06                	jmp    800ad6 <strncmp+0x17>
		n--, p++, q++;
  800ad0:	83 c0 01             	add    $0x1,%eax
  800ad3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ad6:	39 d8                	cmp    %ebx,%eax
  800ad8:	74 15                	je     800aef <strncmp+0x30>
  800ada:	0f b6 08             	movzbl (%eax),%ecx
  800add:	84 c9                	test   %cl,%cl
  800adf:	74 04                	je     800ae5 <strncmp+0x26>
  800ae1:	3a 0a                	cmp    (%edx),%cl
  800ae3:	74 eb                	je     800ad0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ae5:	0f b6 00             	movzbl (%eax),%eax
  800ae8:	0f b6 12             	movzbl (%edx),%edx
  800aeb:	29 d0                	sub    %edx,%eax
  800aed:	eb 05                	jmp    800af4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aef:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800af4:	5b                   	pop    %ebx
  800af5:	5d                   	pop    %ebp
  800af6:	c3                   	ret    

00800af7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800af7:	55                   	push   %ebp
  800af8:	89 e5                	mov    %esp,%ebp
  800afa:	8b 45 08             	mov    0x8(%ebp),%eax
  800afd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b01:	eb 07                	jmp    800b0a <strchr+0x13>
		if (*s == c)
  800b03:	38 ca                	cmp    %cl,%dl
  800b05:	74 0f                	je     800b16 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800b07:	83 c0 01             	add    $0x1,%eax
  800b0a:	0f b6 10             	movzbl (%eax),%edx
  800b0d:	84 d2                	test   %dl,%dl
  800b0f:	75 f2                	jne    800b03 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800b11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b22:	eb 03                	jmp    800b27 <strfind+0xf>
  800b24:	83 c0 01             	add    $0x1,%eax
  800b27:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b2a:	38 ca                	cmp    %cl,%dl
  800b2c:	74 04                	je     800b32 <strfind+0x1a>
  800b2e:	84 d2                	test   %dl,%dl
  800b30:	75 f2                	jne    800b24 <strfind+0xc>
			break;
	return (char *) s;
}
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    

00800b34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b34:	55                   	push   %ebp
  800b35:	89 e5                	mov    %esp,%ebp
  800b37:	57                   	push   %edi
  800b38:	56                   	push   %esi
  800b39:	53                   	push   %ebx
  800b3a:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b3d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b40:	85 c9                	test   %ecx,%ecx
  800b42:	74 36                	je     800b7a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b44:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b4a:	75 28                	jne    800b74 <memset+0x40>
  800b4c:	f6 c1 03             	test   $0x3,%cl
  800b4f:	75 23                	jne    800b74 <memset+0x40>
		c &= 0xFF;
  800b51:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b55:	89 d3                	mov    %edx,%ebx
  800b57:	c1 e3 08             	shl    $0x8,%ebx
  800b5a:	89 d6                	mov    %edx,%esi
  800b5c:	c1 e6 18             	shl    $0x18,%esi
  800b5f:	89 d0                	mov    %edx,%eax
  800b61:	c1 e0 10             	shl    $0x10,%eax
  800b64:	09 f0                	or     %esi,%eax
  800b66:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b68:	89 d8                	mov    %ebx,%eax
  800b6a:	09 d0                	or     %edx,%eax
  800b6c:	c1 e9 02             	shr    $0x2,%ecx
  800b6f:	fc                   	cld    
  800b70:	f3 ab                	rep stos %eax,%es:(%edi)
  800b72:	eb 06                	jmp    800b7a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b74:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b77:	fc                   	cld    
  800b78:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b7a:	89 f8                	mov    %edi,%eax
  800b7c:	5b                   	pop    %ebx
  800b7d:	5e                   	pop    %esi
  800b7e:	5f                   	pop    %edi
  800b7f:	5d                   	pop    %ebp
  800b80:	c3                   	ret    

00800b81 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b81:	55                   	push   %ebp
  800b82:	89 e5                	mov    %esp,%ebp
  800b84:	57                   	push   %edi
  800b85:	56                   	push   %esi
  800b86:	8b 45 08             	mov    0x8(%ebp),%eax
  800b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b8f:	39 c6                	cmp    %eax,%esi
  800b91:	73 35                	jae    800bc8 <memmove+0x47>
  800b93:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b96:	39 d0                	cmp    %edx,%eax
  800b98:	73 2e                	jae    800bc8 <memmove+0x47>
		s += n;
		d += n;
  800b9a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b9d:	89 d6                	mov    %edx,%esi
  800b9f:	09 fe                	or     %edi,%esi
  800ba1:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ba7:	75 13                	jne    800bbc <memmove+0x3b>
  800ba9:	f6 c1 03             	test   $0x3,%cl
  800bac:	75 0e                	jne    800bbc <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800bae:	83 ef 04             	sub    $0x4,%edi
  800bb1:	8d 72 fc             	lea    -0x4(%edx),%esi
  800bb4:	c1 e9 02             	shr    $0x2,%ecx
  800bb7:	fd                   	std    
  800bb8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bba:	eb 09                	jmp    800bc5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800bbc:	83 ef 01             	sub    $0x1,%edi
  800bbf:	8d 72 ff             	lea    -0x1(%edx),%esi
  800bc2:	fd                   	std    
  800bc3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800bc5:	fc                   	cld    
  800bc6:	eb 1d                	jmp    800be5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bc8:	89 f2                	mov    %esi,%edx
  800bca:	09 c2                	or     %eax,%edx
  800bcc:	f6 c2 03             	test   $0x3,%dl
  800bcf:	75 0f                	jne    800be0 <memmove+0x5f>
  800bd1:	f6 c1 03             	test   $0x3,%cl
  800bd4:	75 0a                	jne    800be0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800bd6:	c1 e9 02             	shr    $0x2,%ecx
  800bd9:	89 c7                	mov    %eax,%edi
  800bdb:	fc                   	cld    
  800bdc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800bde:	eb 05                	jmp    800be5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800be0:	89 c7                	mov    %eax,%edi
  800be2:	fc                   	cld    
  800be3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800be5:	5e                   	pop    %esi
  800be6:	5f                   	pop    %edi
  800be7:	5d                   	pop    %ebp
  800be8:	c3                   	ret    

00800be9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800be9:	55                   	push   %ebp
  800bea:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bec:	ff 75 10             	pushl  0x10(%ebp)
  800bef:	ff 75 0c             	pushl  0xc(%ebp)
  800bf2:	ff 75 08             	pushl  0x8(%ebp)
  800bf5:	e8 87 ff ff ff       	call   800b81 <memmove>
}
  800bfa:	c9                   	leave  
  800bfb:	c3                   	ret    

00800bfc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bfc:	55                   	push   %ebp
  800bfd:	89 e5                	mov    %esp,%ebp
  800bff:	56                   	push   %esi
  800c00:	53                   	push   %ebx
  800c01:	8b 45 08             	mov    0x8(%ebp),%eax
  800c04:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c07:	89 c6                	mov    %eax,%esi
  800c09:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c0c:	eb 1a                	jmp    800c28 <memcmp+0x2c>
		if (*s1 != *s2)
  800c0e:	0f b6 08             	movzbl (%eax),%ecx
  800c11:	0f b6 1a             	movzbl (%edx),%ebx
  800c14:	38 d9                	cmp    %bl,%cl
  800c16:	74 0a                	je     800c22 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800c18:	0f b6 c1             	movzbl %cl,%eax
  800c1b:	0f b6 db             	movzbl %bl,%ebx
  800c1e:	29 d8                	sub    %ebx,%eax
  800c20:	eb 0f                	jmp    800c31 <memcmp+0x35>
		s1++, s2++;
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c28:	39 f0                	cmp    %esi,%eax
  800c2a:	75 e2                	jne    800c0e <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800c2c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c31:	5b                   	pop    %ebx
  800c32:	5e                   	pop    %esi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	53                   	push   %ebx
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3c:	89 c1                	mov    %eax,%ecx
  800c3e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c41:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c45:	eb 0a                	jmp    800c51 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c47:	0f b6 10             	movzbl (%eax),%edx
  800c4a:	39 da                	cmp    %ebx,%edx
  800c4c:	74 07                	je     800c55 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c4e:	83 c0 01             	add    $0x1,%eax
  800c51:	39 c8                	cmp    %ecx,%eax
  800c53:	72 f2                	jb     800c47 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c55:	5b                   	pop    %ebx
  800c56:	5d                   	pop    %ebp
  800c57:	c3                   	ret    

00800c58 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	57                   	push   %edi
  800c5c:	56                   	push   %esi
  800c5d:	53                   	push   %ebx
  800c5e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c61:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c64:	eb 03                	jmp    800c69 <strtol+0x11>
		s++;
  800c66:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c69:	0f b6 01             	movzbl (%ecx),%eax
  800c6c:	3c 20                	cmp    $0x20,%al
  800c6e:	74 f6                	je     800c66 <strtol+0xe>
  800c70:	3c 09                	cmp    $0x9,%al
  800c72:	74 f2                	je     800c66 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c74:	3c 2b                	cmp    $0x2b,%al
  800c76:	75 0a                	jne    800c82 <strtol+0x2a>
		s++;
  800c78:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c7b:	bf 00 00 00 00       	mov    $0x0,%edi
  800c80:	eb 11                	jmp    800c93 <strtol+0x3b>
  800c82:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c87:	3c 2d                	cmp    $0x2d,%al
  800c89:	75 08                	jne    800c93 <strtol+0x3b>
		s++, neg = 1;
  800c8b:	83 c1 01             	add    $0x1,%ecx
  800c8e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c93:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c99:	75 15                	jne    800cb0 <strtol+0x58>
  800c9b:	80 39 30             	cmpb   $0x30,(%ecx)
  800c9e:	75 10                	jne    800cb0 <strtol+0x58>
  800ca0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800ca4:	75 7c                	jne    800d22 <strtol+0xca>
		s += 2, base = 16;
  800ca6:	83 c1 02             	add    $0x2,%ecx
  800ca9:	bb 10 00 00 00       	mov    $0x10,%ebx
  800cae:	eb 16                	jmp    800cc6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800cb0:	85 db                	test   %ebx,%ebx
  800cb2:	75 12                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cb4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb9:	80 39 30             	cmpb   $0x30,(%ecx)
  800cbc:	75 08                	jne    800cc6 <strtol+0x6e>
		s++, base = 8;
  800cbe:	83 c1 01             	add    $0x1,%ecx
  800cc1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800cc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800ccb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cce:	0f b6 11             	movzbl (%ecx),%edx
  800cd1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cd4:	89 f3                	mov    %esi,%ebx
  800cd6:	80 fb 09             	cmp    $0x9,%bl
  800cd9:	77 08                	ja     800ce3 <strtol+0x8b>
			dig = *s - '0';
  800cdb:	0f be d2             	movsbl %dl,%edx
  800cde:	83 ea 30             	sub    $0x30,%edx
  800ce1:	eb 22                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800ce3:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ce6:	89 f3                	mov    %esi,%ebx
  800ce8:	80 fb 19             	cmp    $0x19,%bl
  800ceb:	77 08                	ja     800cf5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ced:	0f be d2             	movsbl %dl,%edx
  800cf0:	83 ea 57             	sub    $0x57,%edx
  800cf3:	eb 10                	jmp    800d05 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cf5:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cf8:	89 f3                	mov    %esi,%ebx
  800cfa:	80 fb 19             	cmp    $0x19,%bl
  800cfd:	77 16                	ja     800d15 <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cff:	0f be d2             	movsbl %dl,%edx
  800d02:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800d05:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d08:	7d 0b                	jge    800d15 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800d0a:	83 c1 01             	add    $0x1,%ecx
  800d0d:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d11:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800d13:	eb b9                	jmp    800cce <strtol+0x76>

	if (endptr)
  800d15:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d19:	74 0d                	je     800d28 <strtol+0xd0>
		*endptr = (char *) s;
  800d1b:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d1e:	89 0e                	mov    %ecx,(%esi)
  800d20:	eb 06                	jmp    800d28 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800d22:	85 db                	test   %ebx,%ebx
  800d24:	74 98                	je     800cbe <strtol+0x66>
  800d26:	eb 9e                	jmp    800cc6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800d28:	89 c2                	mov    %eax,%edx
  800d2a:	f7 da                	neg    %edx
  800d2c:	85 ff                	test   %edi,%edi
  800d2e:	0f 45 c2             	cmovne %edx,%eax
}
  800d31:	5b                   	pop    %ebx
  800d32:	5e                   	pop    %esi
  800d33:	5f                   	pop    %edi
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	57                   	push   %edi
  800d3a:	56                   	push   %esi
  800d3b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d41:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d44:	8b 55 08             	mov    0x8(%ebp),%edx
  800d47:	89 c3                	mov    %eax,%ebx
  800d49:	89 c7                	mov    %eax,%edi
  800d4b:	89 c6                	mov    %eax,%esi
  800d4d:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d4f:	5b                   	pop    %ebx
  800d50:	5e                   	pop    %esi
  800d51:	5f                   	pop    %edi
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_cgetc>:

int
sys_cgetc(void)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	57                   	push   %edi
  800d58:	56                   	push   %esi
  800d59:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d5f:	b8 01 00 00 00       	mov    $0x1,%eax
  800d64:	89 d1                	mov    %edx,%ecx
  800d66:	89 d3                	mov    %edx,%ebx
  800d68:	89 d7                	mov    %edx,%edi
  800d6a:	89 d6                	mov    %edx,%esi
  800d6c:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6e:	5b                   	pop    %ebx
  800d6f:	5e                   	pop    %esi
  800d70:	5f                   	pop    %edi
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
  800d76:	57                   	push   %edi
  800d77:	56                   	push   %esi
  800d78:	53                   	push   %ebx
  800d79:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d81:	b8 03 00 00 00       	mov    $0x3,%eax
  800d86:	8b 55 08             	mov    0x8(%ebp),%edx
  800d89:	89 cb                	mov    %ecx,%ebx
  800d8b:	89 cf                	mov    %ecx,%edi
  800d8d:	89 ce                	mov    %ecx,%esi
  800d8f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d91:	85 c0                	test   %eax,%eax
  800d93:	7e 17                	jle    800dac <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d95:	83 ec 0c             	sub    $0xc,%esp
  800d98:	50                   	push   %eax
  800d99:	6a 03                	push   $0x3
  800d9b:	68 9f 28 80 00       	push   $0x80289f
  800da0:	6a 23                	push   $0x23
  800da2:	68 bc 28 80 00       	push   $0x8028bc
  800da7:	e8 66 f5 ff ff       	call   800312 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800dac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800daf:	5b                   	pop    %ebx
  800db0:	5e                   	pop    %esi
  800db1:	5f                   	pop    %edi
  800db2:	5d                   	pop    %ebp
  800db3:	c3                   	ret    

00800db4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800db4:	55                   	push   %ebp
  800db5:	89 e5                	mov    %esp,%ebp
  800db7:	57                   	push   %edi
  800db8:	56                   	push   %esi
  800db9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dba:	ba 00 00 00 00       	mov    $0x0,%edx
  800dbf:	b8 02 00 00 00       	mov    $0x2,%eax
  800dc4:	89 d1                	mov    %edx,%ecx
  800dc6:	89 d3                	mov    %edx,%ebx
  800dc8:	89 d7                	mov    %edx,%edi
  800dca:	89 d6                	mov    %edx,%esi
  800dcc:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800dce:	5b                   	pop    %ebx
  800dcf:	5e                   	pop    %esi
  800dd0:	5f                   	pop    %edi
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <sys_yield>:

void
sys_yield(void)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	57                   	push   %edi
  800dd7:	56                   	push   %esi
  800dd8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd9:	ba 00 00 00 00       	mov    $0x0,%edx
  800dde:	b8 0b 00 00 00       	mov    $0xb,%eax
  800de3:	89 d1                	mov    %edx,%ecx
  800de5:	89 d3                	mov    %edx,%ebx
  800de7:	89 d7                	mov    %edx,%edi
  800de9:	89 d6                	mov    %edx,%esi
  800deb:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ded:	5b                   	pop    %ebx
  800dee:	5e                   	pop    %esi
  800def:	5f                   	pop    %edi
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	57                   	push   %edi
  800df6:	56                   	push   %esi
  800df7:	53                   	push   %ebx
  800df8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dfb:	be 00 00 00 00       	mov    $0x0,%esi
  800e00:	b8 04 00 00 00       	mov    $0x4,%eax
  800e05:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e08:	8b 55 08             	mov    0x8(%ebp),%edx
  800e0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0e:	89 f7                	mov    %esi,%edi
  800e10:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e12:	85 c0                	test   %eax,%eax
  800e14:	7e 17                	jle    800e2d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e16:	83 ec 0c             	sub    $0xc,%esp
  800e19:	50                   	push   %eax
  800e1a:	6a 04                	push   $0x4
  800e1c:	68 9f 28 80 00       	push   $0x80289f
  800e21:	6a 23                	push   $0x23
  800e23:	68 bc 28 80 00       	push   $0x8028bc
  800e28:	e8 e5 f4 ff ff       	call   800312 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800e2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5f                   	pop    %edi
  800e33:	5d                   	pop    %ebp
  800e34:	c3                   	ret    

00800e35 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e35:	55                   	push   %ebp
  800e36:	89 e5                	mov    %esp,%ebp
  800e38:	57                   	push   %edi
  800e39:	56                   	push   %esi
  800e3a:	53                   	push   %ebx
  800e3b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e3e:	b8 05 00 00 00       	mov    $0x5,%eax
  800e43:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e46:	8b 55 08             	mov    0x8(%ebp),%edx
  800e49:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e4c:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e4f:	8b 75 18             	mov    0x18(%ebp),%esi
  800e52:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e54:	85 c0                	test   %eax,%eax
  800e56:	7e 17                	jle    800e6f <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	50                   	push   %eax
  800e5c:	6a 05                	push   $0x5
  800e5e:	68 9f 28 80 00       	push   $0x80289f
  800e63:	6a 23                	push   $0x23
  800e65:	68 bc 28 80 00       	push   $0x8028bc
  800e6a:	e8 a3 f4 ff ff       	call   800312 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e72:	5b                   	pop    %ebx
  800e73:	5e                   	pop    %esi
  800e74:	5f                   	pop    %edi
  800e75:	5d                   	pop    %ebp
  800e76:	c3                   	ret    

00800e77 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e77:	55                   	push   %ebp
  800e78:	89 e5                	mov    %esp,%ebp
  800e7a:	57                   	push   %edi
  800e7b:	56                   	push   %esi
  800e7c:	53                   	push   %ebx
  800e7d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e80:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e85:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 df                	mov    %ebx,%edi
  800e92:	89 de                	mov    %ebx,%esi
  800e94:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e96:	85 c0                	test   %eax,%eax
  800e98:	7e 17                	jle    800eb1 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	50                   	push   %eax
  800e9e:	6a 06                	push   $0x6
  800ea0:	68 9f 28 80 00       	push   $0x80289f
  800ea5:	6a 23                	push   $0x23
  800ea7:	68 bc 28 80 00       	push   $0x8028bc
  800eac:	e8 61 f4 ff ff       	call   800312 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800eb4:	5b                   	pop    %ebx
  800eb5:	5e                   	pop    %esi
  800eb6:	5f                   	pop    %edi
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	57                   	push   %edi
  800ebd:	56                   	push   %esi
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec2:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec7:	b8 08 00 00 00       	mov    $0x8,%eax
  800ecc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecf:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed2:	89 df                	mov    %ebx,%edi
  800ed4:	89 de                	mov    %ebx,%esi
  800ed6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800ed8:	85 c0                	test   %eax,%eax
  800eda:	7e 17                	jle    800ef3 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edc:	83 ec 0c             	sub    $0xc,%esp
  800edf:	50                   	push   %eax
  800ee0:	6a 08                	push   $0x8
  800ee2:	68 9f 28 80 00       	push   $0x80289f
  800ee7:	6a 23                	push   $0x23
  800ee9:	68 bc 28 80 00       	push   $0x8028bc
  800eee:	e8 1f f4 ff ff       	call   800312 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ef6:	5b                   	pop    %ebx
  800ef7:	5e                   	pop    %esi
  800ef8:	5f                   	pop    %edi
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f04:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f09:	b8 09 00 00 00       	mov    $0x9,%eax
  800f0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f11:	8b 55 08             	mov    0x8(%ebp),%edx
  800f14:	89 df                	mov    %ebx,%edi
  800f16:	89 de                	mov    %ebx,%esi
  800f18:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	7e 17                	jle    800f35 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f1e:	83 ec 0c             	sub    $0xc,%esp
  800f21:	50                   	push   %eax
  800f22:	6a 09                	push   $0x9
  800f24:	68 9f 28 80 00       	push   $0x80289f
  800f29:	6a 23                	push   $0x23
  800f2b:	68 bc 28 80 00       	push   $0x8028bc
  800f30:	e8 dd f3 ff ff       	call   800312 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  800f35:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f38:	5b                   	pop    %ebx
  800f39:	5e                   	pop    %esi
  800f3a:	5f                   	pop    %edi
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f46:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f4b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f50:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f53:	8b 55 08             	mov    0x8(%ebp),%edx
  800f56:	89 df                	mov    %ebx,%edi
  800f58:	89 de                	mov    %ebx,%esi
  800f5a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f5c:	85 c0                	test   %eax,%eax
  800f5e:	7e 17                	jle    800f77 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	50                   	push   %eax
  800f64:	6a 0a                	push   $0xa
  800f66:	68 9f 28 80 00       	push   $0x80289f
  800f6b:	6a 23                	push   $0x23
  800f6d:	68 bc 28 80 00       	push   $0x8028bc
  800f72:	e8 9b f3 ff ff       	call   800312 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f7a:	5b                   	pop    %ebx
  800f7b:	5e                   	pop    %esi
  800f7c:	5f                   	pop    %edi
  800f7d:	5d                   	pop    %ebp
  800f7e:	c3                   	ret    

00800f7f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f7f:	55                   	push   %ebp
  800f80:	89 e5                	mov    %esp,%ebp
  800f82:	57                   	push   %edi
  800f83:	56                   	push   %esi
  800f84:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f85:	be 00 00 00 00       	mov    $0x0,%esi
  800f8a:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f92:	8b 55 08             	mov    0x8(%ebp),%edx
  800f95:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f98:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f9b:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f9d:	5b                   	pop    %ebx
  800f9e:	5e                   	pop    %esi
  800f9f:	5f                   	pop    %edi
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	57                   	push   %edi
  800fa6:	56                   	push   %esi
  800fa7:	53                   	push   %ebx
  800fa8:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fab:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fb5:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb8:	89 cb                	mov    %ecx,%ebx
  800fba:	89 cf                	mov    %ecx,%edi
  800fbc:	89 ce                	mov    %ecx,%esi
  800fbe:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800fc0:	85 c0                	test   %eax,%eax
  800fc2:	7e 17                	jle    800fdb <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	50                   	push   %eax
  800fc8:	6a 0d                	push   $0xd
  800fca:	68 9f 28 80 00       	push   $0x80289f
  800fcf:	6a 23                	push   $0x23
  800fd1:	68 bc 28 80 00       	push   $0x8028bc
  800fd6:	e8 37 f3 ff ff       	call   800312 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800fdb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800fde:	5b                   	pop    %ebx
  800fdf:	5e                   	pop    %esi
  800fe0:	5f                   	pop    %edi
  800fe1:	5d                   	pop    %ebp
  800fe2:	c3                   	ret    

00800fe3 <pgfault>:
// Custom page fault handler - if faulting page is copy-on-write,
// map in our own private writable copy.
//
static void
pgfault(struct UTrapframe *utf)
{
  800fe3:	55                   	push   %ebp
  800fe4:	89 e5                	mov    %esp,%ebp
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 04             	sub    $0x4,%esp
  800fea:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fed:	8b 18                	mov    (%eax),%ebx
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  800fef:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800ff3:	74 2d                	je     801022 <pgfault+0x3f>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  800ff5:	89 d8                	mov    %ebx,%eax
  800ff7:	c1 e8 16             	shr    $0x16,%eax
  800ffa:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801001:	a8 01                	test   $0x1,%al
  801003:	74 1d                	je     801022 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801005:	89 d8                	mov    %ebx,%eax
  801007:	c1 e8 0c             	shr    $0xc,%eax
  80100a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
  801011:	f6 c2 01             	test   $0x1,%dl
  801014:	74 0c                	je     801022 <pgfault+0x3f>
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
  801016:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	// Hint:
	//   Use the read-only page table mappings at uvpt
	//   (see <inc/memlayout.h>).

	// LAB 4: Your code here.
	if (!(
  80101d:	f6 c4 08             	test   $0x8,%ah
  801020:	75 14                	jne    801036 <pgfault+0x53>
        (err & FEC_WR) && (uvpd[PDX(addr)] & PTE_P) &&
        (uvpt[PGNUM(addr)] & PTE_P) && (uvpt[PGNUM(addr)] & PTE_COW)
	)) panic("Neither the fault is a write nor copy-on-write page.\n");
  801022:	83 ec 04             	sub    $0x4,%esp
  801025:	68 cc 28 80 00       	push   $0x8028cc
  80102a:	6a 1f                	push   $0x1f
  80102c:	68 02 29 80 00       	push   $0x802902
  801031:	e8 dc f2 ff ff       	call   800312 <_panic>
	// page to the old page's address.
	// Hint:
	//   You should make three system calls.

	// LAB 4: Your code here.
	if((r = sys_page_alloc(0, PFTEMP, PTE_U | PTE_P | PTE_W)) < 0){
  801036:	83 ec 04             	sub    $0x4,%esp
  801039:	6a 07                	push   $0x7
  80103b:	68 00 f0 7f 00       	push   $0x7ff000
  801040:	6a 00                	push   $0x0
  801042:	e8 ab fd ff ff       	call   800df2 <sys_page_alloc>
  801047:	83 c4 10             	add    $0x10,%esp
  80104a:	85 c0                	test   %eax,%eax
  80104c:	79 12                	jns    801060 <pgfault+0x7d>
		 panic("sys_page_alloc: %e\n", r);
  80104e:	50                   	push   %eax
  80104f:	68 0d 29 80 00       	push   $0x80290d
  801054:	6a 29                	push   $0x29
  801056:	68 02 29 80 00       	push   $0x802902
  80105b:	e8 b2 f2 ff ff       	call   800312 <_panic>
	}
	addr = ROUNDDOWN(addr, PGSIZE);
  801060:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memcpy((void *)PFTEMP, addr, PGSIZE);
  801066:	83 ec 04             	sub    $0x4,%esp
  801069:	68 00 10 00 00       	push   $0x1000
  80106e:	53                   	push   %ebx
  80106f:	68 00 f0 7f 00       	push   $0x7ff000
  801074:	e8 70 fb ff ff       	call   800be9 <memcpy>
	if ((r = sys_page_map(0, (void *)PFTEMP, 0, addr, PTE_P | PTE_U | PTE_W)) < 0)
  801079:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801080:	53                   	push   %ebx
  801081:	6a 00                	push   $0x0
  801083:	68 00 f0 7f 00       	push   $0x7ff000
  801088:	6a 00                	push   $0x0
  80108a:	e8 a6 fd ff ff       	call   800e35 <sys_page_map>
  80108f:	83 c4 20             	add    $0x20,%esp
  801092:	85 c0                	test   %eax,%eax
  801094:	79 12                	jns    8010a8 <pgfault+0xc5>
        panic("sys_page_map: %e\n", r);
  801096:	50                   	push   %eax
  801097:	68 21 29 80 00       	push   $0x802921
  80109c:	6a 2e                	push   $0x2e
  80109e:	68 02 29 80 00       	push   $0x802902
  8010a3:	e8 6a f2 ff ff       	call   800312 <_panic>
    if ((r = sys_page_unmap(0, (void *)PFTEMP)) < 0)
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	68 00 f0 7f 00       	push   $0x7ff000
  8010b0:	6a 00                	push   $0x0
  8010b2:	e8 c0 fd ff ff       	call   800e77 <sys_page_unmap>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	79 12                	jns    8010d0 <pgfault+0xed>
        panic("sys_page_unmap: %e\n", r);
  8010be:	50                   	push   %eax
  8010bf:	68 33 29 80 00       	push   $0x802933
  8010c4:	6a 30                	push   $0x30
  8010c6:	68 02 29 80 00       	push   $0x802902
  8010cb:	e8 42 f2 ff ff       	call   800312 <_panic>
	//panic("pgfault not implemented");
}
  8010d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010d3:	c9                   	leave  
  8010d4:	c3                   	ret    

008010d5 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	57                   	push   %edi
  8010d9:	56                   	push   %esi
  8010da:	53                   	push   %ebx
  8010db:	83 ec 28             	sub    $0x28,%esp
	// LAB 4: Your code here.
	envid_t cenvid;
    unsigned pn;
    int r;
	set_pgfault_handler(pgfault);
  8010de:	68 e3 0f 80 00       	push   $0x800fe3
  8010e3:	e8 d3 0e 00 00       	call   801fbb <set_pgfault_handler>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010e8:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ed:	cd 30                	int    $0x30
  8010ef:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if ((cenvid = sys_exofork()) < 0){
  8010f2:	83 c4 10             	add    $0x10,%esp
  8010f5:	85 c0                	test   %eax,%eax
  8010f7:	79 14                	jns    80110d <fork+0x38>
		panic("sys_exofork failed");
  8010f9:	83 ec 04             	sub    $0x4,%esp
  8010fc:	68 47 29 80 00       	push   $0x802947
  801101:	6a 6f                	push   $0x6f
  801103:	68 02 29 80 00       	push   $0x802902
  801108:	e8 05 f2 ff ff       	call   800312 <_panic>
  80110d:	89 c7                	mov    %eax,%edi
		return cenvid;
	}
	if(cenvid>0){
  80110f:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  801113:	0f 8e 2b 01 00 00    	jle    801244 <fork+0x16f>
  801119:	bb 00 08 00 00       	mov    $0x800,%ebx
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
  80111e:	89 d8                	mov    %ebx,%eax
  801120:	c1 e8 0a             	shr    $0xa,%eax
  801123:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80112a:	a8 01                	test   $0x1,%al
  80112c:	0f 84 bf 00 00 00    	je     8011f1 <fork+0x11c>
  801132:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801139:	a8 01                	test   $0x1,%al
  80113b:	0f 84 b0 00 00 00    	je     8011f1 <fork+0x11c>
  801141:	89 de                	mov    %ebx,%esi
  801143:	c1 e6 0c             	shl    $0xc,%esi
{
	int r;

	// LAB 4: Your code here.
	void* vaddr=(void*)(pn*PGSIZE);
	if(uvpt[pn]&PTE_SHARE){
  801146:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80114d:	f6 c4 04             	test   $0x4,%ah
  801150:	74 29                	je     80117b <fork+0xa6>
		if((r=sys_page_map(0,vaddr,envid,vaddr,uvpt[pn]&PTE_SYSCALL))<0)return r;
  801152:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801159:	83 ec 0c             	sub    $0xc,%esp
  80115c:	25 07 0e 00 00       	and    $0xe07,%eax
  801161:	50                   	push   %eax
  801162:	56                   	push   %esi
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	6a 00                	push   $0x0
  801167:	e8 c9 fc ff ff       	call   800e35 <sys_page_map>
  80116c:	83 c4 20             	add    $0x20,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	ba 00 00 00 00       	mov    $0x0,%edx
  801176:	0f 4f c2             	cmovg  %edx,%eax
  801179:	eb 72                	jmp    8011ed <fork+0x118>
	}
	else if((uvpt[pn] & PTE_W) || (uvpt[pn] & PTE_COW)){
  80117b:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  801182:	a8 02                	test   $0x2,%al
  801184:	75 0c                	jne    801192 <fork+0xbd>
  801186:	8b 04 9d 00 00 40 ef 	mov    -0x10c00000(,%ebx,4),%eax
  80118d:	f6 c4 08             	test   $0x8,%ah
  801190:	74 3f                	je     8011d1 <fork+0xfc>
		if ((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  801192:	83 ec 0c             	sub    $0xc,%esp
  801195:	68 05 08 00 00       	push   $0x805
  80119a:	56                   	push   %esi
  80119b:	57                   	push   %edi
  80119c:	56                   	push   %esi
  80119d:	6a 00                	push   $0x0
  80119f:	e8 91 fc ff ff       	call   800e35 <sys_page_map>
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	85 c0                	test   %eax,%eax
  8011a9:	0f 88 b1 00 00 00    	js     801260 <fork+0x18b>
            return r;
        if ((r = sys_page_map(0, vaddr, 0, vaddr, PTE_P | PTE_U | PTE_COW)) < 0)
  8011af:	83 ec 0c             	sub    $0xc,%esp
  8011b2:	68 05 08 00 00       	push   $0x805
  8011b7:	56                   	push   %esi
  8011b8:	6a 00                	push   $0x0
  8011ba:	56                   	push   %esi
  8011bb:	6a 00                	push   $0x0
  8011bd:	e8 73 fc ff ff       	call   800e35 <sys_page_map>
  8011c2:	83 c4 20             	add    $0x20,%esp
  8011c5:	85 c0                	test   %eax,%eax
  8011c7:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011cc:	0f 4f c1             	cmovg  %ecx,%eax
  8011cf:	eb 1c                	jmp    8011ed <fork+0x118>
            return r;
	}
	else if((r = sys_page_map(0, vaddr, envid, vaddr, PTE_P | PTE_U)) < 0) {
  8011d1:	83 ec 0c             	sub    $0xc,%esp
  8011d4:	6a 05                	push   $0x5
  8011d6:	56                   	push   %esi
  8011d7:	57                   	push   %edi
  8011d8:	56                   	push   %esi
  8011d9:	6a 00                	push   $0x0
  8011db:	e8 55 fc ff ff       	call   800e35 <sys_page_map>
  8011e0:	83 c4 20             	add    $0x20,%esp
  8011e3:	85 c0                	test   %eax,%eax
  8011e5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ea:	0f 4f c1             	cmovg  %ecx,%eax
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
  8011ed:	85 c0                	test   %eax,%eax
  8011ef:	78 6f                	js     801260 <fork+0x18b>
	if ((cenvid = sys_exofork()) < 0){
		panic("sys_exofork failed");
		return cenvid;
	}
	if(cenvid>0){
		for (pn=PGNUM(UTEXT); pn<PGNUM(USTACKTOP); pn++){
  8011f1:	83 c3 01             	add    $0x1,%ebx
  8011f4:	81 fb fe eb 0e 00    	cmp    $0xeebfe,%ebx
  8011fa:	0f 85 1e ff ff ff    	jne    80111e <fork+0x49>
            if ((uvpd[pn >> 10] & PTE_P) && (uvpt[pn] & PTE_P))
                if ((r = duppage(cenvid, pn)) < 0)
                    return r;
		}
		if ((r = sys_page_alloc(cenvid, (void *)(UXSTACKTOP-PGSIZE), PTE_U | PTE_P | PTE_W)) < 0)
  801200:	83 ec 04             	sub    $0x4,%esp
  801203:	6a 07                	push   $0x7
  801205:	68 00 f0 bf ee       	push   $0xeebff000
  80120a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80120d:	57                   	push   %edi
  80120e:	e8 df fb ff ff       	call   800df2 <sys_page_alloc>
  801213:	83 c4 10             	add    $0x10,%esp
  801216:	85 c0                	test   %eax,%eax
  801218:	78 46                	js     801260 <fork+0x18b>
            return r;
		extern void _pgfault_upcall(void);
		if ((r = sys_env_set_pgfault_upcall(cenvid, _pgfault_upcall)) < 0)
  80121a:	83 ec 08             	sub    $0x8,%esp
  80121d:	68 1e 20 80 00       	push   $0x80201e
  801222:	57                   	push   %edi
  801223:	e8 15 fd ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	85 c0                	test   %eax,%eax
  80122d:	78 31                	js     801260 <fork+0x18b>
            return r;
		if ((r = sys_env_set_status(cenvid, ENV_RUNNABLE)) < 0)
  80122f:	83 ec 08             	sub    $0x8,%esp
  801232:	6a 02                	push   $0x2
  801234:	57                   	push   %edi
  801235:	e8 7f fc ff ff       	call   800eb9 <sys_env_set_status>
  80123a:	83 c4 10             	add    $0x10,%esp
            return r;
        return cenvid;
  80123d:	85 c0                	test   %eax,%eax
  80123f:	0f 49 c7             	cmovns %edi,%eax
  801242:	eb 1c                	jmp    801260 <fork+0x18b>
	}
	else {
		thisenv = &envs[ENVX(sys_getenvid())];
  801244:	e8 6b fb ff ff       	call   800db4 <sys_getenvid>
  801249:	25 ff 03 00 00       	and    $0x3ff,%eax
  80124e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801251:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801256:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80125b:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	//panic("fork not implemented");
	
}
  801260:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801263:	5b                   	pop    %ebx
  801264:	5e                   	pop    %esi
  801265:	5f                   	pop    %edi
  801266:	5d                   	pop    %ebp
  801267:	c3                   	ret    

00801268 <sfork>:

// Challenge!
int
sfork(void)
{
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80126e:	68 5a 29 80 00       	push   $0x80295a
  801273:	68 8d 00 00 00       	push   $0x8d
  801278:	68 02 29 80 00       	push   $0x802902
  80127d:	e8 90 f0 ff ff       	call   800312 <_panic>

00801282 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801282:	55                   	push   %ebp
  801283:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801285:	8b 45 08             	mov    0x8(%ebp),%eax
  801288:	05 00 00 00 30       	add    $0x30000000,%eax
  80128d:	c1 e8 0c             	shr    $0xc,%eax
}
  801290:	5d                   	pop    %ebp
  801291:	c3                   	ret    

00801292 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  801295:	8b 45 08             	mov    0x8(%ebp),%eax
  801298:	05 00 00 00 30       	add    $0x30000000,%eax
  80129d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8012a2:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012a7:	5d                   	pop    %ebp
  8012a8:	c3                   	ret    

008012a9 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012a9:	55                   	push   %ebp
  8012aa:	89 e5                	mov    %esp,%ebp
  8012ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012af:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012b4:	89 c2                	mov    %eax,%edx
  8012b6:	c1 ea 16             	shr    $0x16,%edx
  8012b9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012c0:	f6 c2 01             	test   $0x1,%dl
  8012c3:	74 11                	je     8012d6 <fd_alloc+0x2d>
  8012c5:	89 c2                	mov    %eax,%edx
  8012c7:	c1 ea 0c             	shr    $0xc,%edx
  8012ca:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8012d1:	f6 c2 01             	test   $0x1,%dl
  8012d4:	75 09                	jne    8012df <fd_alloc+0x36>
			*fd_store = fd;
  8012d6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8012d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012dd:	eb 17                	jmp    8012f6 <fd_alloc+0x4d>
  8012df:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8012e4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8012e9:	75 c9                	jne    8012b4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8012eb:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8012f1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    

008012f8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8012f8:	55                   	push   %ebp
  8012f9:	89 e5                	mov    %esp,%ebp
  8012fb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8012fe:	83 f8 1f             	cmp    $0x1f,%eax
  801301:	77 36                	ja     801339 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801303:	c1 e0 0c             	shl    $0xc,%eax
  801306:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80130b:	89 c2                	mov    %eax,%edx
  80130d:	c1 ea 16             	shr    $0x16,%edx
  801310:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801317:	f6 c2 01             	test   $0x1,%dl
  80131a:	74 24                	je     801340 <fd_lookup+0x48>
  80131c:	89 c2                	mov    %eax,%edx
  80131e:	c1 ea 0c             	shr    $0xc,%edx
  801321:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801328:	f6 c2 01             	test   $0x1,%dl
  80132b:	74 1a                	je     801347 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80132d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801330:	89 02                	mov    %eax,(%edx)
	return 0;
  801332:	b8 00 00 00 00       	mov    $0x0,%eax
  801337:	eb 13                	jmp    80134c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80133e:	eb 0c                	jmp    80134c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801340:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801345:	eb 05                	jmp    80134c <fd_lookup+0x54>
  801347:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80134c:	5d                   	pop    %ebp
  80134d:	c3                   	ret    

0080134e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801357:	ba f0 29 80 00       	mov    $0x8029f0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80135c:	eb 13                	jmp    801371 <dev_lookup+0x23>
  80135e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  801361:	39 08                	cmp    %ecx,(%eax)
  801363:	75 0c                	jne    801371 <dev_lookup+0x23>
			*dev = devtab[i];
  801365:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801368:	89 01                	mov    %eax,(%ecx)
			return 0;
  80136a:	b8 00 00 00 00       	mov    $0x0,%eax
  80136f:	eb 2e                	jmp    80139f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  801371:	8b 02                	mov    (%edx),%eax
  801373:	85 c0                	test   %eax,%eax
  801375:	75 e7                	jne    80135e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801377:	a1 04 40 80 00       	mov    0x804004,%eax
  80137c:	8b 40 48             	mov    0x48(%eax),%eax
  80137f:	83 ec 04             	sub    $0x4,%esp
  801382:	51                   	push   %ecx
  801383:	50                   	push   %eax
  801384:	68 70 29 80 00       	push   $0x802970
  801389:	e8 5d f0 ff ff       	call   8003eb <cprintf>
	*dev = 0;
  80138e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801391:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801397:	83 c4 10             	add    $0x10,%esp
  80139a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80139f:	c9                   	leave  
  8013a0:	c3                   	ret    

008013a1 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	56                   	push   %esi
  8013a5:	53                   	push   %ebx
  8013a6:	83 ec 10             	sub    $0x10,%esp
  8013a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8013ac:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013af:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013b2:	50                   	push   %eax
  8013b3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8013b9:	c1 e8 0c             	shr    $0xc,%eax
  8013bc:	50                   	push   %eax
  8013bd:	e8 36 ff ff ff       	call   8012f8 <fd_lookup>
  8013c2:	83 c4 08             	add    $0x8,%esp
  8013c5:	85 c0                	test   %eax,%eax
  8013c7:	78 05                	js     8013ce <fd_close+0x2d>
	    || fd != fd2)
  8013c9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8013cc:	74 0c                	je     8013da <fd_close+0x39>
		return (must_exist ? r : 0);
  8013ce:	84 db                	test   %bl,%bl
  8013d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8013d5:	0f 44 c2             	cmove  %edx,%eax
  8013d8:	eb 41                	jmp    80141b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8013da:	83 ec 08             	sub    $0x8,%esp
  8013dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e0:	50                   	push   %eax
  8013e1:	ff 36                	pushl  (%esi)
  8013e3:	e8 66 ff ff ff       	call   80134e <dev_lookup>
  8013e8:	89 c3                	mov    %eax,%ebx
  8013ea:	83 c4 10             	add    $0x10,%esp
  8013ed:	85 c0                	test   %eax,%eax
  8013ef:	78 1a                	js     80140b <fd_close+0x6a>
		if (dev->dev_close)
  8013f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013f4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8013f7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8013fc:	85 c0                	test   %eax,%eax
  8013fe:	74 0b                	je     80140b <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  801400:	83 ec 0c             	sub    $0xc,%esp
  801403:	56                   	push   %esi
  801404:	ff d0                	call   *%eax
  801406:	89 c3                	mov    %eax,%ebx
  801408:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80140b:	83 ec 08             	sub    $0x8,%esp
  80140e:	56                   	push   %esi
  80140f:	6a 00                	push   $0x0
  801411:	e8 61 fa ff ff       	call   800e77 <sys_page_unmap>
	return r;
  801416:	83 c4 10             	add    $0x10,%esp
  801419:	89 d8                	mov    %ebx,%eax
}
  80141b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80141e:	5b                   	pop    %ebx
  80141f:	5e                   	pop    %esi
  801420:	5d                   	pop    %ebp
  801421:	c3                   	ret    

00801422 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  801422:	55                   	push   %ebp
  801423:	89 e5                	mov    %esp,%ebp
  801425:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801428:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80142b:	50                   	push   %eax
  80142c:	ff 75 08             	pushl  0x8(%ebp)
  80142f:	e8 c4 fe ff ff       	call   8012f8 <fd_lookup>
  801434:	83 c4 08             	add    $0x8,%esp
  801437:	85 c0                	test   %eax,%eax
  801439:	78 10                	js     80144b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	6a 01                	push   $0x1
  801440:	ff 75 f4             	pushl  -0xc(%ebp)
  801443:	e8 59 ff ff ff       	call   8013a1 <fd_close>
  801448:	83 c4 10             	add    $0x10,%esp
}
  80144b:	c9                   	leave  
  80144c:	c3                   	ret    

0080144d <close_all>:

void
close_all(void)
{
  80144d:	55                   	push   %ebp
  80144e:	89 e5                	mov    %esp,%ebp
  801450:	53                   	push   %ebx
  801451:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801454:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801459:	83 ec 0c             	sub    $0xc,%esp
  80145c:	53                   	push   %ebx
  80145d:	e8 c0 ff ff ff       	call   801422 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  801462:	83 c3 01             	add    $0x1,%ebx
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	83 fb 20             	cmp    $0x20,%ebx
  80146b:	75 ec                	jne    801459 <close_all+0xc>
		close(i);
}
  80146d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	57                   	push   %edi
  801476:	56                   	push   %esi
  801477:	53                   	push   %ebx
  801478:	83 ec 2c             	sub    $0x2c,%esp
  80147b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80147e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801481:	50                   	push   %eax
  801482:	ff 75 08             	pushl  0x8(%ebp)
  801485:	e8 6e fe ff ff       	call   8012f8 <fd_lookup>
  80148a:	83 c4 08             	add    $0x8,%esp
  80148d:	85 c0                	test   %eax,%eax
  80148f:	0f 88 c1 00 00 00    	js     801556 <dup+0xe4>
		return r;
	close(newfdnum);
  801495:	83 ec 0c             	sub    $0xc,%esp
  801498:	56                   	push   %esi
  801499:	e8 84 ff ff ff       	call   801422 <close>

	newfd = INDEX2FD(newfdnum);
  80149e:	89 f3                	mov    %esi,%ebx
  8014a0:	c1 e3 0c             	shl    $0xc,%ebx
  8014a3:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8014a9:	83 c4 04             	add    $0x4,%esp
  8014ac:	ff 75 e4             	pushl  -0x1c(%ebp)
  8014af:	e8 de fd ff ff       	call   801292 <fd2data>
  8014b4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8014b6:	89 1c 24             	mov    %ebx,(%esp)
  8014b9:	e8 d4 fd ff ff       	call   801292 <fd2data>
  8014be:	83 c4 10             	add    $0x10,%esp
  8014c1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8014c4:	89 f8                	mov    %edi,%eax
  8014c6:	c1 e8 16             	shr    $0x16,%eax
  8014c9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8014d0:	a8 01                	test   $0x1,%al
  8014d2:	74 37                	je     80150b <dup+0x99>
  8014d4:	89 f8                	mov    %edi,%eax
  8014d6:	c1 e8 0c             	shr    $0xc,%eax
  8014d9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8014e0:	f6 c2 01             	test   $0x1,%dl
  8014e3:	74 26                	je     80150b <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8014e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8014ec:	83 ec 0c             	sub    $0xc,%esp
  8014ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8014f4:	50                   	push   %eax
  8014f5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8014f8:	6a 00                	push   $0x0
  8014fa:	57                   	push   %edi
  8014fb:	6a 00                	push   $0x0
  8014fd:	e8 33 f9 ff ff       	call   800e35 <sys_page_map>
  801502:	89 c7                	mov    %eax,%edi
  801504:	83 c4 20             	add    $0x20,%esp
  801507:	85 c0                	test   %eax,%eax
  801509:	78 2e                	js     801539 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80150b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80150e:	89 d0                	mov    %edx,%eax
  801510:	c1 e8 0c             	shr    $0xc,%eax
  801513:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80151a:	83 ec 0c             	sub    $0xc,%esp
  80151d:	25 07 0e 00 00       	and    $0xe07,%eax
  801522:	50                   	push   %eax
  801523:	53                   	push   %ebx
  801524:	6a 00                	push   $0x0
  801526:	52                   	push   %edx
  801527:	6a 00                	push   $0x0
  801529:	e8 07 f9 ff ff       	call   800e35 <sys_page_map>
  80152e:	89 c7                	mov    %eax,%edi
  801530:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  801533:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801535:	85 ff                	test   %edi,%edi
  801537:	79 1d                	jns    801556 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801539:	83 ec 08             	sub    $0x8,%esp
  80153c:	53                   	push   %ebx
  80153d:	6a 00                	push   $0x0
  80153f:	e8 33 f9 ff ff       	call   800e77 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801544:	83 c4 08             	add    $0x8,%esp
  801547:	ff 75 d4             	pushl  -0x2c(%ebp)
  80154a:	6a 00                	push   $0x0
  80154c:	e8 26 f9 ff ff       	call   800e77 <sys_page_unmap>
	return r;
  801551:	83 c4 10             	add    $0x10,%esp
  801554:	89 f8                	mov    %edi,%eax
}
  801556:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5f                   	pop    %edi
  80155c:	5d                   	pop    %ebp
  80155d:	c3                   	ret    

0080155e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	53                   	push   %ebx
  801562:	83 ec 14             	sub    $0x14,%esp
  801565:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	53                   	push   %ebx
  80156d:	e8 86 fd ff ff       	call   8012f8 <fd_lookup>
  801572:	83 c4 08             	add    $0x8,%esp
  801575:	89 c2                	mov    %eax,%edx
  801577:	85 c0                	test   %eax,%eax
  801579:	78 6d                	js     8015e8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	ff 30                	pushl  (%eax)
  801587:	e8 c2 fd ff ff       	call   80134e <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 4c                	js     8015df <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801593:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801596:	8b 42 08             	mov    0x8(%edx),%eax
  801599:	83 e0 03             	and    $0x3,%eax
  80159c:	83 f8 01             	cmp    $0x1,%eax
  80159f:	75 21                	jne    8015c2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8015a1:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a6:	8b 40 48             	mov    0x48(%eax),%eax
  8015a9:	83 ec 04             	sub    $0x4,%esp
  8015ac:	53                   	push   %ebx
  8015ad:	50                   	push   %eax
  8015ae:	68 b4 29 80 00       	push   $0x8029b4
  8015b3:	e8 33 ee ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  8015b8:	83 c4 10             	add    $0x10,%esp
  8015bb:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8015c0:	eb 26                	jmp    8015e8 <read+0x8a>
	}
	if (!dev->dev_read)
  8015c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8015c5:	8b 40 08             	mov    0x8(%eax),%eax
  8015c8:	85 c0                	test   %eax,%eax
  8015ca:	74 17                	je     8015e3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8015cc:	83 ec 04             	sub    $0x4,%esp
  8015cf:	ff 75 10             	pushl  0x10(%ebp)
  8015d2:	ff 75 0c             	pushl  0xc(%ebp)
  8015d5:	52                   	push   %edx
  8015d6:	ff d0                	call   *%eax
  8015d8:	89 c2                	mov    %eax,%edx
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	eb 09                	jmp    8015e8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015df:	89 c2                	mov    %eax,%edx
  8015e1:	eb 05                	jmp    8015e8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8015e3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8015e8:	89 d0                	mov    %edx,%eax
  8015ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ed:	c9                   	leave  
  8015ee:	c3                   	ret    

008015ef <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8015ef:	55                   	push   %ebp
  8015f0:	89 e5                	mov    %esp,%ebp
  8015f2:	57                   	push   %edi
  8015f3:	56                   	push   %esi
  8015f4:	53                   	push   %ebx
  8015f5:	83 ec 0c             	sub    $0xc,%esp
  8015f8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8015fb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8015fe:	bb 00 00 00 00       	mov    $0x0,%ebx
  801603:	eb 21                	jmp    801626 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801605:	83 ec 04             	sub    $0x4,%esp
  801608:	89 f0                	mov    %esi,%eax
  80160a:	29 d8                	sub    %ebx,%eax
  80160c:	50                   	push   %eax
  80160d:	89 d8                	mov    %ebx,%eax
  80160f:	03 45 0c             	add    0xc(%ebp),%eax
  801612:	50                   	push   %eax
  801613:	57                   	push   %edi
  801614:	e8 45 ff ff ff       	call   80155e <read>
		if (m < 0)
  801619:	83 c4 10             	add    $0x10,%esp
  80161c:	85 c0                	test   %eax,%eax
  80161e:	78 10                	js     801630 <readn+0x41>
			return m;
		if (m == 0)
  801620:	85 c0                	test   %eax,%eax
  801622:	74 0a                	je     80162e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801624:	01 c3                	add    %eax,%ebx
  801626:	39 f3                	cmp    %esi,%ebx
  801628:	72 db                	jb     801605 <readn+0x16>
  80162a:	89 d8                	mov    %ebx,%eax
  80162c:	eb 02                	jmp    801630 <readn+0x41>
  80162e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  801630:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801633:	5b                   	pop    %ebx
  801634:	5e                   	pop    %esi
  801635:	5f                   	pop    %edi
  801636:	5d                   	pop    %ebp
  801637:	c3                   	ret    

00801638 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801638:	55                   	push   %ebp
  801639:	89 e5                	mov    %esp,%ebp
  80163b:	53                   	push   %ebx
  80163c:	83 ec 14             	sub    $0x14,%esp
  80163f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801642:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801645:	50                   	push   %eax
  801646:	53                   	push   %ebx
  801647:	e8 ac fc ff ff       	call   8012f8 <fd_lookup>
  80164c:	83 c4 08             	add    $0x8,%esp
  80164f:	89 c2                	mov    %eax,%edx
  801651:	85 c0                	test   %eax,%eax
  801653:	78 68                	js     8016bd <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801655:	83 ec 08             	sub    $0x8,%esp
  801658:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80165b:	50                   	push   %eax
  80165c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80165f:	ff 30                	pushl  (%eax)
  801661:	e8 e8 fc ff ff       	call   80134e <dev_lookup>
  801666:	83 c4 10             	add    $0x10,%esp
  801669:	85 c0                	test   %eax,%eax
  80166b:	78 47                	js     8016b4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80166d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801670:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801674:	75 21                	jne    801697 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801676:	a1 04 40 80 00       	mov    0x804004,%eax
  80167b:	8b 40 48             	mov    0x48(%eax),%eax
  80167e:	83 ec 04             	sub    $0x4,%esp
  801681:	53                   	push   %ebx
  801682:	50                   	push   %eax
  801683:	68 d0 29 80 00       	push   $0x8029d0
  801688:	e8 5e ed ff ff       	call   8003eb <cprintf>
		return -E_INVAL;
  80168d:	83 c4 10             	add    $0x10,%esp
  801690:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801695:	eb 26                	jmp    8016bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801697:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80169a:	8b 52 0c             	mov    0xc(%edx),%edx
  80169d:	85 d2                	test   %edx,%edx
  80169f:	74 17                	je     8016b8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016a1:	83 ec 04             	sub    $0x4,%esp
  8016a4:	ff 75 10             	pushl  0x10(%ebp)
  8016a7:	ff 75 0c             	pushl  0xc(%ebp)
  8016aa:	50                   	push   %eax
  8016ab:	ff d2                	call   *%edx
  8016ad:	89 c2                	mov    %eax,%edx
  8016af:	83 c4 10             	add    $0x10,%esp
  8016b2:	eb 09                	jmp    8016bd <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016b4:	89 c2                	mov    %eax,%edx
  8016b6:	eb 05                	jmp    8016bd <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8016b8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8016bd:	89 d0                	mov    %edx,%eax
  8016bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8016ca:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8016cd:	50                   	push   %eax
  8016ce:	ff 75 08             	pushl  0x8(%ebp)
  8016d1:	e8 22 fc ff ff       	call   8012f8 <fd_lookup>
  8016d6:	83 c4 08             	add    $0x8,%esp
  8016d9:	85 c0                	test   %eax,%eax
  8016db:	78 0e                	js     8016eb <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8016dd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8016e0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016e3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8016e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016eb:	c9                   	leave  
  8016ec:	c3                   	ret    

008016ed <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8016ed:	55                   	push   %ebp
  8016ee:	89 e5                	mov    %esp,%ebp
  8016f0:	53                   	push   %ebx
  8016f1:	83 ec 14             	sub    $0x14,%esp
  8016f4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016f7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016fa:	50                   	push   %eax
  8016fb:	53                   	push   %ebx
  8016fc:	e8 f7 fb ff ff       	call   8012f8 <fd_lookup>
  801701:	83 c4 08             	add    $0x8,%esp
  801704:	89 c2                	mov    %eax,%edx
  801706:	85 c0                	test   %eax,%eax
  801708:	78 65                	js     80176f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80170a:	83 ec 08             	sub    $0x8,%esp
  80170d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801710:	50                   	push   %eax
  801711:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801714:	ff 30                	pushl  (%eax)
  801716:	e8 33 fc ff ff       	call   80134e <dev_lookup>
  80171b:	83 c4 10             	add    $0x10,%esp
  80171e:	85 c0                	test   %eax,%eax
  801720:	78 44                	js     801766 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801722:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801725:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801729:	75 21                	jne    80174c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80172b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801730:	8b 40 48             	mov    0x48(%eax),%eax
  801733:	83 ec 04             	sub    $0x4,%esp
  801736:	53                   	push   %ebx
  801737:	50                   	push   %eax
  801738:	68 90 29 80 00       	push   $0x802990
  80173d:	e8 a9 ec ff ff       	call   8003eb <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  801742:	83 c4 10             	add    $0x10,%esp
  801745:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80174a:	eb 23                	jmp    80176f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80174c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80174f:	8b 52 18             	mov    0x18(%edx),%edx
  801752:	85 d2                	test   %edx,%edx
  801754:	74 14                	je     80176a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801756:	83 ec 08             	sub    $0x8,%esp
  801759:	ff 75 0c             	pushl  0xc(%ebp)
  80175c:	50                   	push   %eax
  80175d:	ff d2                	call   *%edx
  80175f:	89 c2                	mov    %eax,%edx
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	eb 09                	jmp    80176f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801766:	89 c2                	mov    %eax,%edx
  801768:	eb 05                	jmp    80176f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80176a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80176f:	89 d0                	mov    %edx,%eax
  801771:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801774:	c9                   	leave  
  801775:	c3                   	ret    

00801776 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801776:	55                   	push   %ebp
  801777:	89 e5                	mov    %esp,%ebp
  801779:	53                   	push   %ebx
  80177a:	83 ec 14             	sub    $0x14,%esp
  80177d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801780:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801783:	50                   	push   %eax
  801784:	ff 75 08             	pushl  0x8(%ebp)
  801787:	e8 6c fb ff ff       	call   8012f8 <fd_lookup>
  80178c:	83 c4 08             	add    $0x8,%esp
  80178f:	89 c2                	mov    %eax,%edx
  801791:	85 c0                	test   %eax,%eax
  801793:	78 58                	js     8017ed <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801795:	83 ec 08             	sub    $0x8,%esp
  801798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80179b:	50                   	push   %eax
  80179c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179f:	ff 30                	pushl  (%eax)
  8017a1:	e8 a8 fb ff ff       	call   80134e <dev_lookup>
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	85 c0                	test   %eax,%eax
  8017ab:	78 37                	js     8017e4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8017ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017b0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8017b4:	74 32                	je     8017e8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8017b6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8017b9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8017c0:	00 00 00 
	stat->st_isdir = 0;
  8017c3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8017ca:	00 00 00 
	stat->st_dev = dev;
  8017cd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	53                   	push   %ebx
  8017d7:	ff 75 f0             	pushl  -0x10(%ebp)
  8017da:	ff 50 14             	call   *0x14(%eax)
  8017dd:	89 c2                	mov    %eax,%edx
  8017df:	83 c4 10             	add    $0x10,%esp
  8017e2:	eb 09                	jmp    8017ed <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e4:	89 c2                	mov    %eax,%edx
  8017e6:	eb 05                	jmp    8017ed <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8017e8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8017ed:	89 d0                	mov    %edx,%eax
  8017ef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017f2:	c9                   	leave  
  8017f3:	c3                   	ret    

008017f4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8017f4:	55                   	push   %ebp
  8017f5:	89 e5                	mov    %esp,%ebp
  8017f7:	56                   	push   %esi
  8017f8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8017f9:	83 ec 08             	sub    $0x8,%esp
  8017fc:	6a 00                	push   $0x0
  8017fe:	ff 75 08             	pushl  0x8(%ebp)
  801801:	e8 e3 01 00 00       	call   8019e9 <open>
  801806:	89 c3                	mov    %eax,%ebx
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	78 1b                	js     80182a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80180f:	83 ec 08             	sub    $0x8,%esp
  801812:	ff 75 0c             	pushl  0xc(%ebp)
  801815:	50                   	push   %eax
  801816:	e8 5b ff ff ff       	call   801776 <fstat>
  80181b:	89 c6                	mov    %eax,%esi
	close(fd);
  80181d:	89 1c 24             	mov    %ebx,(%esp)
  801820:	e8 fd fb ff ff       	call   801422 <close>
	return r;
  801825:	83 c4 10             	add    $0x10,%esp
  801828:	89 f0                	mov    %esi,%eax
}
  80182a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80182d:	5b                   	pop    %ebx
  80182e:	5e                   	pop    %esi
  80182f:	5d                   	pop    %ebp
  801830:	c3                   	ret    

00801831 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801831:	55                   	push   %ebp
  801832:	89 e5                	mov    %esp,%ebp
  801834:	56                   	push   %esi
  801835:	53                   	push   %ebx
  801836:	89 c6                	mov    %eax,%esi
  801838:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80183a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801841:	75 12                	jne    801855 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	6a 01                	push   $0x1
  801848:	e8 b2 08 00 00       	call   8020ff <ipc_find_env>
  80184d:	a3 00 40 80 00       	mov    %eax,0x804000
  801852:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801855:	6a 07                	push   $0x7
  801857:	68 00 50 80 00       	push   $0x805000
  80185c:	56                   	push   %esi
  80185d:	ff 35 00 40 80 00    	pushl  0x804000
  801863:	e8 43 08 00 00       	call   8020ab <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801868:	83 c4 0c             	add    $0xc,%esp
  80186b:	6a 00                	push   $0x0
  80186d:	53                   	push   %ebx
  80186e:	6a 00                	push   $0x0
  801870:	e8 cd 07 00 00       	call   802042 <ipc_recv>
}
  801875:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5d                   	pop    %ebp
  80187b:	c3                   	ret    

0080187c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801882:	8b 45 08             	mov    0x8(%ebp),%eax
  801885:	8b 40 0c             	mov    0xc(%eax),%eax
  801888:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80188d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801890:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801895:	ba 00 00 00 00       	mov    $0x0,%edx
  80189a:	b8 02 00 00 00       	mov    $0x2,%eax
  80189f:	e8 8d ff ff ff       	call   801831 <fsipc>
}
  8018a4:	c9                   	leave  
  8018a5:	c3                   	ret    

008018a6 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8018a6:	55                   	push   %ebp
  8018a7:	89 e5                	mov    %esp,%ebp
  8018a9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8018ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8018af:	8b 40 0c             	mov    0xc(%eax),%eax
  8018b2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8018b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8018bc:	b8 06 00 00 00       	mov    $0x6,%eax
  8018c1:	e8 6b ff ff ff       	call   801831 <fsipc>
}
  8018c6:	c9                   	leave  
  8018c7:	c3                   	ret    

008018c8 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8018c8:	55                   	push   %ebp
  8018c9:	89 e5                	mov    %esp,%ebp
  8018cb:	53                   	push   %ebx
  8018cc:	83 ec 04             	sub    $0x4,%esp
  8018cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 40 0c             	mov    0xc(%eax),%eax
  8018d8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8018dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8018e2:	b8 05 00 00 00       	mov    $0x5,%eax
  8018e7:	e8 45 ff ff ff       	call   801831 <fsipc>
  8018ec:	85 c0                	test   %eax,%eax
  8018ee:	78 2c                	js     80191c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8018f0:	83 ec 08             	sub    $0x8,%esp
  8018f3:	68 00 50 80 00       	push   $0x805000
  8018f8:	53                   	push   %ebx
  8018f9:	e8 f1 f0 ff ff       	call   8009ef <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8018fe:	a1 80 50 80 00       	mov    0x805080,%eax
  801903:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801909:	a1 84 50 80 00       	mov    0x805084,%eax
  80190e:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80191f:	c9                   	leave  
  801920:	c3                   	ret    

00801921 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801921:	55                   	push   %ebp
  801922:	89 e5                	mov    %esp,%ebp
  801924:	83 ec 0c             	sub    $0xc,%esp
  801927:	8b 45 10             	mov    0x10(%ebp),%eax
  80192a:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80192f:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801934:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801937:	8b 55 08             	mov    0x8(%ebp),%edx
  80193a:	8b 52 0c             	mov    0xc(%edx),%edx
  80193d:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801943:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801948:	50                   	push   %eax
  801949:	ff 75 0c             	pushl  0xc(%ebp)
  80194c:	68 08 50 80 00       	push   $0x805008
  801951:	e8 2b f2 ff ff       	call   800b81 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801956:	ba 00 00 00 00       	mov    $0x0,%edx
  80195b:	b8 04 00 00 00       	mov    $0x4,%eax
  801960:	e8 cc fe ff ff       	call   801831 <fsipc>
	//panic("devfile_write not implemented");
}
  801965:	c9                   	leave  
  801966:	c3                   	ret    

00801967 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801967:	55                   	push   %ebp
  801968:	89 e5                	mov    %esp,%ebp
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80196f:	8b 45 08             	mov    0x8(%ebp),%eax
  801972:	8b 40 0c             	mov    0xc(%eax),%eax
  801975:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  80197a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801980:	ba 00 00 00 00       	mov    $0x0,%edx
  801985:	b8 03 00 00 00       	mov    $0x3,%eax
  80198a:	e8 a2 fe ff ff       	call   801831 <fsipc>
  80198f:	89 c3                	mov    %eax,%ebx
  801991:	85 c0                	test   %eax,%eax
  801993:	78 4b                	js     8019e0 <devfile_read+0x79>
		return r;
	assert(r <= n);
  801995:	39 c6                	cmp    %eax,%esi
  801997:	73 16                	jae    8019af <devfile_read+0x48>
  801999:	68 00 2a 80 00       	push   $0x802a00
  80199e:	68 07 2a 80 00       	push   $0x802a07
  8019a3:	6a 7c                	push   $0x7c
  8019a5:	68 1c 2a 80 00       	push   $0x802a1c
  8019aa:	e8 63 e9 ff ff       	call   800312 <_panic>
	assert(r <= PGSIZE);
  8019af:	3d 00 10 00 00       	cmp    $0x1000,%eax
  8019b4:	7e 16                	jle    8019cc <devfile_read+0x65>
  8019b6:	68 27 2a 80 00       	push   $0x802a27
  8019bb:	68 07 2a 80 00       	push   $0x802a07
  8019c0:	6a 7d                	push   $0x7d
  8019c2:	68 1c 2a 80 00       	push   $0x802a1c
  8019c7:	e8 46 e9 ff ff       	call   800312 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  8019cc:	83 ec 04             	sub    $0x4,%esp
  8019cf:	50                   	push   %eax
  8019d0:	68 00 50 80 00       	push   $0x805000
  8019d5:	ff 75 0c             	pushl  0xc(%ebp)
  8019d8:	e8 a4 f1 ff ff       	call   800b81 <memmove>
	return r;
  8019dd:	83 c4 10             	add    $0x10,%esp
}
  8019e0:	89 d8                	mov    %ebx,%eax
  8019e2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019e5:	5b                   	pop    %ebx
  8019e6:	5e                   	pop    %esi
  8019e7:	5d                   	pop    %ebp
  8019e8:	c3                   	ret    

008019e9 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  8019e9:	55                   	push   %ebp
  8019ea:	89 e5                	mov    %esp,%ebp
  8019ec:	53                   	push   %ebx
  8019ed:	83 ec 20             	sub    $0x20,%esp
  8019f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  8019f3:	53                   	push   %ebx
  8019f4:	e8 bd ef ff ff       	call   8009b6 <strlen>
  8019f9:	83 c4 10             	add    $0x10,%esp
  8019fc:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a01:	7f 67                	jg     801a6a <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a03:	83 ec 0c             	sub    $0xc,%esp
  801a06:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a09:	50                   	push   %eax
  801a0a:	e8 9a f8 ff ff       	call   8012a9 <fd_alloc>
  801a0f:	83 c4 10             	add    $0x10,%esp
		return r;
  801a12:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801a14:	85 c0                	test   %eax,%eax
  801a16:	78 57                	js     801a6f <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801a18:	83 ec 08             	sub    $0x8,%esp
  801a1b:	53                   	push   %ebx
  801a1c:	68 00 50 80 00       	push   $0x805000
  801a21:	e8 c9 ef ff ff       	call   8009ef <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a26:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a29:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a31:	b8 01 00 00 00       	mov    $0x1,%eax
  801a36:	e8 f6 fd ff ff       	call   801831 <fsipc>
  801a3b:	89 c3                	mov    %eax,%ebx
  801a3d:	83 c4 10             	add    $0x10,%esp
  801a40:	85 c0                	test   %eax,%eax
  801a42:	79 14                	jns    801a58 <open+0x6f>
		fd_close(fd, 0);
  801a44:	83 ec 08             	sub    $0x8,%esp
  801a47:	6a 00                	push   $0x0
  801a49:	ff 75 f4             	pushl  -0xc(%ebp)
  801a4c:	e8 50 f9 ff ff       	call   8013a1 <fd_close>
		return r;
  801a51:	83 c4 10             	add    $0x10,%esp
  801a54:	89 da                	mov    %ebx,%edx
  801a56:	eb 17                	jmp    801a6f <open+0x86>
	}

	return fd2num(fd);
  801a58:	83 ec 0c             	sub    $0xc,%esp
  801a5b:	ff 75 f4             	pushl  -0xc(%ebp)
  801a5e:	e8 1f f8 ff ff       	call   801282 <fd2num>
  801a63:	89 c2                	mov    %eax,%edx
  801a65:	83 c4 10             	add    $0x10,%esp
  801a68:	eb 05                	jmp    801a6f <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801a6a:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801a6f:	89 d0                	mov    %edx,%eax
  801a71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a74:	c9                   	leave  
  801a75:	c3                   	ret    

00801a76 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	b8 08 00 00 00       	mov    $0x8,%eax
  801a86:	e8 a6 fd ff ff       	call   801831 <fsipc>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801a8d:	55                   	push   %ebp
  801a8e:	89 e5                	mov    %esp,%ebp
  801a90:	56                   	push   %esi
  801a91:	53                   	push   %ebx
  801a92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	ff 75 08             	pushl  0x8(%ebp)
  801a9b:	e8 f2 f7 ff ff       	call   801292 <fd2data>
  801aa0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801aa2:	83 c4 08             	add    $0x8,%esp
  801aa5:	68 33 2a 80 00       	push   $0x802a33
  801aaa:	53                   	push   %ebx
  801aab:	e8 3f ef ff ff       	call   8009ef <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ab0:	8b 46 04             	mov    0x4(%esi),%eax
  801ab3:	2b 06                	sub    (%esi),%eax
  801ab5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801abb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ac2:	00 00 00 
	stat->st_dev = &devpipe;
  801ac5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801acc:	30 80 00 
	return 0;
}
  801acf:	b8 00 00 00 00       	mov    $0x0,%eax
  801ad4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ad7:	5b                   	pop    %ebx
  801ad8:	5e                   	pop    %esi
  801ad9:	5d                   	pop    %ebp
  801ada:	c3                   	ret    

00801adb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801adb:	55                   	push   %ebp
  801adc:	89 e5                	mov    %esp,%ebp
  801ade:	53                   	push   %ebx
  801adf:	83 ec 0c             	sub    $0xc,%esp
  801ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ae5:	53                   	push   %ebx
  801ae6:	6a 00                	push   $0x0
  801ae8:	e8 8a f3 ff ff       	call   800e77 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801aed:	89 1c 24             	mov    %ebx,(%esp)
  801af0:	e8 9d f7 ff ff       	call   801292 <fd2data>
  801af5:	83 c4 08             	add    $0x8,%esp
  801af8:	50                   	push   %eax
  801af9:	6a 00                	push   $0x0
  801afb:	e8 77 f3 ff ff       	call   800e77 <sys_page_unmap>
}
  801b00:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b03:	c9                   	leave  
  801b04:	c3                   	ret    

00801b05 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  801b05:	55                   	push   %ebp
  801b06:	89 e5                	mov    %esp,%ebp
  801b08:	57                   	push   %edi
  801b09:	56                   	push   %esi
  801b0a:	53                   	push   %ebx
  801b0b:	83 ec 1c             	sub    $0x1c,%esp
  801b0e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801b11:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  801b13:	a1 04 40 80 00       	mov    0x804004,%eax
  801b18:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801b1b:	83 ec 0c             	sub    $0xc,%esp
  801b1e:	ff 75 e0             	pushl  -0x20(%ebp)
  801b21:	e8 12 06 00 00       	call   802138 <pageref>
  801b26:	89 c3                	mov    %eax,%ebx
  801b28:	89 3c 24             	mov    %edi,(%esp)
  801b2b:	e8 08 06 00 00       	call   802138 <pageref>
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	39 c3                	cmp    %eax,%ebx
  801b35:	0f 94 c1             	sete   %cl
  801b38:	0f b6 c9             	movzbl %cl,%ecx
  801b3b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  801b3e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b44:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801b47:	39 ce                	cmp    %ecx,%esi
  801b49:	74 1b                	je     801b66 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  801b4b:	39 c3                	cmp    %eax,%ebx
  801b4d:	75 c4                	jne    801b13 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801b4f:	8b 42 58             	mov    0x58(%edx),%eax
  801b52:	ff 75 e4             	pushl  -0x1c(%ebp)
  801b55:	50                   	push   %eax
  801b56:	56                   	push   %esi
  801b57:	68 3a 2a 80 00       	push   $0x802a3a
  801b5c:	e8 8a e8 ff ff       	call   8003eb <cprintf>
  801b61:	83 c4 10             	add    $0x10,%esp
  801b64:	eb ad                	jmp    801b13 <_pipeisclosed+0xe>
	}
}
  801b66:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b6c:	5b                   	pop    %ebx
  801b6d:	5e                   	pop    %esi
  801b6e:	5f                   	pop    %edi
  801b6f:	5d                   	pop    %ebp
  801b70:	c3                   	ret    

00801b71 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801b71:	55                   	push   %ebp
  801b72:	89 e5                	mov    %esp,%ebp
  801b74:	57                   	push   %edi
  801b75:	56                   	push   %esi
  801b76:	53                   	push   %ebx
  801b77:	83 ec 28             	sub    $0x28,%esp
  801b7a:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  801b7d:	56                   	push   %esi
  801b7e:	e8 0f f7 ff ff       	call   801292 <fd2data>
  801b83:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801b85:	83 c4 10             	add    $0x10,%esp
  801b88:	bf 00 00 00 00       	mov    $0x0,%edi
  801b8d:	eb 4b                	jmp    801bda <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801b8f:	89 da                	mov    %ebx,%edx
  801b91:	89 f0                	mov    %esi,%eax
  801b93:	e8 6d ff ff ff       	call   801b05 <_pipeisclosed>
  801b98:	85 c0                	test   %eax,%eax
  801b9a:	75 48                	jne    801be4 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801b9c:	e8 32 f2 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ba1:	8b 43 04             	mov    0x4(%ebx),%eax
  801ba4:	8b 0b                	mov    (%ebx),%ecx
  801ba6:	8d 51 20             	lea    0x20(%ecx),%edx
  801ba9:	39 d0                	cmp    %edx,%eax
  801bab:	73 e2                	jae    801b8f <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801bad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bb0:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801bb4:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801bb7:	89 c2                	mov    %eax,%edx
  801bb9:	c1 fa 1f             	sar    $0x1f,%edx
  801bbc:	89 d1                	mov    %edx,%ecx
  801bbe:	c1 e9 1b             	shr    $0x1b,%ecx
  801bc1:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801bc4:	83 e2 1f             	and    $0x1f,%edx
  801bc7:	29 ca                	sub    %ecx,%edx
  801bc9:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801bcd:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801bd1:	83 c0 01             	add    $0x1,%eax
  801bd4:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801bd7:	83 c7 01             	add    $0x1,%edi
  801bda:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801bdd:	75 c2                	jne    801ba1 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801bdf:	8b 45 10             	mov    0x10(%ebp),%eax
  801be2:	eb 05                	jmp    801be9 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801be4:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801be9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bec:	5b                   	pop    %ebx
  801bed:	5e                   	pop    %esi
  801bee:	5f                   	pop    %edi
  801bef:	5d                   	pop    %ebp
  801bf0:	c3                   	ret    

00801bf1 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801bf1:	55                   	push   %ebp
  801bf2:	89 e5                	mov    %esp,%ebp
  801bf4:	57                   	push   %edi
  801bf5:	56                   	push   %esi
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 18             	sub    $0x18,%esp
  801bfa:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801bfd:	57                   	push   %edi
  801bfe:	e8 8f f6 ff ff       	call   801292 <fd2data>
  801c03:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c05:	83 c4 10             	add    $0x10,%esp
  801c08:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c0d:	eb 3d                	jmp    801c4c <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801c0f:	85 db                	test   %ebx,%ebx
  801c11:	74 04                	je     801c17 <devpipe_read+0x26>
				return i;
  801c13:	89 d8                	mov    %ebx,%eax
  801c15:	eb 44                	jmp    801c5b <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  801c17:	89 f2                	mov    %esi,%edx
  801c19:	89 f8                	mov    %edi,%eax
  801c1b:	e8 e5 fe ff ff       	call   801b05 <_pipeisclosed>
  801c20:	85 c0                	test   %eax,%eax
  801c22:	75 32                	jne    801c56 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  801c24:	e8 aa f1 ff ff       	call   800dd3 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  801c29:	8b 06                	mov    (%esi),%eax
  801c2b:	3b 46 04             	cmp    0x4(%esi),%eax
  801c2e:	74 df                	je     801c0f <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801c30:	99                   	cltd   
  801c31:	c1 ea 1b             	shr    $0x1b,%edx
  801c34:	01 d0                	add    %edx,%eax
  801c36:	83 e0 1f             	and    $0x1f,%eax
  801c39:	29 d0                	sub    %edx,%eax
  801c3b:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  801c40:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c43:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  801c46:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  801c49:	83 c3 01             	add    $0x1,%ebx
  801c4c:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  801c4f:	75 d8                	jne    801c29 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  801c51:	8b 45 10             	mov    0x10(%ebp),%eax
  801c54:	eb 05                	jmp    801c5b <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  801c5b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5f                   	pop    %edi
  801c61:	5d                   	pop    %ebp
  801c62:	c3                   	ret    

00801c63 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  801c63:	55                   	push   %ebp
  801c64:	89 e5                	mov    %esp,%ebp
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  801c6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c6e:	50                   	push   %eax
  801c6f:	e8 35 f6 ff ff       	call   8012a9 <fd_alloc>
  801c74:	83 c4 10             	add    $0x10,%esp
  801c77:	89 c2                	mov    %eax,%edx
  801c79:	85 c0                	test   %eax,%eax
  801c7b:	0f 88 2c 01 00 00    	js     801dad <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801c81:	83 ec 04             	sub    $0x4,%esp
  801c84:	68 07 04 00 00       	push   $0x407
  801c89:	ff 75 f4             	pushl  -0xc(%ebp)
  801c8c:	6a 00                	push   $0x0
  801c8e:	e8 5f f1 ff ff       	call   800df2 <sys_page_alloc>
  801c93:	83 c4 10             	add    $0x10,%esp
  801c96:	89 c2                	mov    %eax,%edx
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	0f 88 0d 01 00 00    	js     801dad <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801ca0:	83 ec 0c             	sub    $0xc,%esp
  801ca3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ca6:	50                   	push   %eax
  801ca7:	e8 fd f5 ff ff       	call   8012a9 <fd_alloc>
  801cac:	89 c3                	mov    %eax,%ebx
  801cae:	83 c4 10             	add    $0x10,%esp
  801cb1:	85 c0                	test   %eax,%eax
  801cb3:	0f 88 e2 00 00 00    	js     801d9b <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cb9:	83 ec 04             	sub    $0x4,%esp
  801cbc:	68 07 04 00 00       	push   $0x407
  801cc1:	ff 75 f0             	pushl  -0x10(%ebp)
  801cc4:	6a 00                	push   $0x0
  801cc6:	e8 27 f1 ff ff       	call   800df2 <sys_page_alloc>
  801ccb:	89 c3                	mov    %eax,%ebx
  801ccd:	83 c4 10             	add    $0x10,%esp
  801cd0:	85 c0                	test   %eax,%eax
  801cd2:	0f 88 c3 00 00 00    	js     801d9b <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801cd8:	83 ec 0c             	sub    $0xc,%esp
  801cdb:	ff 75 f4             	pushl  -0xc(%ebp)
  801cde:	e8 af f5 ff ff       	call   801292 <fd2data>
  801ce3:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ce5:	83 c4 0c             	add    $0xc,%esp
  801ce8:	68 07 04 00 00       	push   $0x407
  801ced:	50                   	push   %eax
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 fd f0 ff ff       	call   800df2 <sys_page_alloc>
  801cf5:	89 c3                	mov    %eax,%ebx
  801cf7:	83 c4 10             	add    $0x10,%esp
  801cfa:	85 c0                	test   %eax,%eax
  801cfc:	0f 88 89 00 00 00    	js     801d8b <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d02:	83 ec 0c             	sub    $0xc,%esp
  801d05:	ff 75 f0             	pushl  -0x10(%ebp)
  801d08:	e8 85 f5 ff ff       	call   801292 <fd2data>
  801d0d:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d14:	50                   	push   %eax
  801d15:	6a 00                	push   $0x0
  801d17:	56                   	push   %esi
  801d18:	6a 00                	push   $0x0
  801d1a:	e8 16 f1 ff ff       	call   800e35 <sys_page_map>
  801d1f:	89 c3                	mov    %eax,%ebx
  801d21:	83 c4 20             	add    $0x20,%esp
  801d24:	85 c0                	test   %eax,%eax
  801d26:	78 55                	js     801d7d <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  801d28:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d2e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d31:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  801d33:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801d36:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  801d3d:	8b 15 24 30 80 00    	mov    0x803024,%edx
  801d43:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d46:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  801d48:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801d4b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  801d52:	83 ec 0c             	sub    $0xc,%esp
  801d55:	ff 75 f4             	pushl  -0xc(%ebp)
  801d58:	e8 25 f5 ff ff       	call   801282 <fd2num>
  801d5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d60:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801d62:	83 c4 04             	add    $0x4,%esp
  801d65:	ff 75 f0             	pushl  -0x10(%ebp)
  801d68:	e8 15 f5 ff ff       	call   801282 <fd2num>
  801d6d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801d70:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	ba 00 00 00 00       	mov    $0x0,%edx
  801d7b:	eb 30                	jmp    801dad <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  801d7d:	83 ec 08             	sub    $0x8,%esp
  801d80:	56                   	push   %esi
  801d81:	6a 00                	push   $0x0
  801d83:	e8 ef f0 ff ff       	call   800e77 <sys_page_unmap>
  801d88:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801d8b:	83 ec 08             	sub    $0x8,%esp
  801d8e:	ff 75 f0             	pushl  -0x10(%ebp)
  801d91:	6a 00                	push   $0x0
  801d93:	e8 df f0 ff ff       	call   800e77 <sys_page_unmap>
  801d98:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801d9b:	83 ec 08             	sub    $0x8,%esp
  801d9e:	ff 75 f4             	pushl  -0xc(%ebp)
  801da1:	6a 00                	push   $0x0
  801da3:	e8 cf f0 ff ff       	call   800e77 <sys_page_unmap>
  801da8:	83 c4 10             	add    $0x10,%esp
  801dab:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801dad:	89 d0                	mov    %edx,%eax
  801daf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    

00801db6 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  801db6:	55                   	push   %ebp
  801db7:	89 e5                	mov    %esp,%ebp
  801db9:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801dbc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dbf:	50                   	push   %eax
  801dc0:	ff 75 08             	pushl  0x8(%ebp)
  801dc3:	e8 30 f5 ff ff       	call   8012f8 <fd_lookup>
  801dc8:	83 c4 10             	add    $0x10,%esp
  801dcb:	85 c0                	test   %eax,%eax
  801dcd:	78 18                	js     801de7 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801dcf:	83 ec 0c             	sub    $0xc,%esp
  801dd2:	ff 75 f4             	pushl  -0xc(%ebp)
  801dd5:	e8 b8 f4 ff ff       	call   801292 <fd2data>
	return _pipeisclosed(fd, p);
  801dda:	89 c2                	mov    %eax,%edx
  801ddc:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ddf:	e8 21 fd ff ff       	call   801b05 <_pipeisclosed>
  801de4:	83 c4 10             	add    $0x10,%esp
}
  801de7:	c9                   	leave  
  801de8:	c3                   	ret    

00801de9 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  801de9:	55                   	push   %ebp
  801dea:	89 e5                	mov    %esp,%ebp
  801dec:	56                   	push   %esi
  801ded:	53                   	push   %ebx
  801dee:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  801df1:	85 f6                	test   %esi,%esi
  801df3:	75 16                	jne    801e0b <wait+0x22>
  801df5:	68 52 2a 80 00       	push   $0x802a52
  801dfa:	68 07 2a 80 00       	push   $0x802a07
  801dff:	6a 09                	push   $0x9
  801e01:	68 5d 2a 80 00       	push   $0x802a5d
  801e06:	e8 07 e5 ff ff       	call   800312 <_panic>
	e = &envs[ENVX(envid)];
  801e0b:	89 f3                	mov    %esi,%ebx
  801e0d:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e13:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  801e16:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  801e1c:	eb 05                	jmp    801e23 <wait+0x3a>
		sys_yield();
  801e1e:	e8 b0 ef ff ff       	call   800dd3 <sys_yield>
{
	const volatile struct Env *e;

	assert(envid != 0);
	e = &envs[ENVX(envid)];
	while (e->env_id == envid && e->env_status != ENV_FREE)
  801e23:	8b 43 48             	mov    0x48(%ebx),%eax
  801e26:	39 c6                	cmp    %eax,%esi
  801e28:	75 07                	jne    801e31 <wait+0x48>
  801e2a:	8b 43 54             	mov    0x54(%ebx),%eax
  801e2d:	85 c0                	test   %eax,%eax
  801e2f:	75 ed                	jne    801e1e <wait+0x35>
		sys_yield();
}
  801e31:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e34:	5b                   	pop    %ebx
  801e35:	5e                   	pop    %esi
  801e36:	5d                   	pop    %ebp
  801e37:	c3                   	ret    

00801e38 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e38:	55                   	push   %ebp
  801e39:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801e3b:	b8 00 00 00 00       	mov    $0x0,%eax
  801e40:	5d                   	pop    %ebp
  801e41:	c3                   	ret    

00801e42 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e42:	55                   	push   %ebp
  801e43:	89 e5                	mov    %esp,%ebp
  801e45:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e48:	68 68 2a 80 00       	push   $0x802a68
  801e4d:	ff 75 0c             	pushl  0xc(%ebp)
  801e50:	e8 9a eb ff ff       	call   8009ef <strcpy>
	return 0;
}
  801e55:	b8 00 00 00 00       	mov    $0x0,%eax
  801e5a:	c9                   	leave  
  801e5b:	c3                   	ret    

00801e5c <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801e5c:	55                   	push   %ebp
  801e5d:	89 e5                	mov    %esp,%ebp
  801e5f:	57                   	push   %edi
  801e60:	56                   	push   %esi
  801e61:	53                   	push   %ebx
  801e62:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e68:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e6d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e73:	eb 2d                	jmp    801ea2 <devcons_write+0x46>
		m = n - tot;
  801e75:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801e78:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  801e7a:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  801e7d:	ba 7f 00 00 00       	mov    $0x7f,%edx
  801e82:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801e85:	83 ec 04             	sub    $0x4,%esp
  801e88:	53                   	push   %ebx
  801e89:	03 45 0c             	add    0xc(%ebp),%eax
  801e8c:	50                   	push   %eax
  801e8d:	57                   	push   %edi
  801e8e:	e8 ee ec ff ff       	call   800b81 <memmove>
		sys_cputs(buf, m);
  801e93:	83 c4 08             	add    $0x8,%esp
  801e96:	53                   	push   %ebx
  801e97:	57                   	push   %edi
  801e98:	e8 99 ee ff ff       	call   800d36 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801e9d:	01 de                	add    %ebx,%esi
  801e9f:	83 c4 10             	add    $0x10,%esp
  801ea2:	89 f0                	mov    %esi,%eax
  801ea4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea7:	72 cc                	jb     801e75 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  801ea9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801eac:	5b                   	pop    %ebx
  801ead:	5e                   	pop    %esi
  801eae:	5f                   	pop    %edi
  801eaf:	5d                   	pop    %ebp
  801eb0:	c3                   	ret    

00801eb1 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  801eb1:	55                   	push   %ebp
  801eb2:	89 e5                	mov    %esp,%ebp
  801eb4:	83 ec 08             	sub    $0x8,%esp
  801eb7:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  801ebc:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ec0:	74 2a                	je     801eec <devcons_read+0x3b>
  801ec2:	eb 05                	jmp    801ec9 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  801ec4:	e8 0a ef ff ff       	call   800dd3 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  801ec9:	e8 86 ee ff ff       	call   800d54 <sys_cgetc>
  801ece:	85 c0                	test   %eax,%eax
  801ed0:	74 f2                	je     801ec4 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  801ed2:	85 c0                	test   %eax,%eax
  801ed4:	78 16                	js     801eec <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  801ed6:	83 f8 04             	cmp    $0x4,%eax
  801ed9:	74 0c                	je     801ee7 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801edb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ede:	88 02                	mov    %al,(%edx)
	return 1;
  801ee0:	b8 01 00 00 00       	mov    $0x1,%eax
  801ee5:	eb 05                	jmp    801eec <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801ee7:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801eec:	c9                   	leave  
  801eed:	c3                   	ret    

00801eee <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801ef4:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef7:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801efa:	6a 01                	push   $0x1
  801efc:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801eff:	50                   	push   %eax
  801f00:	e8 31 ee ff ff       	call   800d36 <sys_cputs>
}
  801f05:	83 c4 10             	add    $0x10,%esp
  801f08:	c9                   	leave  
  801f09:	c3                   	ret    

00801f0a <getchar>:

int
getchar(void)
{
  801f0a:	55                   	push   %ebp
  801f0b:	89 e5                	mov    %esp,%ebp
  801f0d:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801f10:	6a 01                	push   $0x1
  801f12:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f15:	50                   	push   %eax
  801f16:	6a 00                	push   $0x0
  801f18:	e8 41 f6 ff ff       	call   80155e <read>
	if (r < 0)
  801f1d:	83 c4 10             	add    $0x10,%esp
  801f20:	85 c0                	test   %eax,%eax
  801f22:	78 0f                	js     801f33 <getchar+0x29>
		return r;
	if (r < 1)
  801f24:	85 c0                	test   %eax,%eax
  801f26:	7e 06                	jle    801f2e <getchar+0x24>
		return -E_EOF;
	return c;
  801f28:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801f2c:	eb 05                	jmp    801f33 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801f2e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  801f33:	c9                   	leave  
  801f34:	c3                   	ret    

00801f35 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  801f35:	55                   	push   %ebp
  801f36:	89 e5                	mov    %esp,%ebp
  801f38:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f3b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f3e:	50                   	push   %eax
  801f3f:	ff 75 08             	pushl  0x8(%ebp)
  801f42:	e8 b1 f3 ff ff       	call   8012f8 <fd_lookup>
  801f47:	83 c4 10             	add    $0x10,%esp
  801f4a:	85 c0                	test   %eax,%eax
  801f4c:	78 11                	js     801f5f <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f51:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f57:	39 10                	cmp    %edx,(%eax)
  801f59:	0f 94 c0             	sete   %al
  801f5c:	0f b6 c0             	movzbl %al,%eax
}
  801f5f:	c9                   	leave  
  801f60:	c3                   	ret    

00801f61 <opencons>:

int
opencons(void)
{
  801f61:	55                   	push   %ebp
  801f62:	89 e5                	mov    %esp,%ebp
  801f64:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f67:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f6a:	50                   	push   %eax
  801f6b:	e8 39 f3 ff ff       	call   8012a9 <fd_alloc>
  801f70:	83 c4 10             	add    $0x10,%esp
		return r;
  801f73:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801f75:	85 c0                	test   %eax,%eax
  801f77:	78 3e                	js     801fb7 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f79:	83 ec 04             	sub    $0x4,%esp
  801f7c:	68 07 04 00 00       	push   $0x407
  801f81:	ff 75 f4             	pushl  -0xc(%ebp)
  801f84:	6a 00                	push   $0x0
  801f86:	e8 67 ee ff ff       	call   800df2 <sys_page_alloc>
  801f8b:	83 c4 10             	add    $0x10,%esp
		return r;
  801f8e:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801f90:	85 c0                	test   %eax,%eax
  801f92:	78 23                	js     801fb7 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801f94:	8b 15 40 30 80 00    	mov    0x803040,%edx
  801f9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f9d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801f9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fa9:	83 ec 0c             	sub    $0xc,%esp
  801fac:	50                   	push   %eax
  801fad:	e8 d0 f2 ff ff       	call   801282 <fd2num>
  801fb2:	89 c2                	mov    %eax,%edx
  801fb4:	83 c4 10             	add    $0x10,%esp
}
  801fb7:	89 d0                	mov    %edx,%eax
  801fb9:	c9                   	leave  
  801fba:	c3                   	ret    

00801fbb <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801fbb:	55                   	push   %ebp
  801fbc:	89 e5                	mov    %esp,%ebp
  801fbe:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fc1:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  801fc8:	75 4a                	jne    802014 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801fca:	a1 04 40 80 00       	mov    0x804004,%eax
  801fcf:	8b 40 48             	mov    0x48(%eax),%eax
  801fd2:	83 ec 04             	sub    $0x4,%esp
  801fd5:	6a 07                	push   $0x7
  801fd7:	68 00 f0 bf ee       	push   $0xeebff000
  801fdc:	50                   	push   %eax
  801fdd:	e8 10 ee ff ff       	call   800df2 <sys_page_alloc>
  801fe2:	83 c4 10             	add    $0x10,%esp
  801fe5:	85 c0                	test   %eax,%eax
  801fe7:	79 12                	jns    801ffb <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801fe9:	50                   	push   %eax
  801fea:	68 74 2a 80 00       	push   $0x802a74
  801fef:	6a 21                	push   $0x21
  801ff1:	68 8c 2a 80 00       	push   $0x802a8c
  801ff6:	e8 17 e3 ff ff       	call   800312 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801ffb:	a1 04 40 80 00       	mov    0x804004,%eax
  802000:	8b 40 48             	mov    0x48(%eax),%eax
  802003:	83 ec 08             	sub    $0x8,%esp
  802006:	68 1e 20 80 00       	push   $0x80201e
  80200b:	50                   	push   %eax
  80200c:	e8 2c ef ff ff       	call   800f3d <sys_env_set_pgfault_upcall>
  802011:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802014:	8b 45 08             	mov    0x8(%ebp),%eax
  802017:	a3 00 60 80 00       	mov    %eax,0x806000
  80201c:	c9                   	leave  
  80201d:	c3                   	ret    

0080201e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80201e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80201f:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802024:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802026:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  802029:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  80202c:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  802030:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  802035:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  802039:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  80203b:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  80203c:	83 c4 04             	add    $0x4,%esp
	popfl
  80203f:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  802040:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  802041:	c3                   	ret    

00802042 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802042:	55                   	push   %ebp
  802043:	89 e5                	mov    %esp,%ebp
  802045:	56                   	push   %esi
  802046:	53                   	push   %ebx
  802047:	8b 75 08             	mov    0x8(%ebp),%esi
  80204a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80204d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  802050:	85 c0                	test   %eax,%eax
  802052:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802057:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  80205a:	83 ec 0c             	sub    $0xc,%esp
  80205d:	50                   	push   %eax
  80205e:	e8 3f ef ff ff       	call   800fa2 <sys_ipc_recv>
  802063:	83 c4 10             	add    $0x10,%esp
  802066:	85 c0                	test   %eax,%eax
  802068:	79 16                	jns    802080 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  80206a:	85 f6                	test   %esi,%esi
  80206c:	74 06                	je     802074 <ipc_recv+0x32>
            *from_env_store = 0;
  80206e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802074:	85 db                	test   %ebx,%ebx
  802076:	74 2c                	je     8020a4 <ipc_recv+0x62>
            *perm_store = 0;
  802078:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80207e:	eb 24                	jmp    8020a4 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  802080:	85 f6                	test   %esi,%esi
  802082:	74 0a                	je     80208e <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802084:	a1 04 40 80 00       	mov    0x804004,%eax
  802089:	8b 40 74             	mov    0x74(%eax),%eax
  80208c:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80208e:	85 db                	test   %ebx,%ebx
  802090:	74 0a                	je     80209c <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  802092:	a1 04 40 80 00       	mov    0x804004,%eax
  802097:	8b 40 78             	mov    0x78(%eax),%eax
  80209a:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  80209c:	a1 04 40 80 00       	mov    0x804004,%eax
  8020a1:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  8020a4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020a7:	5b                   	pop    %ebx
  8020a8:	5e                   	pop    %esi
  8020a9:	5d                   	pop    %ebp
  8020aa:	c3                   	ret    

008020ab <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020ab:	55                   	push   %ebp
  8020ac:	89 e5                	mov    %esp,%ebp
  8020ae:	57                   	push   %edi
  8020af:	56                   	push   %esi
  8020b0:	53                   	push   %ebx
  8020b1:	83 ec 0c             	sub    $0xc,%esp
  8020b4:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020b7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8020bd:	85 c0                	test   %eax,%eax
  8020bf:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  8020c4:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8020c7:	eb 1c                	jmp    8020e5 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  8020c9:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8020cc:	74 12                	je     8020e0 <ipc_send+0x35>
  8020ce:	50                   	push   %eax
  8020cf:	68 9a 2a 80 00       	push   $0x802a9a
  8020d4:	6a 3a                	push   $0x3a
  8020d6:	68 b0 2a 80 00       	push   $0x802ab0
  8020db:	e8 32 e2 ff ff       	call   800312 <_panic>
		sys_yield();
  8020e0:	e8 ee ec ff ff       	call   800dd3 <sys_yield>
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  8020e5:	ff 75 14             	pushl  0x14(%ebp)
  8020e8:	53                   	push   %ebx
  8020e9:	56                   	push   %esi
  8020ea:	57                   	push   %edi
  8020eb:	e8 8f ee ff ff       	call   800f7f <sys_ipc_try_send>
  8020f0:	83 c4 10             	add    $0x10,%esp
  8020f3:	85 c0                	test   %eax,%eax
  8020f5:	78 d2                	js     8020c9 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  8020f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020fa:	5b                   	pop    %ebx
  8020fb:	5e                   	pop    %esi
  8020fc:	5f                   	pop    %edi
  8020fd:	5d                   	pop    %ebp
  8020fe:	c3                   	ret    

008020ff <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8020ff:	55                   	push   %ebp
  802100:	89 e5                	mov    %esp,%ebp
  802102:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802105:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80210a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80210d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802113:	8b 52 50             	mov    0x50(%edx),%edx
  802116:	39 ca                	cmp    %ecx,%edx
  802118:	75 0d                	jne    802127 <ipc_find_env+0x28>
			return envs[i].env_id;
  80211a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80211d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802122:	8b 40 48             	mov    0x48(%eax),%eax
  802125:	eb 0f                	jmp    802136 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  802127:	83 c0 01             	add    $0x1,%eax
  80212a:	3d 00 04 00 00       	cmp    $0x400,%eax
  80212f:	75 d9                	jne    80210a <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  802131:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802136:	5d                   	pop    %ebp
  802137:	c3                   	ret    

00802138 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802138:	55                   	push   %ebp
  802139:	89 e5                	mov    %esp,%ebp
  80213b:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80213e:	89 d0                	mov    %edx,%eax
  802140:	c1 e8 16             	shr    $0x16,%eax
  802143:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  80214a:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80214f:	f6 c1 01             	test   $0x1,%cl
  802152:	74 1d                	je     802171 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  802154:	c1 ea 0c             	shr    $0xc,%edx
  802157:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  80215e:	f6 c2 01             	test   $0x1,%dl
  802161:	74 0e                	je     802171 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802163:	c1 ea 0c             	shr    $0xc,%edx
  802166:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80216d:	ef 
  80216e:	0f b7 c0             	movzwl %ax,%eax
}
  802171:	5d                   	pop    %ebp
  802172:	c3                   	ret    
  802173:	66 90                	xchg   %ax,%ax
  802175:	66 90                	xchg   %ax,%ax
  802177:	66 90                	xchg   %ax,%ax
  802179:	66 90                	xchg   %ax,%ax
  80217b:	66 90                	xchg   %ax,%ax
  80217d:	66 90                	xchg   %ax,%ax
  80217f:	90                   	nop

00802180 <__udivdi3>:
  802180:	55                   	push   %ebp
  802181:	57                   	push   %edi
  802182:	56                   	push   %esi
  802183:	53                   	push   %ebx
  802184:	83 ec 1c             	sub    $0x1c,%esp
  802187:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80218b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80218f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802193:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802197:	85 f6                	test   %esi,%esi
  802199:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80219d:	89 ca                	mov    %ecx,%edx
  80219f:	89 f8                	mov    %edi,%eax
  8021a1:	75 3d                	jne    8021e0 <__udivdi3+0x60>
  8021a3:	39 cf                	cmp    %ecx,%edi
  8021a5:	0f 87 c5 00 00 00    	ja     802270 <__udivdi3+0xf0>
  8021ab:	85 ff                	test   %edi,%edi
  8021ad:	89 fd                	mov    %edi,%ebp
  8021af:	75 0b                	jne    8021bc <__udivdi3+0x3c>
  8021b1:	b8 01 00 00 00       	mov    $0x1,%eax
  8021b6:	31 d2                	xor    %edx,%edx
  8021b8:	f7 f7                	div    %edi
  8021ba:	89 c5                	mov    %eax,%ebp
  8021bc:	89 c8                	mov    %ecx,%eax
  8021be:	31 d2                	xor    %edx,%edx
  8021c0:	f7 f5                	div    %ebp
  8021c2:	89 c1                	mov    %eax,%ecx
  8021c4:	89 d8                	mov    %ebx,%eax
  8021c6:	89 cf                	mov    %ecx,%edi
  8021c8:	f7 f5                	div    %ebp
  8021ca:	89 c3                	mov    %eax,%ebx
  8021cc:	89 d8                	mov    %ebx,%eax
  8021ce:	89 fa                	mov    %edi,%edx
  8021d0:	83 c4 1c             	add    $0x1c,%esp
  8021d3:	5b                   	pop    %ebx
  8021d4:	5e                   	pop    %esi
  8021d5:	5f                   	pop    %edi
  8021d6:	5d                   	pop    %ebp
  8021d7:	c3                   	ret    
  8021d8:	90                   	nop
  8021d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021e0:	39 ce                	cmp    %ecx,%esi
  8021e2:	77 74                	ja     802258 <__udivdi3+0xd8>
  8021e4:	0f bd fe             	bsr    %esi,%edi
  8021e7:	83 f7 1f             	xor    $0x1f,%edi
  8021ea:	0f 84 98 00 00 00    	je     802288 <__udivdi3+0x108>
  8021f0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8021f5:	89 f9                	mov    %edi,%ecx
  8021f7:	89 c5                	mov    %eax,%ebp
  8021f9:	29 fb                	sub    %edi,%ebx
  8021fb:	d3 e6                	shl    %cl,%esi
  8021fd:	89 d9                	mov    %ebx,%ecx
  8021ff:	d3 ed                	shr    %cl,%ebp
  802201:	89 f9                	mov    %edi,%ecx
  802203:	d3 e0                	shl    %cl,%eax
  802205:	09 ee                	or     %ebp,%esi
  802207:	89 d9                	mov    %ebx,%ecx
  802209:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80220d:	89 d5                	mov    %edx,%ebp
  80220f:	8b 44 24 08          	mov    0x8(%esp),%eax
  802213:	d3 ed                	shr    %cl,%ebp
  802215:	89 f9                	mov    %edi,%ecx
  802217:	d3 e2                	shl    %cl,%edx
  802219:	89 d9                	mov    %ebx,%ecx
  80221b:	d3 e8                	shr    %cl,%eax
  80221d:	09 c2                	or     %eax,%edx
  80221f:	89 d0                	mov    %edx,%eax
  802221:	89 ea                	mov    %ebp,%edx
  802223:	f7 f6                	div    %esi
  802225:	89 d5                	mov    %edx,%ebp
  802227:	89 c3                	mov    %eax,%ebx
  802229:	f7 64 24 0c          	mull   0xc(%esp)
  80222d:	39 d5                	cmp    %edx,%ebp
  80222f:	72 10                	jb     802241 <__udivdi3+0xc1>
  802231:	8b 74 24 08          	mov    0x8(%esp),%esi
  802235:	89 f9                	mov    %edi,%ecx
  802237:	d3 e6                	shl    %cl,%esi
  802239:	39 c6                	cmp    %eax,%esi
  80223b:	73 07                	jae    802244 <__udivdi3+0xc4>
  80223d:	39 d5                	cmp    %edx,%ebp
  80223f:	75 03                	jne    802244 <__udivdi3+0xc4>
  802241:	83 eb 01             	sub    $0x1,%ebx
  802244:	31 ff                	xor    %edi,%edi
  802246:	89 d8                	mov    %ebx,%eax
  802248:	89 fa                	mov    %edi,%edx
  80224a:	83 c4 1c             	add    $0x1c,%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5f                   	pop    %edi
  802250:	5d                   	pop    %ebp
  802251:	c3                   	ret    
  802252:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802258:	31 ff                	xor    %edi,%edi
  80225a:	31 db                	xor    %ebx,%ebx
  80225c:	89 d8                	mov    %ebx,%eax
  80225e:	89 fa                	mov    %edi,%edx
  802260:	83 c4 1c             	add    $0x1c,%esp
  802263:	5b                   	pop    %ebx
  802264:	5e                   	pop    %esi
  802265:	5f                   	pop    %edi
  802266:	5d                   	pop    %ebp
  802267:	c3                   	ret    
  802268:	90                   	nop
  802269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802270:	89 d8                	mov    %ebx,%eax
  802272:	f7 f7                	div    %edi
  802274:	31 ff                	xor    %edi,%edi
  802276:	89 c3                	mov    %eax,%ebx
  802278:	89 d8                	mov    %ebx,%eax
  80227a:	89 fa                	mov    %edi,%edx
  80227c:	83 c4 1c             	add    $0x1c,%esp
  80227f:	5b                   	pop    %ebx
  802280:	5e                   	pop    %esi
  802281:	5f                   	pop    %edi
  802282:	5d                   	pop    %ebp
  802283:	c3                   	ret    
  802284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802288:	39 ce                	cmp    %ecx,%esi
  80228a:	72 0c                	jb     802298 <__udivdi3+0x118>
  80228c:	31 db                	xor    %ebx,%ebx
  80228e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802292:	0f 87 34 ff ff ff    	ja     8021cc <__udivdi3+0x4c>
  802298:	bb 01 00 00 00       	mov    $0x1,%ebx
  80229d:	e9 2a ff ff ff       	jmp    8021cc <__udivdi3+0x4c>
  8022a2:	66 90                	xchg   %ax,%ax
  8022a4:	66 90                	xchg   %ax,%ax
  8022a6:	66 90                	xchg   %ax,%ax
  8022a8:	66 90                	xchg   %ax,%ax
  8022aa:	66 90                	xchg   %ax,%ax
  8022ac:	66 90                	xchg   %ax,%ax
  8022ae:	66 90                	xchg   %ax,%ax

008022b0 <__umoddi3>:
  8022b0:	55                   	push   %ebp
  8022b1:	57                   	push   %edi
  8022b2:	56                   	push   %esi
  8022b3:	53                   	push   %ebx
  8022b4:	83 ec 1c             	sub    $0x1c,%esp
  8022b7:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022bb:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  8022bf:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022c3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022c7:	85 d2                	test   %edx,%edx
  8022c9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  8022cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022d1:	89 f3                	mov    %esi,%ebx
  8022d3:	89 3c 24             	mov    %edi,(%esp)
  8022d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022da:	75 1c                	jne    8022f8 <__umoddi3+0x48>
  8022dc:	39 f7                	cmp    %esi,%edi
  8022de:	76 50                	jbe    802330 <__umoddi3+0x80>
  8022e0:	89 c8                	mov    %ecx,%eax
  8022e2:	89 f2                	mov    %esi,%edx
  8022e4:	f7 f7                	div    %edi
  8022e6:	89 d0                	mov    %edx,%eax
  8022e8:	31 d2                	xor    %edx,%edx
  8022ea:	83 c4 1c             	add    $0x1c,%esp
  8022ed:	5b                   	pop    %ebx
  8022ee:	5e                   	pop    %esi
  8022ef:	5f                   	pop    %edi
  8022f0:	5d                   	pop    %ebp
  8022f1:	c3                   	ret    
  8022f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	89 d0                	mov    %edx,%eax
  8022fc:	77 52                	ja     802350 <__umoddi3+0xa0>
  8022fe:	0f bd ea             	bsr    %edx,%ebp
  802301:	83 f5 1f             	xor    $0x1f,%ebp
  802304:	75 5a                	jne    802360 <__umoddi3+0xb0>
  802306:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80230a:	0f 82 e0 00 00 00    	jb     8023f0 <__umoddi3+0x140>
  802310:	39 0c 24             	cmp    %ecx,(%esp)
  802313:	0f 86 d7 00 00 00    	jbe    8023f0 <__umoddi3+0x140>
  802319:	8b 44 24 08          	mov    0x8(%esp),%eax
  80231d:	8b 54 24 04          	mov    0x4(%esp),%edx
  802321:	83 c4 1c             	add    $0x1c,%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5f                   	pop    %edi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    
  802329:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802330:	85 ff                	test   %edi,%edi
  802332:	89 fd                	mov    %edi,%ebp
  802334:	75 0b                	jne    802341 <__umoddi3+0x91>
  802336:	b8 01 00 00 00       	mov    $0x1,%eax
  80233b:	31 d2                	xor    %edx,%edx
  80233d:	f7 f7                	div    %edi
  80233f:	89 c5                	mov    %eax,%ebp
  802341:	89 f0                	mov    %esi,%eax
  802343:	31 d2                	xor    %edx,%edx
  802345:	f7 f5                	div    %ebp
  802347:	89 c8                	mov    %ecx,%eax
  802349:	f7 f5                	div    %ebp
  80234b:	89 d0                	mov    %edx,%eax
  80234d:	eb 99                	jmp    8022e8 <__umoddi3+0x38>
  80234f:	90                   	nop
  802350:	89 c8                	mov    %ecx,%eax
  802352:	89 f2                	mov    %esi,%edx
  802354:	83 c4 1c             	add    $0x1c,%esp
  802357:	5b                   	pop    %ebx
  802358:	5e                   	pop    %esi
  802359:	5f                   	pop    %edi
  80235a:	5d                   	pop    %ebp
  80235b:	c3                   	ret    
  80235c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802360:	8b 34 24             	mov    (%esp),%esi
  802363:	bf 20 00 00 00       	mov    $0x20,%edi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	29 ef                	sub    %ebp,%edi
  80236c:	d3 e0                	shl    %cl,%eax
  80236e:	89 f9                	mov    %edi,%ecx
  802370:	89 f2                	mov    %esi,%edx
  802372:	d3 ea                	shr    %cl,%edx
  802374:	89 e9                	mov    %ebp,%ecx
  802376:	09 c2                	or     %eax,%edx
  802378:	89 d8                	mov    %ebx,%eax
  80237a:	89 14 24             	mov    %edx,(%esp)
  80237d:	89 f2                	mov    %esi,%edx
  80237f:	d3 e2                	shl    %cl,%edx
  802381:	89 f9                	mov    %edi,%ecx
  802383:	89 54 24 04          	mov    %edx,0x4(%esp)
  802387:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80238b:	d3 e8                	shr    %cl,%eax
  80238d:	89 e9                	mov    %ebp,%ecx
  80238f:	89 c6                	mov    %eax,%esi
  802391:	d3 e3                	shl    %cl,%ebx
  802393:	89 f9                	mov    %edi,%ecx
  802395:	89 d0                	mov    %edx,%eax
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	09 d8                	or     %ebx,%eax
  80239d:	89 d3                	mov    %edx,%ebx
  80239f:	89 f2                	mov    %esi,%edx
  8023a1:	f7 34 24             	divl   (%esp)
  8023a4:	89 d6                	mov    %edx,%esi
  8023a6:	d3 e3                	shl    %cl,%ebx
  8023a8:	f7 64 24 04          	mull   0x4(%esp)
  8023ac:	39 d6                	cmp    %edx,%esi
  8023ae:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8023b2:	89 d1                	mov    %edx,%ecx
  8023b4:	89 c3                	mov    %eax,%ebx
  8023b6:	72 08                	jb     8023c0 <__umoddi3+0x110>
  8023b8:	75 11                	jne    8023cb <__umoddi3+0x11b>
  8023ba:	39 44 24 08          	cmp    %eax,0x8(%esp)
  8023be:	73 0b                	jae    8023cb <__umoddi3+0x11b>
  8023c0:	2b 44 24 04          	sub    0x4(%esp),%eax
  8023c4:	1b 14 24             	sbb    (%esp),%edx
  8023c7:	89 d1                	mov    %edx,%ecx
  8023c9:	89 c3                	mov    %eax,%ebx
  8023cb:	8b 54 24 08          	mov    0x8(%esp),%edx
  8023cf:	29 da                	sub    %ebx,%edx
  8023d1:	19 ce                	sbb    %ecx,%esi
  8023d3:	89 f9                	mov    %edi,%ecx
  8023d5:	89 f0                	mov    %esi,%eax
  8023d7:	d3 e0                	shl    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	d3 ea                	shr    %cl,%edx
  8023dd:	89 e9                	mov    %ebp,%ecx
  8023df:	d3 ee                	shr    %cl,%esi
  8023e1:	09 d0                	or     %edx,%eax
  8023e3:	89 f2                	mov    %esi,%edx
  8023e5:	83 c4 1c             	add    $0x1c,%esp
  8023e8:	5b                   	pop    %ebx
  8023e9:	5e                   	pop    %esi
  8023ea:	5f                   	pop    %edi
  8023eb:	5d                   	pop    %ebp
  8023ec:	c3                   	ret    
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	29 f9                	sub    %edi,%ecx
  8023f2:	19 d6                	sbb    %edx,%esi
  8023f4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8023f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023fc:	e9 18 ff ff ff       	jmp    802319 <__umoddi3+0x69>
