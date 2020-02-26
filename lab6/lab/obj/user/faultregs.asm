
obj/user/faultregs.debug：     文件格式 elf32-i386


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
  80002c:	e8 66 05 00 00       	call   800597 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 0c             	sub    $0xc,%esp
  80003c:	89 c6                	mov    %eax,%esi
  80003e:	89 cb                	mov    %ecx,%ebx
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  800040:	ff 75 08             	pushl  0x8(%ebp)
  800043:	52                   	push   %edx
  800044:	68 d1 28 80 00       	push   $0x8028d1
  800049:	68 a0 28 80 00       	push   $0x8028a0
  80004e:	e8 7d 06 00 00       	call   8006d0 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800053:	ff 33                	pushl  (%ebx)
  800055:	ff 36                	pushl  (%esi)
  800057:	68 b0 28 80 00       	push   $0x8028b0
  80005c:	68 b4 28 80 00       	push   $0x8028b4
  800061:	e8 6a 06 00 00       	call   8006d0 <cprintf>
  800066:	83 c4 20             	add    $0x20,%esp
  800069:	8b 03                	mov    (%ebx),%eax
  80006b:	39 06                	cmp    %eax,(%esi)
  80006d:	75 17                	jne    800086 <check_regs+0x53>
  80006f:	83 ec 0c             	sub    $0xc,%esp
  800072:	68 c4 28 80 00       	push   $0x8028c4
  800077:	e8 54 06 00 00       	call   8006d0 <cprintf>
  80007c:	83 c4 10             	add    $0x10,%esp

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
	int mismatch = 0;
  80007f:	bf 00 00 00 00       	mov    $0x0,%edi
  800084:	eb 15                	jmp    80009b <check_regs+0x68>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  800086:	83 ec 0c             	sub    $0xc,%esp
  800089:	68 c8 28 80 00       	push   $0x8028c8
  80008e:	e8 3d 06 00 00       	call   8006d0 <cprintf>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  80009b:	ff 73 04             	pushl  0x4(%ebx)
  80009e:	ff 76 04             	pushl  0x4(%esi)
  8000a1:	68 d2 28 80 00       	push   $0x8028d2
  8000a6:	68 b4 28 80 00       	push   $0x8028b4
  8000ab:	e8 20 06 00 00       	call   8006d0 <cprintf>
  8000b0:	83 c4 10             	add    $0x10,%esp
  8000b3:	8b 43 04             	mov    0x4(%ebx),%eax
  8000b6:	39 46 04             	cmp    %eax,0x4(%esi)
  8000b9:	75 12                	jne    8000cd <check_regs+0x9a>
  8000bb:	83 ec 0c             	sub    $0xc,%esp
  8000be:	68 c4 28 80 00       	push   $0x8028c4
  8000c3:	e8 08 06 00 00       	call   8006d0 <cprintf>
  8000c8:	83 c4 10             	add    $0x10,%esp
  8000cb:	eb 15                	jmp    8000e2 <check_regs+0xaf>
  8000cd:	83 ec 0c             	sub    $0xc,%esp
  8000d0:	68 c8 28 80 00       	push   $0x8028c8
  8000d5:	e8 f6 05 00 00       	call   8006d0 <cprintf>
  8000da:	83 c4 10             	add    $0x10,%esp
  8000dd:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000e2:	ff 73 08             	pushl  0x8(%ebx)
  8000e5:	ff 76 08             	pushl  0x8(%esi)
  8000e8:	68 d6 28 80 00       	push   $0x8028d6
  8000ed:	68 b4 28 80 00       	push   $0x8028b4
  8000f2:	e8 d9 05 00 00       	call   8006d0 <cprintf>
  8000f7:	83 c4 10             	add    $0x10,%esp
  8000fa:	8b 43 08             	mov    0x8(%ebx),%eax
  8000fd:	39 46 08             	cmp    %eax,0x8(%esi)
  800100:	75 12                	jne    800114 <check_regs+0xe1>
  800102:	83 ec 0c             	sub    $0xc,%esp
  800105:	68 c4 28 80 00       	push   $0x8028c4
  80010a:	e8 c1 05 00 00       	call   8006d0 <cprintf>
  80010f:	83 c4 10             	add    $0x10,%esp
  800112:	eb 15                	jmp    800129 <check_regs+0xf6>
  800114:	83 ec 0c             	sub    $0xc,%esp
  800117:	68 c8 28 80 00       	push   $0x8028c8
  80011c:	e8 af 05 00 00       	call   8006d0 <cprintf>
  800121:	83 c4 10             	add    $0x10,%esp
  800124:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800129:	ff 73 10             	pushl  0x10(%ebx)
  80012c:	ff 76 10             	pushl  0x10(%esi)
  80012f:	68 da 28 80 00       	push   $0x8028da
  800134:	68 b4 28 80 00       	push   $0x8028b4
  800139:	e8 92 05 00 00       	call   8006d0 <cprintf>
  80013e:	83 c4 10             	add    $0x10,%esp
  800141:	8b 43 10             	mov    0x10(%ebx),%eax
  800144:	39 46 10             	cmp    %eax,0x10(%esi)
  800147:	75 12                	jne    80015b <check_regs+0x128>
  800149:	83 ec 0c             	sub    $0xc,%esp
  80014c:	68 c4 28 80 00       	push   $0x8028c4
  800151:	e8 7a 05 00 00       	call   8006d0 <cprintf>
  800156:	83 c4 10             	add    $0x10,%esp
  800159:	eb 15                	jmp    800170 <check_regs+0x13d>
  80015b:	83 ec 0c             	sub    $0xc,%esp
  80015e:	68 c8 28 80 00       	push   $0x8028c8
  800163:	e8 68 05 00 00       	call   8006d0 <cprintf>
  800168:	83 c4 10             	add    $0x10,%esp
  80016b:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800170:	ff 73 14             	pushl  0x14(%ebx)
  800173:	ff 76 14             	pushl  0x14(%esi)
  800176:	68 de 28 80 00       	push   $0x8028de
  80017b:	68 b4 28 80 00       	push   $0x8028b4
  800180:	e8 4b 05 00 00       	call   8006d0 <cprintf>
  800185:	83 c4 10             	add    $0x10,%esp
  800188:	8b 43 14             	mov    0x14(%ebx),%eax
  80018b:	39 46 14             	cmp    %eax,0x14(%esi)
  80018e:	75 12                	jne    8001a2 <check_regs+0x16f>
  800190:	83 ec 0c             	sub    $0xc,%esp
  800193:	68 c4 28 80 00       	push   $0x8028c4
  800198:	e8 33 05 00 00       	call   8006d0 <cprintf>
  80019d:	83 c4 10             	add    $0x10,%esp
  8001a0:	eb 15                	jmp    8001b7 <check_regs+0x184>
  8001a2:	83 ec 0c             	sub    $0xc,%esp
  8001a5:	68 c8 28 80 00       	push   $0x8028c8
  8001aa:	e8 21 05 00 00       	call   8006d0 <cprintf>
  8001af:	83 c4 10             	add    $0x10,%esp
  8001b2:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001b7:	ff 73 18             	pushl  0x18(%ebx)
  8001ba:	ff 76 18             	pushl  0x18(%esi)
  8001bd:	68 e2 28 80 00       	push   $0x8028e2
  8001c2:	68 b4 28 80 00       	push   $0x8028b4
  8001c7:	e8 04 05 00 00       	call   8006d0 <cprintf>
  8001cc:	83 c4 10             	add    $0x10,%esp
  8001cf:	8b 43 18             	mov    0x18(%ebx),%eax
  8001d2:	39 46 18             	cmp    %eax,0x18(%esi)
  8001d5:	75 12                	jne    8001e9 <check_regs+0x1b6>
  8001d7:	83 ec 0c             	sub    $0xc,%esp
  8001da:	68 c4 28 80 00       	push   $0x8028c4
  8001df:	e8 ec 04 00 00       	call   8006d0 <cprintf>
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	eb 15                	jmp    8001fe <check_regs+0x1cb>
  8001e9:	83 ec 0c             	sub    $0xc,%esp
  8001ec:	68 c8 28 80 00       	push   $0x8028c8
  8001f1:	e8 da 04 00 00       	call   8006d0 <cprintf>
  8001f6:	83 c4 10             	add    $0x10,%esp
  8001f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  8001fe:	ff 73 1c             	pushl  0x1c(%ebx)
  800201:	ff 76 1c             	pushl  0x1c(%esi)
  800204:	68 e6 28 80 00       	push   $0x8028e6
  800209:	68 b4 28 80 00       	push   $0x8028b4
  80020e:	e8 bd 04 00 00       	call   8006d0 <cprintf>
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800219:	39 46 1c             	cmp    %eax,0x1c(%esi)
  80021c:	75 12                	jne    800230 <check_regs+0x1fd>
  80021e:	83 ec 0c             	sub    $0xc,%esp
  800221:	68 c4 28 80 00       	push   $0x8028c4
  800226:	e8 a5 04 00 00       	call   8006d0 <cprintf>
  80022b:	83 c4 10             	add    $0x10,%esp
  80022e:	eb 15                	jmp    800245 <check_regs+0x212>
  800230:	83 ec 0c             	sub    $0xc,%esp
  800233:	68 c8 28 80 00       	push   $0x8028c8
  800238:	e8 93 04 00 00       	call   8006d0 <cprintf>
  80023d:	83 c4 10             	add    $0x10,%esp
  800240:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  800245:	ff 73 20             	pushl  0x20(%ebx)
  800248:	ff 76 20             	pushl  0x20(%esi)
  80024b:	68 ea 28 80 00       	push   $0x8028ea
  800250:	68 b4 28 80 00       	push   $0x8028b4
  800255:	e8 76 04 00 00       	call   8006d0 <cprintf>
  80025a:	83 c4 10             	add    $0x10,%esp
  80025d:	8b 43 20             	mov    0x20(%ebx),%eax
  800260:	39 46 20             	cmp    %eax,0x20(%esi)
  800263:	75 12                	jne    800277 <check_regs+0x244>
  800265:	83 ec 0c             	sub    $0xc,%esp
  800268:	68 c4 28 80 00       	push   $0x8028c4
  80026d:	e8 5e 04 00 00       	call   8006d0 <cprintf>
  800272:	83 c4 10             	add    $0x10,%esp
  800275:	eb 15                	jmp    80028c <check_regs+0x259>
  800277:	83 ec 0c             	sub    $0xc,%esp
  80027a:	68 c8 28 80 00       	push   $0x8028c8
  80027f:	e8 4c 04 00 00       	call   8006d0 <cprintf>
  800284:	83 c4 10             	add    $0x10,%esp
  800287:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  80028c:	ff 73 24             	pushl  0x24(%ebx)
  80028f:	ff 76 24             	pushl  0x24(%esi)
  800292:	68 ee 28 80 00       	push   $0x8028ee
  800297:	68 b4 28 80 00       	push   $0x8028b4
  80029c:	e8 2f 04 00 00       	call   8006d0 <cprintf>
  8002a1:	83 c4 10             	add    $0x10,%esp
  8002a4:	8b 43 24             	mov    0x24(%ebx),%eax
  8002a7:	39 46 24             	cmp    %eax,0x24(%esi)
  8002aa:	75 2f                	jne    8002db <check_regs+0x2a8>
  8002ac:	83 ec 0c             	sub    $0xc,%esp
  8002af:	68 c4 28 80 00       	push   $0x8028c4
  8002b4:	e8 17 04 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002b9:	ff 73 28             	pushl  0x28(%ebx)
  8002bc:	ff 76 28             	pushl  0x28(%esi)
  8002bf:	68 f5 28 80 00       	push   $0x8028f5
  8002c4:	68 b4 28 80 00       	push   $0x8028b4
  8002c9:	e8 02 04 00 00       	call   8006d0 <cprintf>
  8002ce:	83 c4 20             	add    $0x20,%esp
  8002d1:	8b 43 28             	mov    0x28(%ebx),%eax
  8002d4:	39 46 28             	cmp    %eax,0x28(%esi)
  8002d7:	74 31                	je     80030a <check_regs+0x2d7>
  8002d9:	eb 55                	jmp    800330 <check_regs+0x2fd>
	CHECK(ebx, regs.reg_ebx);
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	68 c8 28 80 00       	push   $0x8028c8
  8002e3:	e8 e8 03 00 00       	call   8006d0 <cprintf>
	CHECK(esp, esp);
  8002e8:	ff 73 28             	pushl  0x28(%ebx)
  8002eb:	ff 76 28             	pushl  0x28(%esi)
  8002ee:	68 f5 28 80 00       	push   $0x8028f5
  8002f3:	68 b4 28 80 00       	push   $0x8028b4
  8002f8:	e8 d3 03 00 00       	call   8006d0 <cprintf>
  8002fd:	83 c4 20             	add    $0x20,%esp
  800300:	8b 43 28             	mov    0x28(%ebx),%eax
  800303:	39 46 28             	cmp    %eax,0x28(%esi)
  800306:	75 28                	jne    800330 <check_regs+0x2fd>
  800308:	eb 6c                	jmp    800376 <check_regs+0x343>
  80030a:	83 ec 0c             	sub    $0xc,%esp
  80030d:	68 c4 28 80 00       	push   $0x8028c4
  800312:	e8 b9 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800317:	83 c4 08             	add    $0x8,%esp
  80031a:	ff 75 0c             	pushl  0xc(%ebp)
  80031d:	68 f9 28 80 00       	push   $0x8028f9
  800322:	e8 a9 03 00 00       	call   8006d0 <cprintf>
	if (!mismatch)
  800327:	83 c4 10             	add    $0x10,%esp
  80032a:	85 ff                	test   %edi,%edi
  80032c:	74 24                	je     800352 <check_regs+0x31f>
  80032e:	eb 34                	jmp    800364 <check_regs+0x331>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	68 c8 28 80 00       	push   $0x8028c8
  800338:	e8 93 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  80033d:	83 c4 08             	add    $0x8,%esp
  800340:	ff 75 0c             	pushl  0xc(%ebp)
  800343:	68 f9 28 80 00       	push   $0x8028f9
  800348:	e8 83 03 00 00       	call   8006d0 <cprintf>
  80034d:	83 c4 10             	add    $0x10,%esp
  800350:	eb 12                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
  800352:	83 ec 0c             	sub    $0xc,%esp
  800355:	68 c4 28 80 00       	push   $0x8028c4
  80035a:	e8 71 03 00 00       	call   8006d0 <cprintf>
  80035f:	83 c4 10             	add    $0x10,%esp
  800362:	eb 34                	jmp    800398 <check_regs+0x365>
	else
		cprintf("MISMATCH\n");
  800364:	83 ec 0c             	sub    $0xc,%esp
  800367:	68 c8 28 80 00       	push   $0x8028c8
  80036c:	e8 5f 03 00 00       	call   8006d0 <cprintf>
  800371:	83 c4 10             	add    $0x10,%esp
}
  800374:	eb 22                	jmp    800398 <check_regs+0x365>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  800376:	83 ec 0c             	sub    $0xc,%esp
  800379:	68 c4 28 80 00       	push   $0x8028c4
  80037e:	e8 4d 03 00 00       	call   8006d0 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800383:	83 c4 08             	add    $0x8,%esp
  800386:	ff 75 0c             	pushl  0xc(%ebp)
  800389:	68 f9 28 80 00       	push   $0x8028f9
  80038e:	e8 3d 03 00 00       	call   8006d0 <cprintf>
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb cc                	jmp    800364 <check_regs+0x331>
	if (!mismatch)
		cprintf("OK\n");
	else
		cprintf("MISMATCH\n");
}
  800398:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039b:	5b                   	pop    %ebx
  80039c:	5e                   	pop    %esi
  80039d:	5f                   	pop    %edi
  80039e:	5d                   	pop    %ebp
  80039f:	c3                   	ret    

008003a0 <pgfault>:

static void
pgfault(struct UTrapframe *utf)
{
  8003a0:	55                   	push   %ebp
  8003a1:	89 e5                	mov    %esp,%ebp
  8003a3:	83 ec 08             	sub    $0x8,%esp
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8003a9:	8b 10                	mov    (%eax),%edx
  8003ab:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8003b1:	74 18                	je     8003cb <pgfault+0x2b>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8003b3:	83 ec 0c             	sub    $0xc,%esp
  8003b6:	ff 70 28             	pushl  0x28(%eax)
  8003b9:	52                   	push   %edx
  8003ba:	68 60 29 80 00       	push   $0x802960
  8003bf:	6a 51                	push   $0x51
  8003c1:	68 07 29 80 00       	push   $0x802907
  8003c6:	e8 2c 02 00 00       	call   8005f7 <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8003cb:	8b 50 08             	mov    0x8(%eax),%edx
  8003ce:	89 15 40 40 80 00    	mov    %edx,0x804040
  8003d4:	8b 50 0c             	mov    0xc(%eax),%edx
  8003d7:	89 15 44 40 80 00    	mov    %edx,0x804044
  8003dd:	8b 50 10             	mov    0x10(%eax),%edx
  8003e0:	89 15 48 40 80 00    	mov    %edx,0x804048
  8003e6:	8b 50 14             	mov    0x14(%eax),%edx
  8003e9:	89 15 4c 40 80 00    	mov    %edx,0x80404c
  8003ef:	8b 50 18             	mov    0x18(%eax),%edx
  8003f2:	89 15 50 40 80 00    	mov    %edx,0x804050
  8003f8:	8b 50 1c             	mov    0x1c(%eax),%edx
  8003fb:	89 15 54 40 80 00    	mov    %edx,0x804054
  800401:	8b 50 20             	mov    0x20(%eax),%edx
  800404:	89 15 58 40 80 00    	mov    %edx,0x804058
  80040a:	8b 50 24             	mov    0x24(%eax),%edx
  80040d:	89 15 5c 40 80 00    	mov    %edx,0x80405c
	during.eip = utf->utf_eip;
  800413:	8b 50 28             	mov    0x28(%eax),%edx
  800416:	89 15 60 40 80 00    	mov    %edx,0x804060
	during.eflags = utf->utf_eflags & ~FL_RF;
  80041c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80041f:	81 e2 ff ff fe ff    	and    $0xfffeffff,%edx
  800425:	89 15 64 40 80 00    	mov    %edx,0x804064
	during.esp = utf->utf_esp;
  80042b:	8b 40 30             	mov    0x30(%eax),%eax
  80042e:	a3 68 40 80 00       	mov    %eax,0x804068
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  800433:	83 ec 08             	sub    $0x8,%esp
  800436:	68 1f 29 80 00       	push   $0x80291f
  80043b:	68 2d 29 80 00       	push   $0x80292d
  800440:	b9 40 40 80 00       	mov    $0x804040,%ecx
  800445:	ba 18 29 80 00       	mov    $0x802918,%edx
  80044a:	b8 80 40 80 00       	mov    $0x804080,%eax
  80044f:	e8 df fb ff ff       	call   800033 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800454:	83 c4 0c             	add    $0xc,%esp
  800457:	6a 07                	push   $0x7
  800459:	68 00 00 40 00       	push   $0x400000
  80045e:	6a 00                	push   $0x0
  800460:	e8 72 0c 00 00       	call   8010d7 <sys_page_alloc>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	85 c0                	test   %eax,%eax
  80046a:	79 12                	jns    80047e <pgfault+0xde>
		panic("sys_page_alloc: %e", r);
  80046c:	50                   	push   %eax
  80046d:	68 34 29 80 00       	push   $0x802934
  800472:	6a 5c                	push   $0x5c
  800474:	68 07 29 80 00       	push   $0x802907
  800479:	e8 79 01 00 00       	call   8005f7 <_panic>
}
  80047e:	c9                   	leave  
  80047f:	c3                   	ret    

00800480 <umain>:

void
umain(int argc, char **argv)
{
  800480:	55                   	push   %ebp
  800481:	89 e5                	mov    %esp,%ebp
  800483:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(pgfault);
  800486:	68 a0 03 80 00       	push   $0x8003a0
  80048b:	e8 77 0e 00 00       	call   801307 <set_pgfault_handler>

	asm volatile(
  800490:	50                   	push   %eax
  800491:	9c                   	pushf  
  800492:	58                   	pop    %eax
  800493:	0d d5 08 00 00       	or     $0x8d5,%eax
  800498:	50                   	push   %eax
  800499:	9d                   	popf   
  80049a:	a3 a4 40 80 00       	mov    %eax,0x8040a4
  80049f:	8d 05 da 04 80 00    	lea    0x8004da,%eax
  8004a5:	a3 a0 40 80 00       	mov    %eax,0x8040a0
  8004aa:	58                   	pop    %eax
  8004ab:	89 3d 80 40 80 00    	mov    %edi,0x804080
  8004b1:	89 35 84 40 80 00    	mov    %esi,0x804084
  8004b7:	89 2d 88 40 80 00    	mov    %ebp,0x804088
  8004bd:	89 1d 90 40 80 00    	mov    %ebx,0x804090
  8004c3:	89 15 94 40 80 00    	mov    %edx,0x804094
  8004c9:	89 0d 98 40 80 00    	mov    %ecx,0x804098
  8004cf:	a3 9c 40 80 00       	mov    %eax,0x80409c
  8004d4:	89 25 a8 40 80 00    	mov    %esp,0x8040a8
  8004da:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8004e1:	00 00 00 
  8004e4:	89 3d 00 40 80 00    	mov    %edi,0x804000
  8004ea:	89 35 04 40 80 00    	mov    %esi,0x804004
  8004f0:	89 2d 08 40 80 00    	mov    %ebp,0x804008
  8004f6:	89 1d 10 40 80 00    	mov    %ebx,0x804010
  8004fc:	89 15 14 40 80 00    	mov    %edx,0x804014
  800502:	89 0d 18 40 80 00    	mov    %ecx,0x804018
  800508:	a3 1c 40 80 00       	mov    %eax,0x80401c
  80050d:	89 25 28 40 80 00    	mov    %esp,0x804028
  800513:	8b 3d 80 40 80 00    	mov    0x804080,%edi
  800519:	8b 35 84 40 80 00    	mov    0x804084,%esi
  80051f:	8b 2d 88 40 80 00    	mov    0x804088,%ebp
  800525:	8b 1d 90 40 80 00    	mov    0x804090,%ebx
  80052b:	8b 15 94 40 80 00    	mov    0x804094,%edx
  800531:	8b 0d 98 40 80 00    	mov    0x804098,%ecx
  800537:	a1 9c 40 80 00       	mov    0x80409c,%eax
  80053c:	8b 25 a8 40 80 00    	mov    0x8040a8,%esp
  800542:	50                   	push   %eax
  800543:	9c                   	pushf  
  800544:	58                   	pop    %eax
  800545:	a3 24 40 80 00       	mov    %eax,0x804024
  80054a:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80054b:	83 c4 10             	add    $0x10,%esp
  80054e:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800555:	74 10                	je     800567 <umain+0xe7>
		cprintf("EIP after page-fault MISMATCH\n");
  800557:	83 ec 0c             	sub    $0xc,%esp
  80055a:	68 94 29 80 00       	push   $0x802994
  80055f:	e8 6c 01 00 00       	call   8006d0 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp
	after.eip = before.eip;
  800567:	a1 a0 40 80 00       	mov    0x8040a0,%eax
  80056c:	a3 20 40 80 00       	mov    %eax,0x804020

	check_regs(&before, "before", &after, "after", "after page-fault");
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	68 47 29 80 00       	push   $0x802947
  800579:	68 58 29 80 00       	push   $0x802958
  80057e:	b9 00 40 80 00       	mov    $0x804000,%ecx
  800583:	ba 18 29 80 00       	mov    $0x802918,%edx
  800588:	b8 80 40 80 00       	mov    $0x804080,%eax
  80058d:	e8 a1 fa ff ff       	call   800033 <check_regs>
}
  800592:	83 c4 10             	add    $0x10,%esp
  800595:	c9                   	leave  
  800596:	c3                   	ret    

00800597 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800597:	55                   	push   %ebp
  800598:	89 e5                	mov    %esp,%ebp
  80059a:	56                   	push   %esi
  80059b:	53                   	push   %ebx
  80059c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059f:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  8005a2:	e8 f2 0a 00 00       	call   801099 <sys_getenvid>
  8005a7:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005ac:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005af:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005b4:	a3 b4 40 80 00       	mov    %eax,0x8040b4

    // save the name of the program so that panic() can use it
    if (argc > 0)
  8005b9:	85 db                	test   %ebx,%ebx
  8005bb:	7e 07                	jle    8005c4 <libmain+0x2d>
        binaryname = argv[0];
  8005bd:	8b 06                	mov    (%esi),%eax
  8005bf:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  8005c4:	83 ec 08             	sub    $0x8,%esp
  8005c7:	56                   	push   %esi
  8005c8:	53                   	push   %ebx
  8005c9:	e8 b2 fe ff ff       	call   800480 <umain>

    // exit gracefully
    exit();
  8005ce:	e8 0a 00 00 00       	call   8005dd <exit>
}
  8005d3:	83 c4 10             	add    $0x10,%esp
  8005d6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8005d9:	5b                   	pop    %ebx
  8005da:	5e                   	pop    %esi
  8005db:	5d                   	pop    %ebp
  8005dc:	c3                   	ret    

008005dd <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005dd:	55                   	push   %ebp
  8005de:	89 e5                	mov    %esp,%ebp
  8005e0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8005e3:	e8 71 0f 00 00       	call   801559 <close_all>
	sys_env_destroy(0);
  8005e8:	83 ec 0c             	sub    $0xc,%esp
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 66 0a 00 00       	call   801058 <sys_env_destroy>
}
  8005f2:	83 c4 10             	add    $0x10,%esp
  8005f5:	c9                   	leave  
  8005f6:	c3                   	ret    

008005f7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8005f7:	55                   	push   %ebp
  8005f8:	89 e5                	mov    %esp,%ebp
  8005fa:	56                   	push   %esi
  8005fb:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8005fc:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8005ff:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800605:	e8 8f 0a 00 00       	call   801099 <sys_getenvid>
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	ff 75 0c             	pushl  0xc(%ebp)
  800610:	ff 75 08             	pushl  0x8(%ebp)
  800613:	56                   	push   %esi
  800614:	50                   	push   %eax
  800615:	68 c0 29 80 00       	push   $0x8029c0
  80061a:	e8 b1 00 00 00       	call   8006d0 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80061f:	83 c4 18             	add    $0x18,%esp
  800622:	53                   	push   %ebx
  800623:	ff 75 10             	pushl  0x10(%ebp)
  800626:	e8 54 00 00 00       	call   80067f <vcprintf>
	cprintf("\n");
  80062b:	c7 04 24 d0 28 80 00 	movl   $0x8028d0,(%esp)
  800632:	e8 99 00 00 00       	call   8006d0 <cprintf>
  800637:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80063a:	cc                   	int3   
  80063b:	eb fd                	jmp    80063a <_panic+0x43>

0080063d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80063d:	55                   	push   %ebp
  80063e:	89 e5                	mov    %esp,%ebp
  800640:	53                   	push   %ebx
  800641:	83 ec 04             	sub    $0x4,%esp
  800644:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800647:	8b 13                	mov    (%ebx),%edx
  800649:	8d 42 01             	lea    0x1(%edx),%eax
  80064c:	89 03                	mov    %eax,(%ebx)
  80064e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800651:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800655:	3d ff 00 00 00       	cmp    $0xff,%eax
  80065a:	75 1a                	jne    800676 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	68 ff 00 00 00       	push   $0xff
  800664:	8d 43 08             	lea    0x8(%ebx),%eax
  800667:	50                   	push   %eax
  800668:	e8 ae 09 00 00       	call   80101b <sys_cputs>
		b->idx = 0;
  80066d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800673:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800676:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80067a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067d:	c9                   	leave  
  80067e:	c3                   	ret    

0080067f <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80067f:	55                   	push   %ebp
  800680:	89 e5                	mov    %esp,%ebp
  800682:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800688:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80068f:	00 00 00 
	b.cnt = 0;
  800692:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800699:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80069c:	ff 75 0c             	pushl  0xc(%ebp)
  80069f:	ff 75 08             	pushl  0x8(%ebp)
  8006a2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8006a8:	50                   	push   %eax
  8006a9:	68 3d 06 80 00       	push   $0x80063d
  8006ae:	e8 1a 01 00 00       	call   8007cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006b3:	83 c4 08             	add    $0x8,%esp
  8006b6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8006bc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006c2:	50                   	push   %eax
  8006c3:	e8 53 09 00 00       	call   80101b <sys_cputs>

	return b.cnt;
}
  8006c8:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006ce:	c9                   	leave  
  8006cf:	c3                   	ret    

008006d0 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006d0:	55                   	push   %ebp
  8006d1:	89 e5                	mov    %esp,%ebp
  8006d3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8006d6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8006d9:	50                   	push   %eax
  8006da:	ff 75 08             	pushl  0x8(%ebp)
  8006dd:	e8 9d ff ff ff       	call   80067f <vcprintf>
	va_end(ap);

	return cnt;
}
  8006e2:	c9                   	leave  
  8006e3:	c3                   	ret    

008006e4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8006e4:	55                   	push   %ebp
  8006e5:	89 e5                	mov    %esp,%ebp
  8006e7:	57                   	push   %edi
  8006e8:	56                   	push   %esi
  8006e9:	53                   	push   %ebx
  8006ea:	83 ec 1c             	sub    $0x1c,%esp
  8006ed:	89 c7                	mov    %eax,%edi
  8006ef:	89 d6                	mov    %edx,%esi
  8006f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8006f7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8006fa:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8006fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800700:	bb 00 00 00 00       	mov    $0x0,%ebx
  800705:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800708:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80070b:	39 d3                	cmp    %edx,%ebx
  80070d:	72 05                	jb     800714 <printnum+0x30>
  80070f:	39 45 10             	cmp    %eax,0x10(%ebp)
  800712:	77 45                	ja     800759 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800714:	83 ec 0c             	sub    $0xc,%esp
  800717:	ff 75 18             	pushl  0x18(%ebp)
  80071a:	8b 45 14             	mov    0x14(%ebp),%eax
  80071d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800720:	53                   	push   %ebx
  800721:	ff 75 10             	pushl  0x10(%ebp)
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 e4             	pushl  -0x1c(%ebp)
  80072a:	ff 75 e0             	pushl  -0x20(%ebp)
  80072d:	ff 75 dc             	pushl  -0x24(%ebp)
  800730:	ff 75 d8             	pushl  -0x28(%ebp)
  800733:	e8 d8 1e 00 00       	call   802610 <__udivdi3>
  800738:	83 c4 18             	add    $0x18,%esp
  80073b:	52                   	push   %edx
  80073c:	50                   	push   %eax
  80073d:	89 f2                	mov    %esi,%edx
  80073f:	89 f8                	mov    %edi,%eax
  800741:	e8 9e ff ff ff       	call   8006e4 <printnum>
  800746:	83 c4 20             	add    $0x20,%esp
  800749:	eb 18                	jmp    800763 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80074b:	83 ec 08             	sub    $0x8,%esp
  80074e:	56                   	push   %esi
  80074f:	ff 75 18             	pushl  0x18(%ebp)
  800752:	ff d7                	call   *%edi
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	eb 03                	jmp    80075c <printnum+0x78>
  800759:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80075c:	83 eb 01             	sub    $0x1,%ebx
  80075f:	85 db                	test   %ebx,%ebx
  800761:	7f e8                	jg     80074b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800763:	83 ec 08             	sub    $0x8,%esp
  800766:	56                   	push   %esi
  800767:	83 ec 04             	sub    $0x4,%esp
  80076a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80076d:	ff 75 e0             	pushl  -0x20(%ebp)
  800770:	ff 75 dc             	pushl  -0x24(%ebp)
  800773:	ff 75 d8             	pushl  -0x28(%ebp)
  800776:	e8 c5 1f 00 00       	call   802740 <__umoddi3>
  80077b:	83 c4 14             	add    $0x14,%esp
  80077e:	0f be 80 e3 29 80 00 	movsbl 0x8029e3(%eax),%eax
  800785:	50                   	push   %eax
  800786:	ff d7                	call   *%edi
}
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80078e:	5b                   	pop    %ebx
  80078f:	5e                   	pop    %esi
  800790:	5f                   	pop    %edi
  800791:	5d                   	pop    %ebp
  800792:	c3                   	ret    

00800793 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800799:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80079d:	8b 10                	mov    (%eax),%edx
  80079f:	3b 50 04             	cmp    0x4(%eax),%edx
  8007a2:	73 0a                	jae    8007ae <sprintputch+0x1b>
		*b->buf++ = ch;
  8007a4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8007a7:	89 08                	mov    %ecx,(%eax)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	88 02                	mov    %al,(%edx)
}
  8007ae:	5d                   	pop    %ebp
  8007af:	c3                   	ret    

008007b0 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007b0:	55                   	push   %ebp
  8007b1:	89 e5                	mov    %esp,%ebp
  8007b3:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8007b9:	50                   	push   %eax
  8007ba:	ff 75 10             	pushl  0x10(%ebp)
  8007bd:	ff 75 0c             	pushl  0xc(%ebp)
  8007c0:	ff 75 08             	pushl  0x8(%ebp)
  8007c3:	e8 05 00 00 00       	call   8007cd <vprintfmt>
	va_end(ap);
}
  8007c8:	83 c4 10             	add    $0x10,%esp
  8007cb:	c9                   	leave  
  8007cc:	c3                   	ret    

008007cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	57                   	push   %edi
  8007d1:	56                   	push   %esi
  8007d2:	53                   	push   %ebx
  8007d3:	83 ec 2c             	sub    $0x2c,%esp
  8007d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8007dc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8007df:	eb 12                	jmp    8007f3 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8007e1:	85 c0                	test   %eax,%eax
  8007e3:	0f 84 42 04 00 00    	je     800c2b <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8007e9:	83 ec 08             	sub    $0x8,%esp
  8007ec:	53                   	push   %ebx
  8007ed:	50                   	push   %eax
  8007ee:	ff d6                	call   *%esi
  8007f0:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007f3:	83 c7 01             	add    $0x1,%edi
  8007f6:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007fa:	83 f8 25             	cmp    $0x25,%eax
  8007fd:	75 e2                	jne    8007e1 <vprintfmt+0x14>
  8007ff:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800803:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80080a:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  800811:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  800818:	b9 00 00 00 00       	mov    $0x0,%ecx
  80081d:	eb 07                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80081f:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800822:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800826:	8d 47 01             	lea    0x1(%edi),%eax
  800829:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80082c:	0f b6 07             	movzbl (%edi),%eax
  80082f:	0f b6 d0             	movzbl %al,%edx
  800832:	83 e8 23             	sub    $0x23,%eax
  800835:	3c 55                	cmp    $0x55,%al
  800837:	0f 87 d3 03 00 00    	ja     800c10 <vprintfmt+0x443>
  80083d:	0f b6 c0             	movzbl %al,%eax
  800840:	ff 24 85 20 2b 80 00 	jmp    *0x802b20(,%eax,4)
  800847:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80084a:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80084e:	eb d6                	jmp    800826 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800850:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800853:	b8 00 00 00 00       	mov    $0x0,%eax
  800858:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80085b:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80085e:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800862:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800865:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800868:	83 f9 09             	cmp    $0x9,%ecx
  80086b:	77 3f                	ja     8008ac <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80086d:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800870:	eb e9                	jmp    80085b <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8b 00                	mov    (%eax),%eax
  800877:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 40 04             	lea    0x4(%eax),%eax
  800880:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800883:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  800886:	eb 2a                	jmp    8008b2 <vprintfmt+0xe5>
  800888:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80088b:	85 c0                	test   %eax,%eax
  80088d:	ba 00 00 00 00       	mov    $0x0,%edx
  800892:	0f 49 d0             	cmovns %eax,%edx
  800895:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800898:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80089b:	eb 89                	jmp    800826 <vprintfmt+0x59>
  80089d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8008a0:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8008a7:	e9 7a ff ff ff       	jmp    800826 <vprintfmt+0x59>
  8008ac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8008af:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  8008b2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008b6:	0f 89 6a ff ff ff    	jns    800826 <vprintfmt+0x59>
				width = precision, precision = -1;
  8008bc:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8008bf:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008c2:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8008c9:	e9 58 ff ff ff       	jmp    800826 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8008ce:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8008d4:	e9 4d ff ff ff       	jmp    800826 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8008dc:	8d 78 04             	lea    0x4(%eax),%edi
  8008df:	83 ec 08             	sub    $0x8,%esp
  8008e2:	53                   	push   %ebx
  8008e3:	ff 30                	pushl  (%eax)
  8008e5:	ff d6                	call   *%esi
			break;
  8008e7:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8008ea:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8008f0:	e9 fe fe ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8008f5:	8b 45 14             	mov    0x14(%ebp),%eax
  8008f8:	8d 78 04             	lea    0x4(%eax),%edi
  8008fb:	8b 00                	mov    (%eax),%eax
  8008fd:	99                   	cltd   
  8008fe:	31 d0                	xor    %edx,%eax
  800900:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800902:	83 f8 0f             	cmp    $0xf,%eax
  800905:	7f 0b                	jg     800912 <vprintfmt+0x145>
  800907:	8b 14 85 80 2c 80 00 	mov    0x802c80(,%eax,4),%edx
  80090e:	85 d2                	test   %edx,%edx
  800910:	75 1b                	jne    80092d <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  800912:	50                   	push   %eax
  800913:	68 fb 29 80 00       	push   $0x8029fb
  800918:	53                   	push   %ebx
  800919:	56                   	push   %esi
  80091a:	e8 91 fe ff ff       	call   8007b0 <printfmt>
  80091f:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  800922:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800925:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800928:	e9 c6 fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80092d:	52                   	push   %edx
  80092e:	68 dd 2d 80 00       	push   $0x802ddd
  800933:	53                   	push   %ebx
  800934:	56                   	push   %esi
  800935:	e8 76 fe ff ff       	call   8007b0 <printfmt>
  80093a:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80093d:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800940:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800943:	e9 ab fe ff ff       	jmp    8007f3 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800948:	8b 45 14             	mov    0x14(%ebp),%eax
  80094b:	83 c0 04             	add    $0x4,%eax
  80094e:	89 45 cc             	mov    %eax,-0x34(%ebp)
  800951:	8b 45 14             	mov    0x14(%ebp),%eax
  800954:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  800956:	85 ff                	test   %edi,%edi
  800958:	b8 f4 29 80 00       	mov    $0x8029f4,%eax
  80095d:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800960:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800964:	0f 8e 94 00 00 00    	jle    8009fe <vprintfmt+0x231>
  80096a:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80096e:	0f 84 98 00 00 00    	je     800a0c <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	ff 75 d0             	pushl  -0x30(%ebp)
  80097a:	57                   	push   %edi
  80097b:	e8 33 03 00 00       	call   800cb3 <strnlen>
  800980:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800983:	29 c1                	sub    %eax,%ecx
  800985:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  800988:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80098b:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80098f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800992:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  800995:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800997:	eb 0f                	jmp    8009a8 <vprintfmt+0x1db>
					putch(padc, putdat);
  800999:	83 ec 08             	sub    $0x8,%esp
  80099c:	53                   	push   %ebx
  80099d:	ff 75 e0             	pushl  -0x20(%ebp)
  8009a0:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8009a2:	83 ef 01             	sub    $0x1,%edi
  8009a5:	83 c4 10             	add    $0x10,%esp
  8009a8:	85 ff                	test   %edi,%edi
  8009aa:	7f ed                	jg     800999 <vprintfmt+0x1cc>
  8009ac:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8009af:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  8009b2:	85 c9                	test   %ecx,%ecx
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b9:	0f 49 c1             	cmovns %ecx,%eax
  8009bc:	29 c1                	sub    %eax,%ecx
  8009be:	89 75 08             	mov    %esi,0x8(%ebp)
  8009c1:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8009c4:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8009c7:	89 cb                	mov    %ecx,%ebx
  8009c9:	eb 4d                	jmp    800a18 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8009cb:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8009cf:	74 1b                	je     8009ec <vprintfmt+0x21f>
  8009d1:	0f be c0             	movsbl %al,%eax
  8009d4:	83 e8 20             	sub    $0x20,%eax
  8009d7:	83 f8 5e             	cmp    $0x5e,%eax
  8009da:	76 10                	jbe    8009ec <vprintfmt+0x21f>
					putch('?', putdat);
  8009dc:	83 ec 08             	sub    $0x8,%esp
  8009df:	ff 75 0c             	pushl  0xc(%ebp)
  8009e2:	6a 3f                	push   $0x3f
  8009e4:	ff 55 08             	call   *0x8(%ebp)
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	eb 0d                	jmp    8009f9 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8009ec:	83 ec 08             	sub    $0x8,%esp
  8009ef:	ff 75 0c             	pushl  0xc(%ebp)
  8009f2:	52                   	push   %edx
  8009f3:	ff 55 08             	call   *0x8(%ebp)
  8009f6:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8009f9:	83 eb 01             	sub    $0x1,%ebx
  8009fc:	eb 1a                	jmp    800a18 <vprintfmt+0x24b>
  8009fe:	89 75 08             	mov    %esi,0x8(%ebp)
  800a01:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a04:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a07:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a0a:	eb 0c                	jmp    800a18 <vprintfmt+0x24b>
  800a0c:	89 75 08             	mov    %esi,0x8(%ebp)
  800a0f:	8b 75 d0             	mov    -0x30(%ebp),%esi
  800a12:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  800a15:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a18:	83 c7 01             	add    $0x1,%edi
  800a1b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a1f:	0f be d0             	movsbl %al,%edx
  800a22:	85 d2                	test   %edx,%edx
  800a24:	74 23                	je     800a49 <vprintfmt+0x27c>
  800a26:	85 f6                	test   %esi,%esi
  800a28:	78 a1                	js     8009cb <vprintfmt+0x1fe>
  800a2a:	83 ee 01             	sub    $0x1,%esi
  800a2d:	79 9c                	jns    8009cb <vprintfmt+0x1fe>
  800a2f:	89 df                	mov    %ebx,%edi
  800a31:	8b 75 08             	mov    0x8(%ebp),%esi
  800a34:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a37:	eb 18                	jmp    800a51 <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800a39:	83 ec 08             	sub    $0x8,%esp
  800a3c:	53                   	push   %ebx
  800a3d:	6a 20                	push   $0x20
  800a3f:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800a41:	83 ef 01             	sub    $0x1,%edi
  800a44:	83 c4 10             	add    $0x10,%esp
  800a47:	eb 08                	jmp    800a51 <vprintfmt+0x284>
  800a49:	89 df                	mov    %ebx,%edi
  800a4b:	8b 75 08             	mov    0x8(%ebp),%esi
  800a4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a51:	85 ff                	test   %edi,%edi
  800a53:	7f e4                	jg     800a39 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a55:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800a58:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800a5b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800a5e:	e9 90 fd ff ff       	jmp    8007f3 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800a63:	83 f9 01             	cmp    $0x1,%ecx
  800a66:	7e 19                	jle    800a81 <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  800a68:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6b:	8b 50 04             	mov    0x4(%eax),%edx
  800a6e:	8b 00                	mov    (%eax),%eax
  800a70:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a73:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800a76:	8b 45 14             	mov    0x14(%ebp),%eax
  800a79:	8d 40 08             	lea    0x8(%eax),%eax
  800a7c:	89 45 14             	mov    %eax,0x14(%ebp)
  800a7f:	eb 38                	jmp    800ab9 <vprintfmt+0x2ec>
	else if (lflag)
  800a81:	85 c9                	test   %ecx,%ecx
  800a83:	74 1b                	je     800aa0 <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  800a85:	8b 45 14             	mov    0x14(%ebp),%eax
  800a88:	8b 00                	mov    (%eax),%eax
  800a8a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a8d:	89 c1                	mov    %eax,%ecx
  800a8f:	c1 f9 1f             	sar    $0x1f,%ecx
  800a92:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a95:	8b 45 14             	mov    0x14(%ebp),%eax
  800a98:	8d 40 04             	lea    0x4(%eax),%eax
  800a9b:	89 45 14             	mov    %eax,0x14(%ebp)
  800a9e:	eb 19                	jmp    800ab9 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  800aa0:	8b 45 14             	mov    0x14(%ebp),%eax
  800aa3:	8b 00                	mov    (%eax),%eax
  800aa5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800aa8:	89 c1                	mov    %eax,%ecx
  800aaa:	c1 f9 1f             	sar    $0x1f,%ecx
  800aad:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800ab0:	8b 45 14             	mov    0x14(%ebp),%eax
  800ab3:	8d 40 04             	lea    0x4(%eax),%eax
  800ab6:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800ab9:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800abc:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  800abf:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800ac4:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  800ac8:	0f 89 0e 01 00 00    	jns    800bdc <vprintfmt+0x40f>
				putch('-', putdat);
  800ace:	83 ec 08             	sub    $0x8,%esp
  800ad1:	53                   	push   %ebx
  800ad2:	6a 2d                	push   $0x2d
  800ad4:	ff d6                	call   *%esi
				num = -(long long) num;
  800ad6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800ad9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800adc:	f7 da                	neg    %edx
  800ade:	83 d1 00             	adc    $0x0,%ecx
  800ae1:	f7 d9                	neg    %ecx
  800ae3:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  800ae6:	b8 0a 00 00 00       	mov    $0xa,%eax
  800aeb:	e9 ec 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800af0:	83 f9 01             	cmp    $0x1,%ecx
  800af3:	7e 18                	jle    800b0d <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  800af5:	8b 45 14             	mov    0x14(%ebp),%eax
  800af8:	8b 10                	mov    (%eax),%edx
  800afa:	8b 48 04             	mov    0x4(%eax),%ecx
  800afd:	8d 40 08             	lea    0x8(%eax),%eax
  800b00:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b03:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b08:	e9 cf 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 1a                	je     800b2b <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  800b11:	8b 45 14             	mov    0x14(%ebp),%eax
  800b14:	8b 10                	mov    (%eax),%edx
  800b16:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b1b:	8d 40 04             	lea    0x4(%eax),%eax
  800b1e:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b21:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b26:	e9 b1 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800b2b:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2e:	8b 10                	mov    (%eax),%edx
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	8d 40 04             	lea    0x4(%eax),%eax
  800b38:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  800b3b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b40:	e9 97 00 00 00       	jmp    800bdc <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800b45:	83 ec 08             	sub    $0x8,%esp
  800b48:	53                   	push   %ebx
  800b49:	6a 58                	push   $0x58
  800b4b:	ff d6                	call   *%esi
			putch('X', putdat);
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	53                   	push   %ebx
  800b51:	6a 58                	push   $0x58
  800b53:	ff d6                	call   *%esi
			putch('X', putdat);
  800b55:	83 c4 08             	add    $0x8,%esp
  800b58:	53                   	push   %ebx
  800b59:	6a 58                	push   $0x58
  800b5b:	ff d6                	call   *%esi
			break;
  800b5d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800b60:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  800b63:	e9 8b fc ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  800b68:	83 ec 08             	sub    $0x8,%esp
  800b6b:	53                   	push   %ebx
  800b6c:	6a 30                	push   $0x30
  800b6e:	ff d6                	call   *%esi
			putch('x', putdat);
  800b70:	83 c4 08             	add    $0x8,%esp
  800b73:	53                   	push   %ebx
  800b74:	6a 78                	push   $0x78
  800b76:	ff d6                	call   *%esi
			num = (unsigned long long)
  800b78:	8b 45 14             	mov    0x14(%ebp),%eax
  800b7b:	8b 10                	mov    (%eax),%edx
  800b7d:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800b82:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800b85:	8d 40 04             	lea    0x4(%eax),%eax
  800b88:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  800b8b:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800b90:	eb 4a                	jmp    800bdc <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b92:	83 f9 01             	cmp    $0x1,%ecx
  800b95:	7e 15                	jle    800bac <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  800b97:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9a:	8b 10                	mov    (%eax),%edx
  800b9c:	8b 48 04             	mov    0x4(%eax),%ecx
  800b9f:	8d 40 08             	lea    0x8(%eax),%eax
  800ba2:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800ba5:	b8 10 00 00 00       	mov    $0x10,%eax
  800baa:	eb 30                	jmp    800bdc <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800bac:	85 c9                	test   %ecx,%ecx
  800bae:	74 17                	je     800bc7 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  800bb0:	8b 45 14             	mov    0x14(%ebp),%eax
  800bb3:	8b 10                	mov    (%eax),%edx
  800bb5:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bba:	8d 40 04             	lea    0x4(%eax),%eax
  800bbd:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bc0:	b8 10 00 00 00       	mov    $0x10,%eax
  800bc5:	eb 15                	jmp    800bdc <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  800bc7:	8b 45 14             	mov    0x14(%ebp),%eax
  800bca:	8b 10                	mov    (%eax),%edx
  800bcc:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bd1:	8d 40 04             	lea    0x4(%eax),%eax
  800bd4:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  800bd7:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  800bdc:	83 ec 0c             	sub    $0xc,%esp
  800bdf:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  800be3:	57                   	push   %edi
  800be4:	ff 75 e0             	pushl  -0x20(%ebp)
  800be7:	50                   	push   %eax
  800be8:	51                   	push   %ecx
  800be9:	52                   	push   %edx
  800bea:	89 da                	mov    %ebx,%edx
  800bec:	89 f0                	mov    %esi,%eax
  800bee:	e8 f1 fa ff ff       	call   8006e4 <printnum>
			break;
  800bf3:	83 c4 20             	add    $0x20,%esp
  800bf6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800bf9:	e9 f5 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800bfe:	83 ec 08             	sub    $0x8,%esp
  800c01:	53                   	push   %ebx
  800c02:	52                   	push   %edx
  800c03:	ff d6                	call   *%esi
			break;
  800c05:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800c08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  800c0b:	e9 e3 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c10:	83 ec 08             	sub    $0x8,%esp
  800c13:	53                   	push   %ebx
  800c14:	6a 25                	push   $0x25
  800c16:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c18:	83 c4 10             	add    $0x10,%esp
  800c1b:	eb 03                	jmp    800c20 <vprintfmt+0x453>
  800c1d:	83 ef 01             	sub    $0x1,%edi
  800c20:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800c24:	75 f7                	jne    800c1d <vprintfmt+0x450>
  800c26:	e9 c8 fb ff ff       	jmp    8007f3 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	83 ec 18             	sub    $0x18,%esp
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800c3f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800c42:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800c46:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800c49:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800c50:	85 c0                	test   %eax,%eax
  800c52:	74 26                	je     800c7a <vsnprintf+0x47>
  800c54:	85 d2                	test   %edx,%edx
  800c56:	7e 22                	jle    800c7a <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800c58:	ff 75 14             	pushl  0x14(%ebp)
  800c5b:	ff 75 10             	pushl  0x10(%ebp)
  800c5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800c61:	50                   	push   %eax
  800c62:	68 93 07 80 00       	push   $0x800793
  800c67:	e8 61 fb ff ff       	call   8007cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800c6c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800c6f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800c72:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	eb 05                	jmp    800c7f <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  800c7a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800c7f:	c9                   	leave  
  800c80:	c3                   	ret    

00800c81 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c87:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800c8a:	50                   	push   %eax
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	ff 75 08             	pushl  0x8(%ebp)
  800c94:	e8 9a ff ff ff       	call   800c33 <vsnprintf>
	va_end(ap);

	return rc;
}
  800c99:	c9                   	leave  
  800c9a:	c3                   	ret    

00800c9b <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ca1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ca6:	eb 03                	jmp    800cab <strlen+0x10>
		n++;
  800ca8:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800cab:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800caf:	75 f7                	jne    800ca8 <strlen+0xd>
		n++;
	return n;
}
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb9:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cbc:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc1:	eb 03                	jmp    800cc6 <strnlen+0x13>
		n++;
  800cc3:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800cc6:	39 c2                	cmp    %eax,%edx
  800cc8:	74 08                	je     800cd2 <strnlen+0x1f>
  800cca:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  800cce:	75 f3                	jne    800cc3 <strnlen+0x10>
  800cd0:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	53                   	push   %ebx
  800cd8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800cde:	89 c2                	mov    %eax,%edx
  800ce0:	83 c2 01             	add    $0x1,%edx
  800ce3:	83 c1 01             	add    $0x1,%ecx
  800ce6:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  800cea:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ced:	84 db                	test   %bl,%bl
  800cef:	75 ef                	jne    800ce0 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  800cf1:	5b                   	pop    %ebx
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800cfb:	53                   	push   %ebx
  800cfc:	e8 9a ff ff ff       	call   800c9b <strlen>
  800d01:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  800d04:	ff 75 0c             	pushl  0xc(%ebp)
  800d07:	01 d8                	add    %ebx,%eax
  800d09:	50                   	push   %eax
  800d0a:	e8 c5 ff ff ff       	call   800cd4 <strcpy>
	return dst;
}
  800d0f:	89 d8                	mov    %ebx,%eax
  800d11:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	56                   	push   %esi
  800d1a:	53                   	push   %ebx
  800d1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800d1e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d21:	89 f3                	mov    %esi,%ebx
  800d23:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d26:	89 f2                	mov    %esi,%edx
  800d28:	eb 0f                	jmp    800d39 <strncpy+0x23>
		*dst++ = *src;
  800d2a:	83 c2 01             	add    $0x1,%edx
  800d2d:	0f b6 01             	movzbl (%ecx),%eax
  800d30:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800d33:	80 39 01             	cmpb   $0x1,(%ecx)
  800d36:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d39:	39 da                	cmp    %ebx,%edx
  800d3b:	75 ed                	jne    800d2a <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800d3d:	89 f0                	mov    %esi,%eax
  800d3f:	5b                   	pop    %ebx
  800d40:	5e                   	pop    %esi
  800d41:	5d                   	pop    %ebp
  800d42:	c3                   	ret    

00800d43 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	56                   	push   %esi
  800d47:	53                   	push   %ebx
  800d48:	8b 75 08             	mov    0x8(%ebp),%esi
  800d4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4e:	8b 55 10             	mov    0x10(%ebp),%edx
  800d51:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800d53:	85 d2                	test   %edx,%edx
  800d55:	74 21                	je     800d78 <strlcpy+0x35>
  800d57:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800d5b:	89 f2                	mov    %esi,%edx
  800d5d:	eb 09                	jmp    800d68 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800d5f:	83 c2 01             	add    $0x1,%edx
  800d62:	83 c1 01             	add    $0x1,%ecx
  800d65:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d68:	39 c2                	cmp    %eax,%edx
  800d6a:	74 09                	je     800d75 <strlcpy+0x32>
  800d6c:	0f b6 19             	movzbl (%ecx),%ebx
  800d6f:	84 db                	test   %bl,%bl
  800d71:	75 ec                	jne    800d5f <strlcpy+0x1c>
  800d73:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800d75:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d78:	29 f0                	sub    %esi,%eax
}
  800d7a:	5b                   	pop    %ebx
  800d7b:	5e                   	pop    %esi
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d84:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800d87:	eb 06                	jmp    800d8f <strcmp+0x11>
		p++, q++;
  800d89:	83 c1 01             	add    $0x1,%ecx
  800d8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d8f:	0f b6 01             	movzbl (%ecx),%eax
  800d92:	84 c0                	test   %al,%al
  800d94:	74 04                	je     800d9a <strcmp+0x1c>
  800d96:	3a 02                	cmp    (%edx),%al
  800d98:	74 ef                	je     800d89 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d9a:	0f b6 c0             	movzbl %al,%eax
  800d9d:	0f b6 12             	movzbl (%edx),%edx
  800da0:	29 d0                	sub    %edx,%eax
}
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	53                   	push   %ebx
  800da8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dab:	8b 55 0c             	mov    0xc(%ebp),%edx
  800dae:	89 c3                	mov    %eax,%ebx
  800db0:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800db3:	eb 06                	jmp    800dbb <strncmp+0x17>
		n--, p++, q++;
  800db5:	83 c0 01             	add    $0x1,%eax
  800db8:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dbb:	39 d8                	cmp    %ebx,%eax
  800dbd:	74 15                	je     800dd4 <strncmp+0x30>
  800dbf:	0f b6 08             	movzbl (%eax),%ecx
  800dc2:	84 c9                	test   %cl,%cl
  800dc4:	74 04                	je     800dca <strncmp+0x26>
  800dc6:	3a 0a                	cmp    (%edx),%cl
  800dc8:	74 eb                	je     800db5 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dca:	0f b6 00             	movzbl (%eax),%eax
  800dcd:	0f b6 12             	movzbl (%edx),%edx
  800dd0:	29 d0                	sub    %edx,%eax
  800dd2:	eb 05                	jmp    800dd9 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800dd4:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800dd9:	5b                   	pop    %ebx
  800dda:	5d                   	pop    %ebp
  800ddb:	c3                   	ret    

00800ddc <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ddc:	55                   	push   %ebp
  800ddd:	89 e5                	mov    %esp,%ebp
  800ddf:	8b 45 08             	mov    0x8(%ebp),%eax
  800de2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800de6:	eb 07                	jmp    800def <strchr+0x13>
		if (*s == c)
  800de8:	38 ca                	cmp    %cl,%dl
  800dea:	74 0f                	je     800dfb <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dec:	83 c0 01             	add    $0x1,%eax
  800def:	0f b6 10             	movzbl (%eax),%edx
  800df2:	84 d2                	test   %dl,%dl
  800df4:	75 f2                	jne    800de8 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800df6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfb:	5d                   	pop    %ebp
  800dfc:	c3                   	ret    

00800dfd <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfd:	55                   	push   %ebp
  800dfe:	89 e5                	mov    %esp,%ebp
  800e00:	8b 45 08             	mov    0x8(%ebp),%eax
  800e03:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e07:	eb 03                	jmp    800e0c <strfind+0xf>
  800e09:	83 c0 01             	add    $0x1,%eax
  800e0c:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800e0f:	38 ca                	cmp    %cl,%dl
  800e11:	74 04                	je     800e17 <strfind+0x1a>
  800e13:	84 d2                	test   %dl,%dl
  800e15:	75 f2                	jne    800e09 <strfind+0xc>
			break;
	return (char *) s;
}
  800e17:	5d                   	pop    %ebp
  800e18:	c3                   	ret    

00800e19 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e19:	55                   	push   %ebp
  800e1a:	89 e5                	mov    %esp,%ebp
  800e1c:	57                   	push   %edi
  800e1d:	56                   	push   %esi
  800e1e:	53                   	push   %ebx
  800e1f:	8b 7d 08             	mov    0x8(%ebp),%edi
  800e22:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800e25:	85 c9                	test   %ecx,%ecx
  800e27:	74 36                	je     800e5f <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800e29:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e2f:	75 28                	jne    800e59 <memset+0x40>
  800e31:	f6 c1 03             	test   $0x3,%cl
  800e34:	75 23                	jne    800e59 <memset+0x40>
		c &= 0xFF;
  800e36:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e3a:	89 d3                	mov    %edx,%ebx
  800e3c:	c1 e3 08             	shl    $0x8,%ebx
  800e3f:	89 d6                	mov    %edx,%esi
  800e41:	c1 e6 18             	shl    $0x18,%esi
  800e44:	89 d0                	mov    %edx,%eax
  800e46:	c1 e0 10             	shl    $0x10,%eax
  800e49:	09 f0                	or     %esi,%eax
  800e4b:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800e4d:	89 d8                	mov    %ebx,%eax
  800e4f:	09 d0                	or     %edx,%eax
  800e51:	c1 e9 02             	shr    $0x2,%ecx
  800e54:	fc                   	cld    
  800e55:	f3 ab                	rep stos %eax,%es:(%edi)
  800e57:	eb 06                	jmp    800e5f <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	fc                   	cld    
  800e5d:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800e5f:	89 f8                	mov    %edi,%eax
  800e61:	5b                   	pop    %ebx
  800e62:	5e                   	pop    %esi
  800e63:	5f                   	pop    %edi
  800e64:	5d                   	pop    %ebp
  800e65:	c3                   	ret    

00800e66 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e66:	55                   	push   %ebp
  800e67:	89 e5                	mov    %esp,%ebp
  800e69:	57                   	push   %edi
  800e6a:	56                   	push   %esi
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e6e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800e71:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e74:	39 c6                	cmp    %eax,%esi
  800e76:	73 35                	jae    800ead <memmove+0x47>
  800e78:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e7b:	39 d0                	cmp    %edx,%eax
  800e7d:	73 2e                	jae    800ead <memmove+0x47>
		s += n;
		d += n;
  800e7f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e82:	89 d6                	mov    %edx,%esi
  800e84:	09 fe                	or     %edi,%esi
  800e86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e8c:	75 13                	jne    800ea1 <memmove+0x3b>
  800e8e:	f6 c1 03             	test   $0x3,%cl
  800e91:	75 0e                	jne    800ea1 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800e93:	83 ef 04             	sub    $0x4,%edi
  800e96:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e99:	c1 e9 02             	shr    $0x2,%ecx
  800e9c:	fd                   	std    
  800e9d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800e9f:	eb 09                	jmp    800eaa <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800ea1:	83 ef 01             	sub    $0x1,%edi
  800ea4:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ea7:	fd                   	std    
  800ea8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800eaa:	fc                   	cld    
  800eab:	eb 1d                	jmp    800eca <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ead:	89 f2                	mov    %esi,%edx
  800eaf:	09 c2                	or     %eax,%edx
  800eb1:	f6 c2 03             	test   $0x3,%dl
  800eb4:	75 0f                	jne    800ec5 <memmove+0x5f>
  800eb6:	f6 c1 03             	test   $0x3,%cl
  800eb9:	75 0a                	jne    800ec5 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ebb:	c1 e9 02             	shr    $0x2,%ecx
  800ebe:	89 c7                	mov    %eax,%edi
  800ec0:	fc                   	cld    
  800ec1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ec3:	eb 05                	jmp    800eca <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ec5:	89 c7                	mov    %eax,%edi
  800ec7:	fc                   	cld    
  800ec8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800eca:	5e                   	pop    %esi
  800ecb:	5f                   	pop    %edi
  800ecc:	5d                   	pop    %ebp
  800ecd:	c3                   	ret    

00800ece <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ece:	55                   	push   %ebp
  800ecf:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ed1:	ff 75 10             	pushl  0x10(%ebp)
  800ed4:	ff 75 0c             	pushl  0xc(%ebp)
  800ed7:	ff 75 08             	pushl  0x8(%ebp)
  800eda:	e8 87 ff ff ff       	call   800e66 <memmove>
}
  800edf:	c9                   	leave  
  800ee0:	c3                   	ret    

00800ee1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ee1:	55                   	push   %ebp
  800ee2:	89 e5                	mov    %esp,%ebp
  800ee4:	56                   	push   %esi
  800ee5:	53                   	push   %ebx
  800ee6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ee9:	8b 55 0c             	mov    0xc(%ebp),%edx
  800eec:	89 c6                	mov    %eax,%esi
  800eee:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ef1:	eb 1a                	jmp    800f0d <memcmp+0x2c>
		if (*s1 != *s2)
  800ef3:	0f b6 08             	movzbl (%eax),%ecx
  800ef6:	0f b6 1a             	movzbl (%edx),%ebx
  800ef9:	38 d9                	cmp    %bl,%cl
  800efb:	74 0a                	je     800f07 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800efd:	0f b6 c1             	movzbl %cl,%eax
  800f00:	0f b6 db             	movzbl %bl,%ebx
  800f03:	29 d8                	sub    %ebx,%eax
  800f05:	eb 0f                	jmp    800f16 <memcmp+0x35>
		s1++, s2++;
  800f07:	83 c0 01             	add    $0x1,%eax
  800f0a:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f0d:	39 f0                	cmp    %esi,%eax
  800f0f:	75 e2                	jne    800ef3 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800f11:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800f16:	5b                   	pop    %ebx
  800f17:	5e                   	pop    %esi
  800f18:	5d                   	pop    %ebp
  800f19:	c3                   	ret    

00800f1a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800f1a:	55                   	push   %ebp
  800f1b:	89 e5                	mov    %esp,%ebp
  800f1d:	53                   	push   %ebx
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800f21:	89 c1                	mov    %eax,%ecx
  800f23:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800f26:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f2a:	eb 0a                	jmp    800f36 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f2c:	0f b6 10             	movzbl (%eax),%edx
  800f2f:	39 da                	cmp    %ebx,%edx
  800f31:	74 07                	je     800f3a <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f33:	83 c0 01             	add    $0x1,%eax
  800f36:	39 c8                	cmp    %ecx,%eax
  800f38:	72 f2                	jb     800f2c <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f3a:	5b                   	pop    %ebx
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	57                   	push   %edi
  800f41:	56                   	push   %esi
  800f42:	53                   	push   %ebx
  800f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f46:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f49:	eb 03                	jmp    800f4e <strtol+0x11>
		s++;
  800f4b:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f4e:	0f b6 01             	movzbl (%ecx),%eax
  800f51:	3c 20                	cmp    $0x20,%al
  800f53:	74 f6                	je     800f4b <strtol+0xe>
  800f55:	3c 09                	cmp    $0x9,%al
  800f57:	74 f2                	je     800f4b <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f59:	3c 2b                	cmp    $0x2b,%al
  800f5b:	75 0a                	jne    800f67 <strtol+0x2a>
		s++;
  800f5d:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800f60:	bf 00 00 00 00       	mov    $0x0,%edi
  800f65:	eb 11                	jmp    800f78 <strtol+0x3b>
  800f67:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800f6c:	3c 2d                	cmp    $0x2d,%al
  800f6e:	75 08                	jne    800f78 <strtol+0x3b>
		s++, neg = 1;
  800f70:	83 c1 01             	add    $0x1,%ecx
  800f73:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f78:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800f7e:	75 15                	jne    800f95 <strtol+0x58>
  800f80:	80 39 30             	cmpb   $0x30,(%ecx)
  800f83:	75 10                	jne    800f95 <strtol+0x58>
  800f85:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800f89:	75 7c                	jne    801007 <strtol+0xca>
		s += 2, base = 16;
  800f8b:	83 c1 02             	add    $0x2,%ecx
  800f8e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800f93:	eb 16                	jmp    800fab <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800f95:	85 db                	test   %ebx,%ebx
  800f97:	75 12                	jne    800fab <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800f99:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f9e:	80 39 30             	cmpb   $0x30,(%ecx)
  800fa1:	75 08                	jne    800fab <strtol+0x6e>
		s++, base = 8;
  800fa3:	83 c1 01             	add    $0x1,%ecx
  800fa6:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800fab:	b8 00 00 00 00       	mov    $0x0,%eax
  800fb0:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fb3:	0f b6 11             	movzbl (%ecx),%edx
  800fb6:	8d 72 d0             	lea    -0x30(%edx),%esi
  800fb9:	89 f3                	mov    %esi,%ebx
  800fbb:	80 fb 09             	cmp    $0x9,%bl
  800fbe:	77 08                	ja     800fc8 <strtol+0x8b>
			dig = *s - '0';
  800fc0:	0f be d2             	movsbl %dl,%edx
  800fc3:	83 ea 30             	sub    $0x30,%edx
  800fc6:	eb 22                	jmp    800fea <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800fc8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800fcb:	89 f3                	mov    %esi,%ebx
  800fcd:	80 fb 19             	cmp    $0x19,%bl
  800fd0:	77 08                	ja     800fda <strtol+0x9d>
			dig = *s - 'a' + 10;
  800fd2:	0f be d2             	movsbl %dl,%edx
  800fd5:	83 ea 57             	sub    $0x57,%edx
  800fd8:	eb 10                	jmp    800fea <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800fda:	8d 72 bf             	lea    -0x41(%edx),%esi
  800fdd:	89 f3                	mov    %esi,%ebx
  800fdf:	80 fb 19             	cmp    $0x19,%bl
  800fe2:	77 16                	ja     800ffa <strtol+0xbd>
			dig = *s - 'A' + 10;
  800fe4:	0f be d2             	movsbl %dl,%edx
  800fe7:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800fea:	3b 55 10             	cmp    0x10(%ebp),%edx
  800fed:	7d 0b                	jge    800ffa <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800fef:	83 c1 01             	add    $0x1,%ecx
  800ff2:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ff6:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ff8:	eb b9                	jmp    800fb3 <strtol+0x76>

	if (endptr)
  800ffa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ffe:	74 0d                	je     80100d <strtol+0xd0>
		*endptr = (char *) s;
  801000:	8b 75 0c             	mov    0xc(%ebp),%esi
  801003:	89 0e                	mov    %ecx,(%esi)
  801005:	eb 06                	jmp    80100d <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801007:	85 db                	test   %ebx,%ebx
  801009:	74 98                	je     800fa3 <strtol+0x66>
  80100b:	eb 9e                	jmp    800fab <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  80100d:	89 c2                	mov    %eax,%edx
  80100f:	f7 da                	neg    %edx
  801011:	85 ff                	test   %edi,%edi
  801013:	0f 45 c2             	cmovne %edx,%eax
}
  801016:	5b                   	pop    %ebx
  801017:	5e                   	pop    %esi
  801018:	5f                   	pop    %edi
  801019:	5d                   	pop    %ebp
  80101a:	c3                   	ret    

0080101b <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80101b:	55                   	push   %ebp
  80101c:	89 e5                	mov    %esp,%ebp
  80101e:	57                   	push   %edi
  80101f:	56                   	push   %esi
  801020:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801021:	b8 00 00 00 00       	mov    $0x0,%eax
  801026:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801029:	8b 55 08             	mov    0x8(%ebp),%edx
  80102c:	89 c3                	mov    %eax,%ebx
  80102e:	89 c7                	mov    %eax,%edi
  801030:	89 c6                	mov    %eax,%esi
  801032:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801034:	5b                   	pop    %ebx
  801035:	5e                   	pop    %esi
  801036:	5f                   	pop    %edi
  801037:	5d                   	pop    %ebp
  801038:	c3                   	ret    

00801039 <sys_cgetc>:

int
sys_cgetc(void)
{
  801039:	55                   	push   %ebp
  80103a:	89 e5                	mov    %esp,%ebp
  80103c:	57                   	push   %edi
  80103d:	56                   	push   %esi
  80103e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80103f:	ba 00 00 00 00       	mov    $0x0,%edx
  801044:	b8 01 00 00 00       	mov    $0x1,%eax
  801049:	89 d1                	mov    %edx,%ecx
  80104b:	89 d3                	mov    %edx,%ebx
  80104d:	89 d7                	mov    %edx,%edi
  80104f:	89 d6                	mov    %edx,%esi
  801051:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  801053:	5b                   	pop    %ebx
  801054:	5e                   	pop    %esi
  801055:	5f                   	pop    %edi
  801056:	5d                   	pop    %ebp
  801057:	c3                   	ret    

00801058 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801061:	b9 00 00 00 00       	mov    $0x0,%ecx
  801066:	b8 03 00 00 00       	mov    $0x3,%eax
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	89 cb                	mov    %ecx,%ebx
  801070:	89 cf                	mov    %ecx,%edi
  801072:	89 ce                	mov    %ecx,%esi
  801074:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801076:	85 c0                	test   %eax,%eax
  801078:	7e 17                	jle    801091 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	50                   	push   %eax
  80107e:	6a 03                	push   $0x3
  801080:	68 df 2c 80 00       	push   $0x802cdf
  801085:	6a 23                	push   $0x23
  801087:	68 fc 2c 80 00       	push   $0x802cfc
  80108c:	e8 66 f5 ff ff       	call   8005f7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801091:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801094:	5b                   	pop    %ebx
  801095:	5e                   	pop    %esi
  801096:	5f                   	pop    %edi
  801097:	5d                   	pop    %ebp
  801098:	c3                   	ret    

00801099 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  801099:	55                   	push   %ebp
  80109a:	89 e5                	mov    %esp,%ebp
  80109c:	57                   	push   %edi
  80109d:	56                   	push   %esi
  80109e:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80109f:	ba 00 00 00 00       	mov    $0x0,%edx
  8010a4:	b8 02 00 00 00       	mov    $0x2,%eax
  8010a9:	89 d1                	mov    %edx,%ecx
  8010ab:	89 d3                	mov    %edx,%ebx
  8010ad:	89 d7                	mov    %edx,%edi
  8010af:	89 d6                	mov    %edx,%esi
  8010b1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8010b3:	5b                   	pop    %ebx
  8010b4:	5e                   	pop    %esi
  8010b5:	5f                   	pop    %edi
  8010b6:	5d                   	pop    %ebp
  8010b7:	c3                   	ret    

008010b8 <sys_yield>:

void
sys_yield(void)
{
  8010b8:	55                   	push   %ebp
  8010b9:	89 e5                	mov    %esp,%ebp
  8010bb:	57                   	push   %edi
  8010bc:	56                   	push   %esi
  8010bd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010be:	ba 00 00 00 00       	mov    $0x0,%edx
  8010c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8010c8:	89 d1                	mov    %edx,%ecx
  8010ca:	89 d3                	mov    %edx,%ebx
  8010cc:	89 d7                	mov    %edx,%edi
  8010ce:	89 d6                	mov    %edx,%esi
  8010d0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8010d2:	5b                   	pop    %ebx
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    

008010d7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010d7:	55                   	push   %ebp
  8010d8:	89 e5                	mov    %esp,%ebp
  8010da:	57                   	push   %edi
  8010db:	56                   	push   %esi
  8010dc:	53                   	push   %ebx
  8010dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010e0:	be 00 00 00 00       	mov    $0x0,%esi
  8010e5:	b8 04 00 00 00       	mov    $0x4,%eax
  8010ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8010f0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010f3:	89 f7                	mov    %esi,%edi
  8010f5:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	7e 17                	jle    801112 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010fb:	83 ec 0c             	sub    $0xc,%esp
  8010fe:	50                   	push   %eax
  8010ff:	6a 04                	push   $0x4
  801101:	68 df 2c 80 00       	push   $0x802cdf
  801106:	6a 23                	push   $0x23
  801108:	68 fc 2c 80 00       	push   $0x802cfc
  80110d:	e8 e5 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801112:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801115:	5b                   	pop    %ebx
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    

0080111a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80111a:	55                   	push   %ebp
  80111b:	89 e5                	mov    %esp,%ebp
  80111d:	57                   	push   %edi
  80111e:	56                   	push   %esi
  80111f:	53                   	push   %ebx
  801120:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801123:	b8 05 00 00 00       	mov    $0x5,%eax
  801128:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801131:	8b 7d 14             	mov    0x14(%ebp),%edi
  801134:	8b 75 18             	mov    0x18(%ebp),%esi
  801137:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801139:	85 c0                	test   %eax,%eax
  80113b:	7e 17                	jle    801154 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80113d:	83 ec 0c             	sub    $0xc,%esp
  801140:	50                   	push   %eax
  801141:	6a 05                	push   $0x5
  801143:	68 df 2c 80 00       	push   $0x802cdf
  801148:	6a 23                	push   $0x23
  80114a:	68 fc 2c 80 00       	push   $0x802cfc
  80114f:	e8 a3 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801154:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801157:	5b                   	pop    %ebx
  801158:	5e                   	pop    %esi
  801159:	5f                   	pop    %edi
  80115a:	5d                   	pop    %ebp
  80115b:	c3                   	ret    

0080115c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80115c:	55                   	push   %ebp
  80115d:	89 e5                	mov    %esp,%ebp
  80115f:	57                   	push   %edi
  801160:	56                   	push   %esi
  801161:	53                   	push   %ebx
  801162:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801165:	bb 00 00 00 00       	mov    $0x0,%ebx
  80116a:	b8 06 00 00 00       	mov    $0x6,%eax
  80116f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801172:	8b 55 08             	mov    0x8(%ebp),%edx
  801175:	89 df                	mov    %ebx,%edi
  801177:	89 de                	mov    %ebx,%esi
  801179:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80117b:	85 c0                	test   %eax,%eax
  80117d:	7e 17                	jle    801196 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80117f:	83 ec 0c             	sub    $0xc,%esp
  801182:	50                   	push   %eax
  801183:	6a 06                	push   $0x6
  801185:	68 df 2c 80 00       	push   $0x802cdf
  80118a:	6a 23                	push   $0x23
  80118c:	68 fc 2c 80 00       	push   $0x802cfc
  801191:	e8 61 f4 ff ff       	call   8005f7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801196:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801199:	5b                   	pop    %ebx
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    

0080119e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80119e:	55                   	push   %ebp
  80119f:	89 e5                	mov    %esp,%ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011a7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ac:	b8 08 00 00 00       	mov    $0x8,%eax
  8011b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8011b7:	89 df                	mov    %ebx,%edi
  8011b9:	89 de                	mov    %ebx,%esi
  8011bb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011bd:	85 c0                	test   %eax,%eax
  8011bf:	7e 17                	jle    8011d8 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011c1:	83 ec 0c             	sub    $0xc,%esp
  8011c4:	50                   	push   %eax
  8011c5:	6a 08                	push   $0x8
  8011c7:	68 df 2c 80 00       	push   $0x802cdf
  8011cc:	6a 23                	push   $0x23
  8011ce:	68 fc 2c 80 00       	push   $0x802cfc
  8011d3:	e8 1f f4 ff ff       	call   8005f7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  8011d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011db:	5b                   	pop    %ebx
  8011dc:	5e                   	pop    %esi
  8011dd:	5f                   	pop    %edi
  8011de:	5d                   	pop    %ebp
  8011df:	c3                   	ret    

008011e0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	53                   	push   %ebx
  8011e6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011ee:	b8 09 00 00 00       	mov    $0x9,%eax
  8011f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8011f9:	89 df                	mov    %ebx,%edi
  8011fb:	89 de                	mov    %ebx,%esi
  8011fd:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8011ff:	85 c0                	test   %eax,%eax
  801201:	7e 17                	jle    80121a <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801203:	83 ec 0c             	sub    $0xc,%esp
  801206:	50                   	push   %eax
  801207:	6a 09                	push   $0x9
  801209:	68 df 2c 80 00       	push   $0x802cdf
  80120e:	6a 23                	push   $0x23
  801210:	68 fc 2c 80 00       	push   $0x802cfc
  801215:	e8 dd f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80121a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121d:	5b                   	pop    %ebx
  80121e:	5e                   	pop    %esi
  80121f:	5f                   	pop    %edi
  801220:	5d                   	pop    %ebp
  801221:	c3                   	ret    

00801222 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801222:	55                   	push   %ebp
  801223:	89 e5                	mov    %esp,%ebp
  801225:	57                   	push   %edi
  801226:	56                   	push   %esi
  801227:	53                   	push   %ebx
  801228:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80122b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801230:	b8 0a 00 00 00       	mov    $0xa,%eax
  801235:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801238:	8b 55 08             	mov    0x8(%ebp),%edx
  80123b:	89 df                	mov    %ebx,%edi
  80123d:	89 de                	mov    %ebx,%esi
  80123f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  801241:	85 c0                	test   %eax,%eax
  801243:	7e 17                	jle    80125c <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	50                   	push   %eax
  801249:	6a 0a                	push   $0xa
  80124b:	68 df 2c 80 00       	push   $0x802cdf
  801250:	6a 23                	push   $0x23
  801252:	68 fc 2c 80 00       	push   $0x802cfc
  801257:	e8 9b f3 ff ff       	call   8005f7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80125c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80125f:	5b                   	pop    %ebx
  801260:	5e                   	pop    %esi
  801261:	5f                   	pop    %edi
  801262:	5d                   	pop    %ebp
  801263:	c3                   	ret    

00801264 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	57                   	push   %edi
  801268:	56                   	push   %esi
  801269:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80126a:	be 00 00 00 00       	mov    $0x0,%esi
  80126f:	b8 0c 00 00 00       	mov    $0xc,%eax
  801274:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801277:	8b 55 08             	mov    0x8(%ebp),%edx
  80127a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80127d:	8b 7d 14             	mov    0x14(%ebp),%edi
  801280:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801282:	5b                   	pop    %ebx
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801287:	55                   	push   %ebp
  801288:	89 e5                	mov    %esp,%ebp
  80128a:	57                   	push   %edi
  80128b:	56                   	push   %esi
  80128c:	53                   	push   %ebx
  80128d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801290:	b9 00 00 00 00       	mov    $0x0,%ecx
  801295:	b8 0d 00 00 00       	mov    $0xd,%eax
  80129a:	8b 55 08             	mov    0x8(%ebp),%edx
  80129d:	89 cb                	mov    %ecx,%ebx
  80129f:	89 cf                	mov    %ecx,%edi
  8012a1:	89 ce                	mov    %ecx,%esi
  8012a3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8012a5:	85 c0                	test   %eax,%eax
  8012a7:	7e 17                	jle    8012c0 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012a9:	83 ec 0c             	sub    $0xc,%esp
  8012ac:	50                   	push   %eax
  8012ad:	6a 0d                	push   $0xd
  8012af:	68 df 2c 80 00       	push   $0x802cdf
  8012b4:	6a 23                	push   $0x23
  8012b6:	68 fc 2c 80 00       	push   $0x802cfc
  8012bb:	e8 37 f3 ff ff       	call   8005f7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8012c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c3:	5b                   	pop    %ebx
  8012c4:	5e                   	pop    %esi
  8012c5:	5f                   	pop    %edi
  8012c6:	5d                   	pop    %ebp
  8012c7:	c3                   	ret    

008012c8 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  8012c8:	55                   	push   %ebp
  8012c9:	89 e5                	mov    %esp,%ebp
  8012cb:	57                   	push   %edi
  8012cc:	56                   	push   %esi
  8012cd:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d3:	b8 0e 00 00 00       	mov    $0xe,%eax
  8012d8:	89 d1                	mov    %edx,%ecx
  8012da:	89 d3                	mov    %edx,%ebx
  8012dc:	89 d7                	mov    %edx,%edi
  8012de:	89 d6                	mov    %edx,%esi
  8012e0:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  8012e2:	5b                   	pop    %ebx
  8012e3:	5e                   	pop    %esi
  8012e4:	5f                   	pop    %edi
  8012e5:	5d                   	pop    %ebp
  8012e6:	c3                   	ret    

008012e7 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  8012e7:	55                   	push   %ebp
  8012e8:	89 e5                	mov    %esp,%ebp
  8012ea:	57                   	push   %edi
  8012eb:	56                   	push   %esi
  8012ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8012f2:	b8 10 00 00 00       	mov    $0x10,%eax
  8012f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8012fa:	89 cb                	mov    %ecx,%ebx
  8012fc:	89 cf                	mov    %ecx,%edi
  8012fe:	89 ce                	mov    %ecx,%esi
  801300:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  801302:	5b                   	pop    %ebx
  801303:	5e                   	pop    %esi
  801304:	5f                   	pop    %edi
  801305:	5d                   	pop    %ebp
  801306:	c3                   	ret    

00801307 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801307:	55                   	push   %ebp
  801308:	89 e5                	mov    %esp,%ebp
  80130a:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80130d:	83 3d b8 40 80 00 00 	cmpl   $0x0,0x8040b8
  801314:	75 4a                	jne    801360 <set_pgfault_handler+0x59>
		// First time through!
		// LAB 4: Your code here.
		if ((r = sys_page_alloc(thisenv->env_id, (void *)(UXSTACKTOP - PGSIZE), PTE_P | PTE_W | PTE_U)) < 0)
  801316:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80131b:	8b 40 48             	mov    0x48(%eax),%eax
  80131e:	83 ec 04             	sub    $0x4,%esp
  801321:	6a 07                	push   $0x7
  801323:	68 00 f0 bf ee       	push   $0xeebff000
  801328:	50                   	push   %eax
  801329:	e8 a9 fd ff ff       	call   8010d7 <sys_page_alloc>
  80132e:	83 c4 10             	add    $0x10,%esp
  801331:	85 c0                	test   %eax,%eax
  801333:	79 12                	jns    801347 <set_pgfault_handler+0x40>
           	panic("set_pgfault_handler: %e", r);
  801335:	50                   	push   %eax
  801336:	68 0a 2d 80 00       	push   $0x802d0a
  80133b:	6a 21                	push   $0x21
  80133d:	68 22 2d 80 00       	push   $0x802d22
  801342:	e8 b0 f2 ff ff       	call   8005f7 <_panic>
        sys_env_set_pgfault_upcall(thisenv->env_id, _pgfault_upcall);
  801347:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80134c:	8b 40 48             	mov    0x48(%eax),%eax
  80134f:	83 ec 08             	sub    $0x8,%esp
  801352:	68 6a 13 80 00       	push   $0x80136a
  801357:	50                   	push   %eax
  801358:	e8 c5 fe ff ff       	call   801222 <sys_env_set_pgfault_upcall>
  80135d:	83 c4 10             	add    $0x10,%esp
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801360:	8b 45 08             	mov    0x8(%ebp),%eax
  801363:	a3 b8 40 80 00       	mov    %eax,0x8040b8
  801368:	c9                   	leave  
  801369:	c3                   	ret    

0080136a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80136a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80136b:	a1 b8 40 80 00       	mov    0x8040b8,%eax
	call *%eax
  801370:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  801372:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	addl $8, %esp
  801375:	83 c4 08             	add    $0x8,%esp
    movl 0x20(%esp), %eax
  801378:	8b 44 24 20          	mov    0x20(%esp),%eax
    subl $4, 0x28(%esp) // reserve 32bit space for trap time eip
  80137c:	83 6c 24 28 04       	subl   $0x4,0x28(%esp)
    movl 0x28(%esp), %edx
  801381:	8b 54 24 28          	mov    0x28(%esp),%edx
    movl %eax, (%edx)
  801385:	89 02                	mov    %eax,(%edx)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	popal
  801387:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
 	addl $4, %esp
  801388:	83 c4 04             	add    $0x4,%esp
	popfl
  80138b:	9d                   	popf   
	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  80138c:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
	ret 
  80138d:	c3                   	ret    

0080138e <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80138e:	55                   	push   %ebp
  80138f:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801391:	8b 45 08             	mov    0x8(%ebp),%eax
  801394:	05 00 00 00 30       	add    $0x30000000,%eax
  801399:	c1 e8 0c             	shr    $0xc,%eax
}
  80139c:	5d                   	pop    %ebp
  80139d:	c3                   	ret    

0080139e <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80139e:	55                   	push   %ebp
  80139f:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8013a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013a4:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8013ae:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013b3:	5d                   	pop    %ebp
  8013b4:	c3                   	ret    

008013b5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013b5:	55                   	push   %ebp
  8013b6:	89 e5                	mov    %esp,%ebp
  8013b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013bb:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013c0:	89 c2                	mov    %eax,%edx
  8013c2:	c1 ea 16             	shr    $0x16,%edx
  8013c5:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013cc:	f6 c2 01             	test   $0x1,%dl
  8013cf:	74 11                	je     8013e2 <fd_alloc+0x2d>
  8013d1:	89 c2                	mov    %eax,%edx
  8013d3:	c1 ea 0c             	shr    $0xc,%edx
  8013d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013dd:	f6 c2 01             	test   $0x1,%dl
  8013e0:	75 09                	jne    8013eb <fd_alloc+0x36>
			*fd_store = fd;
  8013e2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013e4:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e9:	eb 17                	jmp    801402 <fd_alloc+0x4d>
  8013eb:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8013f0:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013f5:	75 c9                	jne    8013c0 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013f7:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8013fd:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  801402:	5d                   	pop    %ebp
  801403:	c3                   	ret    

00801404 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80140a:	83 f8 1f             	cmp    $0x1f,%eax
  80140d:	77 36                	ja     801445 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80140f:	c1 e0 0c             	shl    $0xc,%eax
  801412:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801417:	89 c2                	mov    %eax,%edx
  801419:	c1 ea 16             	shr    $0x16,%edx
  80141c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801423:	f6 c2 01             	test   $0x1,%dl
  801426:	74 24                	je     80144c <fd_lookup+0x48>
  801428:	89 c2                	mov    %eax,%edx
  80142a:	c1 ea 0c             	shr    $0xc,%edx
  80142d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801434:	f6 c2 01             	test   $0x1,%dl
  801437:	74 1a                	je     801453 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801439:	8b 55 0c             	mov    0xc(%ebp),%edx
  80143c:	89 02                	mov    %eax,(%edx)
	return 0;
  80143e:	b8 00 00 00 00       	mov    $0x0,%eax
  801443:	eb 13                	jmp    801458 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  801445:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80144a:	eb 0c                	jmp    801458 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80144c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801451:	eb 05                	jmp    801458 <fd_lookup+0x54>
  801453:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    

0080145a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80145a:	55                   	push   %ebp
  80145b:	89 e5                	mov    %esp,%ebp
  80145d:	83 ec 08             	sub    $0x8,%esp
  801460:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801463:	ba b0 2d 80 00       	mov    $0x802db0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801468:	eb 13                	jmp    80147d <dev_lookup+0x23>
  80146a:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80146d:	39 08                	cmp    %ecx,(%eax)
  80146f:	75 0c                	jne    80147d <dev_lookup+0x23>
			*dev = devtab[i];
  801471:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801474:	89 01                	mov    %eax,(%ecx)
			return 0;
  801476:	b8 00 00 00 00       	mov    $0x0,%eax
  80147b:	eb 2e                	jmp    8014ab <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80147d:	8b 02                	mov    (%edx),%eax
  80147f:	85 c0                	test   %eax,%eax
  801481:	75 e7                	jne    80146a <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801483:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801488:	8b 40 48             	mov    0x48(%eax),%eax
  80148b:	83 ec 04             	sub    $0x4,%esp
  80148e:	51                   	push   %ecx
  80148f:	50                   	push   %eax
  801490:	68 30 2d 80 00       	push   $0x802d30
  801495:	e8 36 f2 ff ff       	call   8006d0 <cprintf>
	*dev = 0;
  80149a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80149d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014a3:	83 c4 10             	add    $0x10,%esp
  8014a6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014ab:	c9                   	leave  
  8014ac:	c3                   	ret    

008014ad <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8014ad:	55                   	push   %ebp
  8014ae:	89 e5                	mov    %esp,%ebp
  8014b0:	56                   	push   %esi
  8014b1:	53                   	push   %ebx
  8014b2:	83 ec 10             	sub    $0x10,%esp
  8014b5:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014be:	50                   	push   %eax
  8014bf:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8014c5:	c1 e8 0c             	shr    $0xc,%eax
  8014c8:	50                   	push   %eax
  8014c9:	e8 36 ff ff ff       	call   801404 <fd_lookup>
  8014ce:	83 c4 08             	add    $0x8,%esp
  8014d1:	85 c0                	test   %eax,%eax
  8014d3:	78 05                	js     8014da <fd_close+0x2d>
	    || fd != fd2)
  8014d5:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8014d8:	74 0c                	je     8014e6 <fd_close+0x39>
		return (must_exist ? r : 0);
  8014da:	84 db                	test   %bl,%bl
  8014dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e1:	0f 44 c2             	cmove  %edx,%eax
  8014e4:	eb 41                	jmp    801527 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014e6:	83 ec 08             	sub    $0x8,%esp
  8014e9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014ec:	50                   	push   %eax
  8014ed:	ff 36                	pushl  (%esi)
  8014ef:	e8 66 ff ff ff       	call   80145a <dev_lookup>
  8014f4:	89 c3                	mov    %eax,%ebx
  8014f6:	83 c4 10             	add    $0x10,%esp
  8014f9:	85 c0                	test   %eax,%eax
  8014fb:	78 1a                	js     801517 <fd_close+0x6a>
		if (dev->dev_close)
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  801503:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  801508:	85 c0                	test   %eax,%eax
  80150a:	74 0b                	je     801517 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  80150c:	83 ec 0c             	sub    $0xc,%esp
  80150f:	56                   	push   %esi
  801510:	ff d0                	call   *%eax
  801512:	89 c3                	mov    %eax,%ebx
  801514:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  801517:	83 ec 08             	sub    $0x8,%esp
  80151a:	56                   	push   %esi
  80151b:	6a 00                	push   $0x0
  80151d:	e8 3a fc ff ff       	call   80115c <sys_page_unmap>
	return r;
  801522:	83 c4 10             	add    $0x10,%esp
  801525:	89 d8                	mov    %ebx,%eax
}
  801527:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152a:	5b                   	pop    %ebx
  80152b:	5e                   	pop    %esi
  80152c:	5d                   	pop    %ebp
  80152d:	c3                   	ret    

0080152e <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  80152e:	55                   	push   %ebp
  80152f:	89 e5                	mov    %esp,%ebp
  801531:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801534:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801537:	50                   	push   %eax
  801538:	ff 75 08             	pushl  0x8(%ebp)
  80153b:	e8 c4 fe ff ff       	call   801404 <fd_lookup>
  801540:	83 c4 08             	add    $0x8,%esp
  801543:	85 c0                	test   %eax,%eax
  801545:	78 10                	js     801557 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  801547:	83 ec 08             	sub    $0x8,%esp
  80154a:	6a 01                	push   $0x1
  80154c:	ff 75 f4             	pushl  -0xc(%ebp)
  80154f:	e8 59 ff ff ff       	call   8014ad <fd_close>
  801554:	83 c4 10             	add    $0x10,%esp
}
  801557:	c9                   	leave  
  801558:	c3                   	ret    

00801559 <close_all>:

void
close_all(void)
{
  801559:	55                   	push   %ebp
  80155a:	89 e5                	mov    %esp,%ebp
  80155c:	53                   	push   %ebx
  80155d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801560:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	53                   	push   %ebx
  801569:	e8 c0 ff ff ff       	call   80152e <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80156e:	83 c3 01             	add    $0x1,%ebx
  801571:	83 c4 10             	add    $0x10,%esp
  801574:	83 fb 20             	cmp    $0x20,%ebx
  801577:	75 ec                	jne    801565 <close_all+0xc>
		close(i);
}
  801579:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157c:	c9                   	leave  
  80157d:	c3                   	ret    

0080157e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80157e:	55                   	push   %ebp
  80157f:	89 e5                	mov    %esp,%ebp
  801581:	57                   	push   %edi
  801582:	56                   	push   %esi
  801583:	53                   	push   %ebx
  801584:	83 ec 2c             	sub    $0x2c,%esp
  801587:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80158a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80158d:	50                   	push   %eax
  80158e:	ff 75 08             	pushl  0x8(%ebp)
  801591:	e8 6e fe ff ff       	call   801404 <fd_lookup>
  801596:	83 c4 08             	add    $0x8,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	0f 88 c1 00 00 00    	js     801662 <dup+0xe4>
		return r;
	close(newfdnum);
  8015a1:	83 ec 0c             	sub    $0xc,%esp
  8015a4:	56                   	push   %esi
  8015a5:	e8 84 ff ff ff       	call   80152e <close>

	newfd = INDEX2FD(newfdnum);
  8015aa:	89 f3                	mov    %esi,%ebx
  8015ac:	c1 e3 0c             	shl    $0xc,%ebx
  8015af:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8015b5:	83 c4 04             	add    $0x4,%esp
  8015b8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015bb:	e8 de fd ff ff       	call   80139e <fd2data>
  8015c0:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8015c2:	89 1c 24             	mov    %ebx,(%esp)
  8015c5:	e8 d4 fd ff ff       	call   80139e <fd2data>
  8015ca:	83 c4 10             	add    $0x10,%esp
  8015cd:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015d0:	89 f8                	mov    %edi,%eax
  8015d2:	c1 e8 16             	shr    $0x16,%eax
  8015d5:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015dc:	a8 01                	test   $0x1,%al
  8015de:	74 37                	je     801617 <dup+0x99>
  8015e0:	89 f8                	mov    %edi,%eax
  8015e2:	c1 e8 0c             	shr    $0xc,%eax
  8015e5:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015ec:	f6 c2 01             	test   $0x1,%dl
  8015ef:	74 26                	je     801617 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8015f1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f8:	83 ec 0c             	sub    $0xc,%esp
  8015fb:	25 07 0e 00 00       	and    $0xe07,%eax
  801600:	50                   	push   %eax
  801601:	ff 75 d4             	pushl  -0x2c(%ebp)
  801604:	6a 00                	push   $0x0
  801606:	57                   	push   %edi
  801607:	6a 00                	push   $0x0
  801609:	e8 0c fb ff ff       	call   80111a <sys_page_map>
  80160e:	89 c7                	mov    %eax,%edi
  801610:	83 c4 20             	add    $0x20,%esp
  801613:	85 c0                	test   %eax,%eax
  801615:	78 2e                	js     801645 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801617:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80161a:	89 d0                	mov    %edx,%eax
  80161c:	c1 e8 0c             	shr    $0xc,%eax
  80161f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801626:	83 ec 0c             	sub    $0xc,%esp
  801629:	25 07 0e 00 00       	and    $0xe07,%eax
  80162e:	50                   	push   %eax
  80162f:	53                   	push   %ebx
  801630:	6a 00                	push   $0x0
  801632:	52                   	push   %edx
  801633:	6a 00                	push   $0x0
  801635:	e8 e0 fa ff ff       	call   80111a <sys_page_map>
  80163a:	89 c7                	mov    %eax,%edi
  80163c:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80163f:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801641:	85 ff                	test   %edi,%edi
  801643:	79 1d                	jns    801662 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  801645:	83 ec 08             	sub    $0x8,%esp
  801648:	53                   	push   %ebx
  801649:	6a 00                	push   $0x0
  80164b:	e8 0c fb ff ff       	call   80115c <sys_page_unmap>
	sys_page_unmap(0, nva);
  801650:	83 c4 08             	add    $0x8,%esp
  801653:	ff 75 d4             	pushl  -0x2c(%ebp)
  801656:	6a 00                	push   $0x0
  801658:	e8 ff fa ff ff       	call   80115c <sys_page_unmap>
	return r;
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	89 f8                	mov    %edi,%eax
}
  801662:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801665:	5b                   	pop    %ebx
  801666:	5e                   	pop    %esi
  801667:	5f                   	pop    %edi
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	53                   	push   %ebx
  80166e:	83 ec 14             	sub    $0x14,%esp
  801671:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801674:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801677:	50                   	push   %eax
  801678:	53                   	push   %ebx
  801679:	e8 86 fd ff ff       	call   801404 <fd_lookup>
  80167e:	83 c4 08             	add    $0x8,%esp
  801681:	89 c2                	mov    %eax,%edx
  801683:	85 c0                	test   %eax,%eax
  801685:	78 6d                	js     8016f4 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801687:	83 ec 08             	sub    $0x8,%esp
  80168a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80168d:	50                   	push   %eax
  80168e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801691:	ff 30                	pushl  (%eax)
  801693:	e8 c2 fd ff ff       	call   80145a <dev_lookup>
  801698:	83 c4 10             	add    $0x10,%esp
  80169b:	85 c0                	test   %eax,%eax
  80169d:	78 4c                	js     8016eb <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80169f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016a2:	8b 42 08             	mov    0x8(%edx),%eax
  8016a5:	83 e0 03             	and    $0x3,%eax
  8016a8:	83 f8 01             	cmp    $0x1,%eax
  8016ab:	75 21                	jne    8016ce <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ad:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  8016b2:	8b 40 48             	mov    0x48(%eax),%eax
  8016b5:	83 ec 04             	sub    $0x4,%esp
  8016b8:	53                   	push   %ebx
  8016b9:	50                   	push   %eax
  8016ba:	68 74 2d 80 00       	push   $0x802d74
  8016bf:	e8 0c f0 ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  8016c4:	83 c4 10             	add    $0x10,%esp
  8016c7:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8016cc:	eb 26                	jmp    8016f4 <read+0x8a>
	}
	if (!dev->dev_read)
  8016ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016d1:	8b 40 08             	mov    0x8(%eax),%eax
  8016d4:	85 c0                	test   %eax,%eax
  8016d6:	74 17                	je     8016ef <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	ff 75 10             	pushl  0x10(%ebp)
  8016de:	ff 75 0c             	pushl  0xc(%ebp)
  8016e1:	52                   	push   %edx
  8016e2:	ff d0                	call   *%eax
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	83 c4 10             	add    $0x10,%esp
  8016e9:	eb 09                	jmp    8016f4 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016eb:	89 c2                	mov    %eax,%edx
  8016ed:	eb 05                	jmp    8016f4 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8016ef:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8016f4:	89 d0                	mov    %edx,%eax
  8016f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f9:	c9                   	leave  
  8016fa:	c3                   	ret    

008016fb <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016fb:	55                   	push   %ebp
  8016fc:	89 e5                	mov    %esp,%ebp
  8016fe:	57                   	push   %edi
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	83 ec 0c             	sub    $0xc,%esp
  801704:	8b 7d 08             	mov    0x8(%ebp),%edi
  801707:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80170a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80170f:	eb 21                	jmp    801732 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801711:	83 ec 04             	sub    $0x4,%esp
  801714:	89 f0                	mov    %esi,%eax
  801716:	29 d8                	sub    %ebx,%eax
  801718:	50                   	push   %eax
  801719:	89 d8                	mov    %ebx,%eax
  80171b:	03 45 0c             	add    0xc(%ebp),%eax
  80171e:	50                   	push   %eax
  80171f:	57                   	push   %edi
  801720:	e8 45 ff ff ff       	call   80166a <read>
		if (m < 0)
  801725:	83 c4 10             	add    $0x10,%esp
  801728:	85 c0                	test   %eax,%eax
  80172a:	78 10                	js     80173c <readn+0x41>
			return m;
		if (m == 0)
  80172c:	85 c0                	test   %eax,%eax
  80172e:	74 0a                	je     80173a <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801730:	01 c3                	add    %eax,%ebx
  801732:	39 f3                	cmp    %esi,%ebx
  801734:	72 db                	jb     801711 <readn+0x16>
  801736:	89 d8                	mov    %ebx,%eax
  801738:	eb 02                	jmp    80173c <readn+0x41>
  80173a:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  80173c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80173f:	5b                   	pop    %ebx
  801740:	5e                   	pop    %esi
  801741:	5f                   	pop    %edi
  801742:	5d                   	pop    %ebp
  801743:	c3                   	ret    

00801744 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	53                   	push   %ebx
  801748:	83 ec 14             	sub    $0x14,%esp
  80174b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801751:	50                   	push   %eax
  801752:	53                   	push   %ebx
  801753:	e8 ac fc ff ff       	call   801404 <fd_lookup>
  801758:	83 c4 08             	add    $0x8,%esp
  80175b:	89 c2                	mov    %eax,%edx
  80175d:	85 c0                	test   %eax,%eax
  80175f:	78 68                	js     8017c9 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801761:	83 ec 08             	sub    $0x8,%esp
  801764:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801767:	50                   	push   %eax
  801768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176b:	ff 30                	pushl  (%eax)
  80176d:	e8 e8 fc ff ff       	call   80145a <dev_lookup>
  801772:	83 c4 10             	add    $0x10,%esp
  801775:	85 c0                	test   %eax,%eax
  801777:	78 47                	js     8017c0 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801779:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801780:	75 21                	jne    8017a3 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801782:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  801787:	8b 40 48             	mov    0x48(%eax),%eax
  80178a:	83 ec 04             	sub    $0x4,%esp
  80178d:	53                   	push   %ebx
  80178e:	50                   	push   %eax
  80178f:	68 90 2d 80 00       	push   $0x802d90
  801794:	e8 37 ef ff ff       	call   8006d0 <cprintf>
		return -E_INVAL;
  801799:	83 c4 10             	add    $0x10,%esp
  80179c:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8017a1:	eb 26                	jmp    8017c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017a3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017a6:	8b 52 0c             	mov    0xc(%edx),%edx
  8017a9:	85 d2                	test   %edx,%edx
  8017ab:	74 17                	je     8017c4 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017ad:	83 ec 04             	sub    $0x4,%esp
  8017b0:	ff 75 10             	pushl  0x10(%ebp)
  8017b3:	ff 75 0c             	pushl  0xc(%ebp)
  8017b6:	50                   	push   %eax
  8017b7:	ff d2                	call   *%edx
  8017b9:	89 c2                	mov    %eax,%edx
  8017bb:	83 c4 10             	add    $0x10,%esp
  8017be:	eb 09                	jmp    8017c9 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c0:	89 c2                	mov    %eax,%edx
  8017c2:	eb 05                	jmp    8017c9 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8017c4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8017c9:	89 d0                	mov    %edx,%eax
  8017cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ce:	c9                   	leave  
  8017cf:	c3                   	ret    

008017d0 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017d0:	55                   	push   %ebp
  8017d1:	89 e5                	mov    %esp,%ebp
  8017d3:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017d6:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8017d9:	50                   	push   %eax
  8017da:	ff 75 08             	pushl  0x8(%ebp)
  8017dd:	e8 22 fc ff ff       	call   801404 <fd_lookup>
  8017e2:	83 c4 08             	add    $0x8,%esp
  8017e5:	85 c0                	test   %eax,%eax
  8017e7:	78 0e                	js     8017f7 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8017e9:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8017ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017ef:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f7:	c9                   	leave  
  8017f8:	c3                   	ret    

008017f9 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017f9:	55                   	push   %ebp
  8017fa:	89 e5                	mov    %esp,%ebp
  8017fc:	53                   	push   %ebx
  8017fd:	83 ec 14             	sub    $0x14,%esp
  801800:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801803:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801806:	50                   	push   %eax
  801807:	53                   	push   %ebx
  801808:	e8 f7 fb ff ff       	call   801404 <fd_lookup>
  80180d:	83 c4 08             	add    $0x8,%esp
  801810:	89 c2                	mov    %eax,%edx
  801812:	85 c0                	test   %eax,%eax
  801814:	78 65                	js     80187b <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801816:	83 ec 08             	sub    $0x8,%esp
  801819:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80181c:	50                   	push   %eax
  80181d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801820:	ff 30                	pushl  (%eax)
  801822:	e8 33 fc ff ff       	call   80145a <dev_lookup>
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	78 44                	js     801872 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80182e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801831:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801835:	75 21                	jne    801858 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  801837:	a1 b4 40 80 00       	mov    0x8040b4,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80183c:	8b 40 48             	mov    0x48(%eax),%eax
  80183f:	83 ec 04             	sub    $0x4,%esp
  801842:	53                   	push   %ebx
  801843:	50                   	push   %eax
  801844:	68 50 2d 80 00       	push   $0x802d50
  801849:	e8 82 ee ff ff       	call   8006d0 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80184e:	83 c4 10             	add    $0x10,%esp
  801851:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  801856:	eb 23                	jmp    80187b <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  801858:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80185b:	8b 52 18             	mov    0x18(%edx),%edx
  80185e:	85 d2                	test   %edx,%edx
  801860:	74 14                	je     801876 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801862:	83 ec 08             	sub    $0x8,%esp
  801865:	ff 75 0c             	pushl  0xc(%ebp)
  801868:	50                   	push   %eax
  801869:	ff d2                	call   *%edx
  80186b:	89 c2                	mov    %eax,%edx
  80186d:	83 c4 10             	add    $0x10,%esp
  801870:	eb 09                	jmp    80187b <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801872:	89 c2                	mov    %eax,%edx
  801874:	eb 05                	jmp    80187b <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  801876:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80187b:	89 d0                	mov    %edx,%eax
  80187d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801880:	c9                   	leave  
  801881:	c3                   	ret    

00801882 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801882:	55                   	push   %ebp
  801883:	89 e5                	mov    %esp,%ebp
  801885:	53                   	push   %ebx
  801886:	83 ec 14             	sub    $0x14,%esp
  801889:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188f:	50                   	push   %eax
  801890:	ff 75 08             	pushl  0x8(%ebp)
  801893:	e8 6c fb ff ff       	call   801404 <fd_lookup>
  801898:	83 c4 08             	add    $0x8,%esp
  80189b:	89 c2                	mov    %eax,%edx
  80189d:	85 c0                	test   %eax,%eax
  80189f:	78 58                	js     8018f9 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018a1:	83 ec 08             	sub    $0x8,%esp
  8018a4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a7:	50                   	push   %eax
  8018a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ab:	ff 30                	pushl  (%eax)
  8018ad:	e8 a8 fb ff ff       	call   80145a <dev_lookup>
  8018b2:	83 c4 10             	add    $0x10,%esp
  8018b5:	85 c0                	test   %eax,%eax
  8018b7:	78 37                	js     8018f0 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8018b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018bc:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018c0:	74 32                	je     8018f4 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018c2:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018c5:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018cc:	00 00 00 
	stat->st_isdir = 0;
  8018cf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018d6:	00 00 00 
	stat->st_dev = dev;
  8018d9:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018df:	83 ec 08             	sub    $0x8,%esp
  8018e2:	53                   	push   %ebx
  8018e3:	ff 75 f0             	pushl  -0x10(%ebp)
  8018e6:	ff 50 14             	call   *0x14(%eax)
  8018e9:	89 c2                	mov    %eax,%edx
  8018eb:	83 c4 10             	add    $0x10,%esp
  8018ee:	eb 09                	jmp    8018f9 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f0:	89 c2                	mov    %eax,%edx
  8018f2:	eb 05                	jmp    8018f9 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8018f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8018f9:	89 d0                	mov    %edx,%eax
  8018fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018fe:	c9                   	leave  
  8018ff:	c3                   	ret    

00801900 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801900:	55                   	push   %ebp
  801901:	89 e5                	mov    %esp,%ebp
  801903:	56                   	push   %esi
  801904:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801905:	83 ec 08             	sub    $0x8,%esp
  801908:	6a 00                	push   $0x0
  80190a:	ff 75 08             	pushl  0x8(%ebp)
  80190d:	e8 e3 01 00 00       	call   801af5 <open>
  801912:	89 c3                	mov    %eax,%ebx
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	85 c0                	test   %eax,%eax
  801919:	78 1b                	js     801936 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  80191b:	83 ec 08             	sub    $0x8,%esp
  80191e:	ff 75 0c             	pushl  0xc(%ebp)
  801921:	50                   	push   %eax
  801922:	e8 5b ff ff ff       	call   801882 <fstat>
  801927:	89 c6                	mov    %eax,%esi
	close(fd);
  801929:	89 1c 24             	mov    %ebx,(%esp)
  80192c:	e8 fd fb ff ff       	call   80152e <close>
	return r;
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	89 f0                	mov    %esi,%eax
}
  801936:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801939:	5b                   	pop    %ebx
  80193a:	5e                   	pop    %esi
  80193b:	5d                   	pop    %ebp
  80193c:	c3                   	ret    

0080193d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80193d:	55                   	push   %ebp
  80193e:	89 e5                	mov    %esp,%ebp
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	89 c6                	mov    %eax,%esi
  801944:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801946:	83 3d ac 40 80 00 00 	cmpl   $0x0,0x8040ac
  80194d:	75 12                	jne    801961 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80194f:	83 ec 0c             	sub    $0xc,%esp
  801952:	6a 01                	push   $0x1
  801954:	e8 43 0c 00 00       	call   80259c <ipc_find_env>
  801959:	a3 ac 40 80 00       	mov    %eax,0x8040ac
  80195e:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801961:	6a 07                	push   $0x7
  801963:	68 00 50 80 00       	push   $0x805000
  801968:	56                   	push   %esi
  801969:	ff 35 ac 40 80 00    	pushl  0x8040ac
  80196f:	e8 d4 0b 00 00       	call   802548 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801974:	83 c4 0c             	add    $0xc,%esp
  801977:	6a 00                	push   $0x0
  801979:	53                   	push   %ebx
  80197a:	6a 00                	push   $0x0
  80197c:	e8 5e 0b 00 00       	call   8024df <ipc_recv>
}
  801981:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801984:	5b                   	pop    %ebx
  801985:	5e                   	pop    %esi
  801986:	5d                   	pop    %ebp
  801987:	c3                   	ret    

00801988 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801988:	55                   	push   %ebp
  801989:	89 e5                	mov    %esp,%ebp
  80198b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80198e:	8b 45 08             	mov    0x8(%ebp),%eax
  801991:	8b 40 0c             	mov    0xc(%eax),%eax
  801994:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801999:	8b 45 0c             	mov    0xc(%ebp),%eax
  80199c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8019a6:	b8 02 00 00 00       	mov    $0x2,%eax
  8019ab:	e8 8d ff ff ff       	call   80193d <fsipc>
}
  8019b0:	c9                   	leave  
  8019b1:	c3                   	ret    

008019b2 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8019b2:	55                   	push   %ebp
  8019b3:	89 e5                	mov    %esp,%ebp
  8019b5:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bb:	8b 40 0c             	mov    0xc(%eax),%eax
  8019be:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019c3:	ba 00 00 00 00       	mov    $0x0,%edx
  8019c8:	b8 06 00 00 00       	mov    $0x6,%eax
  8019cd:	e8 6b ff ff ff       	call   80193d <fsipc>
}
  8019d2:	c9                   	leave  
  8019d3:	c3                   	ret    

008019d4 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8019d4:	55                   	push   %ebp
  8019d5:	89 e5                	mov    %esp,%ebp
  8019d7:	53                   	push   %ebx
  8019d8:	83 ec 04             	sub    $0x4,%esp
  8019db:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019de:	8b 45 08             	mov    0x8(%ebp),%eax
  8019e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8019e4:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8019ee:	b8 05 00 00 00       	mov    $0x5,%eax
  8019f3:	e8 45 ff ff ff       	call   80193d <fsipc>
  8019f8:	85 c0                	test   %eax,%eax
  8019fa:	78 2c                	js     801a28 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019fc:	83 ec 08             	sub    $0x8,%esp
  8019ff:	68 00 50 80 00       	push   $0x805000
  801a04:	53                   	push   %ebx
  801a05:	e8 ca f2 ff ff       	call   800cd4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a0a:	a1 80 50 80 00       	mov    0x805080,%eax
  801a0f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a15:	a1 84 50 80 00       	mov    0x805084,%eax
  801a1a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a20:	83 c4 10             	add    $0x10,%esp
  801a23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a2b:	c9                   	leave  
  801a2c:	c3                   	ret    

00801a2d <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	83 ec 0c             	sub    $0xc,%esp
  801a33:	8b 45 10             	mov    0x10(%ebp),%eax
  801a36:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a3b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a40:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a43:	8b 55 08             	mov    0x8(%ebp),%edx
  801a46:	8b 52 0c             	mov    0xc(%edx),%edx
  801a49:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a4f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  801a54:	50                   	push   %eax
  801a55:	ff 75 0c             	pushl  0xc(%ebp)
  801a58:	68 08 50 80 00       	push   $0x805008
  801a5d:	e8 04 f4 ff ff       	call   800e66 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	b8 04 00 00 00       	mov    $0x4,%eax
  801a6c:	e8 cc fe ff ff       	call   80193d <fsipc>
	//panic("devfile_write not implemented");
}
  801a71:	c9                   	leave  
  801a72:	c3                   	ret    

00801a73 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  801a73:	55                   	push   %ebp
  801a74:	89 e5                	mov    %esp,%ebp
  801a76:	56                   	push   %esi
  801a77:	53                   	push   %ebx
  801a78:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a7b:	8b 45 08             	mov    0x8(%ebp),%eax
  801a7e:	8b 40 0c             	mov    0xc(%eax),%eax
  801a81:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a86:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a91:	b8 03 00 00 00       	mov    $0x3,%eax
  801a96:	e8 a2 fe ff ff       	call   80193d <fsipc>
  801a9b:	89 c3                	mov    %eax,%ebx
  801a9d:	85 c0                	test   %eax,%eax
  801a9f:	78 4b                	js     801aec <devfile_read+0x79>
		return r;
	assert(r <= n);
  801aa1:	39 c6                	cmp    %eax,%esi
  801aa3:	73 16                	jae    801abb <devfile_read+0x48>
  801aa5:	68 c4 2d 80 00       	push   $0x802dc4
  801aaa:	68 cb 2d 80 00       	push   $0x802dcb
  801aaf:	6a 7c                	push   $0x7c
  801ab1:	68 e0 2d 80 00       	push   $0x802de0
  801ab6:	e8 3c eb ff ff       	call   8005f7 <_panic>
	assert(r <= PGSIZE);
  801abb:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ac0:	7e 16                	jle    801ad8 <devfile_read+0x65>
  801ac2:	68 eb 2d 80 00       	push   $0x802deb
  801ac7:	68 cb 2d 80 00       	push   $0x802dcb
  801acc:	6a 7d                	push   $0x7d
  801ace:	68 e0 2d 80 00       	push   $0x802de0
  801ad3:	e8 1f eb ff ff       	call   8005f7 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801ad8:	83 ec 04             	sub    $0x4,%esp
  801adb:	50                   	push   %eax
  801adc:	68 00 50 80 00       	push   $0x805000
  801ae1:	ff 75 0c             	pushl  0xc(%ebp)
  801ae4:	e8 7d f3 ff ff       	call   800e66 <memmove>
	return r;
  801ae9:	83 c4 10             	add    $0x10,%esp
}
  801aec:	89 d8                	mov    %ebx,%eax
  801aee:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801af1:	5b                   	pop    %ebx
  801af2:	5e                   	pop    %esi
  801af3:	5d                   	pop    %ebp
  801af4:	c3                   	ret    

00801af5 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  801af5:	55                   	push   %ebp
  801af6:	89 e5                	mov    %esp,%ebp
  801af8:	53                   	push   %ebx
  801af9:	83 ec 20             	sub    $0x20,%esp
  801afc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  801aff:	53                   	push   %ebx
  801b00:	e8 96 f1 ff ff       	call   800c9b <strlen>
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b0d:	7f 67                	jg     801b76 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	e8 9a f8 ff ff       	call   8013b5 <fd_alloc>
  801b1b:	83 c4 10             	add    $0x10,%esp
		return r;
  801b1e:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 57                	js     801b7b <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	53                   	push   %ebx
  801b28:	68 00 50 80 00       	push   $0x805000
  801b2d:	e8 a2 f1 ff ff       	call   800cd4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b35:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b42:	e8 f6 fd ff ff       	call   80193d <fsipc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	79 14                	jns    801b64 <open+0x6f>
		fd_close(fd, 0);
  801b50:	83 ec 08             	sub    $0x8,%esp
  801b53:	6a 00                	push   $0x0
  801b55:	ff 75 f4             	pushl  -0xc(%ebp)
  801b58:	e8 50 f9 ff ff       	call   8014ad <fd_close>
		return r;
  801b5d:	83 c4 10             	add    $0x10,%esp
  801b60:	89 da                	mov    %ebx,%edx
  801b62:	eb 17                	jmp    801b7b <open+0x86>
	}

	return fd2num(fd);
  801b64:	83 ec 0c             	sub    $0xc,%esp
  801b67:	ff 75 f4             	pushl  -0xc(%ebp)
  801b6a:	e8 1f f8 ff ff       	call   80138e <fd2num>
  801b6f:	89 c2                	mov    %eax,%edx
  801b71:	83 c4 10             	add    $0x10,%esp
  801b74:	eb 05                	jmp    801b7b <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  801b76:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  801b7b:	89 d0                	mov    %edx,%eax
  801b7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b80:	c9                   	leave  
  801b81:	c3                   	ret    

00801b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b82:	55                   	push   %ebp
  801b83:	89 e5                	mov    %esp,%ebp
  801b85:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b88:	ba 00 00 00 00       	mov    $0x0,%edx
  801b8d:	b8 08 00 00 00       	mov    $0x8,%eax
  801b92:	e8 a6 fd ff ff       	call   80193d <fsipc>
}
  801b97:	c9                   	leave  
  801b98:	c3                   	ret    

00801b99 <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  801b99:	55                   	push   %ebp
  801b9a:	89 e5                	mov    %esp,%ebp
  801b9c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  801b9f:	68 f7 2d 80 00       	push   $0x802df7
  801ba4:	ff 75 0c             	pushl  0xc(%ebp)
  801ba7:	e8 28 f1 ff ff       	call   800cd4 <strcpy>
	return 0;
}
  801bac:	b8 00 00 00 00       	mov    $0x0,%eax
  801bb1:	c9                   	leave  
  801bb2:	c3                   	ret    

00801bb3 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  801bb3:	55                   	push   %ebp
  801bb4:	89 e5                	mov    %esp,%ebp
  801bb6:	53                   	push   %ebx
  801bb7:	83 ec 10             	sub    $0x10,%esp
  801bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  801bbd:	53                   	push   %ebx
  801bbe:	e8 12 0a 00 00       	call   8025d5 <pageref>
  801bc3:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  801bc6:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  801bcb:	83 f8 01             	cmp    $0x1,%eax
  801bce:	75 10                	jne    801be0 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  801bd0:	83 ec 0c             	sub    $0xc,%esp
  801bd3:	ff 73 0c             	pushl  0xc(%ebx)
  801bd6:	e8 c0 02 00 00       	call   801e9b <nsipc_close>
  801bdb:	89 c2                	mov    %eax,%edx
  801bdd:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  801be0:	89 d0                	mov    %edx,%eax
  801be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801be5:	c9                   	leave  
  801be6:	c3                   	ret    

00801be7 <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  801be7:	55                   	push   %ebp
  801be8:	89 e5                	mov    %esp,%ebp
  801bea:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  801bed:	6a 00                	push   $0x0
  801bef:	ff 75 10             	pushl  0x10(%ebp)
  801bf2:	ff 75 0c             	pushl  0xc(%ebp)
  801bf5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bf8:	ff 70 0c             	pushl  0xc(%eax)
  801bfb:	e8 78 03 00 00       	call   801f78 <nsipc_send>
}
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    

00801c02 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  801c02:	55                   	push   %ebp
  801c03:	89 e5                	mov    %esp,%ebp
  801c05:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  801c08:	6a 00                	push   $0x0
  801c0a:	ff 75 10             	pushl  0x10(%ebp)
  801c0d:	ff 75 0c             	pushl  0xc(%ebp)
  801c10:	8b 45 08             	mov    0x8(%ebp),%eax
  801c13:	ff 70 0c             	pushl  0xc(%eax)
  801c16:	e8 f1 02 00 00       	call   801f0c <nsipc_recv>
}
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  801c23:	8d 55 f4             	lea    -0xc(%ebp),%edx
  801c26:	52                   	push   %edx
  801c27:	50                   	push   %eax
  801c28:	e8 d7 f7 ff ff       	call   801404 <fd_lookup>
  801c2d:	83 c4 10             	add    $0x10,%esp
  801c30:	85 c0                	test   %eax,%eax
  801c32:	78 17                	js     801c4b <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  801c34:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c37:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  801c3d:	39 08                	cmp    %ecx,(%eax)
  801c3f:	75 05                	jne    801c46 <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  801c41:	8b 40 0c             	mov    0xc(%eax),%eax
  801c44:	eb 05                	jmp    801c4b <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  801c46:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  801c4b:	c9                   	leave  
  801c4c:	c3                   	ret    

00801c4d <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  801c4d:	55                   	push   %ebp
  801c4e:	89 e5                	mov    %esp,%ebp
  801c50:	56                   	push   %esi
  801c51:	53                   	push   %ebx
  801c52:	83 ec 1c             	sub    $0x1c,%esp
  801c55:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  801c57:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c5a:	50                   	push   %eax
  801c5b:	e8 55 f7 ff ff       	call   8013b5 <fd_alloc>
  801c60:	89 c3                	mov    %eax,%ebx
  801c62:	83 c4 10             	add    $0x10,%esp
  801c65:	85 c0                	test   %eax,%eax
  801c67:	78 1b                	js     801c84 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  801c69:	83 ec 04             	sub    $0x4,%esp
  801c6c:	68 07 04 00 00       	push   $0x407
  801c71:	ff 75 f4             	pushl  -0xc(%ebp)
  801c74:	6a 00                	push   $0x0
  801c76:	e8 5c f4 ff ff       	call   8010d7 <sys_page_alloc>
  801c7b:	89 c3                	mov    %eax,%ebx
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	85 c0                	test   %eax,%eax
  801c82:	79 10                	jns    801c94 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  801c84:	83 ec 0c             	sub    $0xc,%esp
  801c87:	56                   	push   %esi
  801c88:	e8 0e 02 00 00       	call   801e9b <nsipc_close>
		return r;
  801c8d:	83 c4 10             	add    $0x10,%esp
  801c90:	89 d8                	mov    %ebx,%eax
  801c92:	eb 24                	jmp    801cb8 <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  801c94:	8b 15 20 30 80 00    	mov    0x803020,%edx
  801c9a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c9d:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  801c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ca2:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  801ca9:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  801cac:	83 ec 0c             	sub    $0xc,%esp
  801caf:	50                   	push   %eax
  801cb0:	e8 d9 f6 ff ff       	call   80138e <fd2num>
  801cb5:	83 c4 10             	add    $0x10,%esp
}
  801cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cbb:	5b                   	pop    %ebx
  801cbc:	5e                   	pop    %esi
  801cbd:	5d                   	pop    %ebp
  801cbe:	c3                   	ret    

00801cbf <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801cc8:	e8 50 ff ff ff       	call   801c1d <fd2sockid>
		return r;
  801ccd:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  801ccf:	85 c0                	test   %eax,%eax
  801cd1:	78 1f                	js     801cf2 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801cd3:	83 ec 04             	sub    $0x4,%esp
  801cd6:	ff 75 10             	pushl  0x10(%ebp)
  801cd9:	ff 75 0c             	pushl  0xc(%ebp)
  801cdc:	50                   	push   %eax
  801cdd:	e8 12 01 00 00       	call   801df4 <nsipc_accept>
  801ce2:	83 c4 10             	add    $0x10,%esp
		return r;
  801ce5:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  801ce7:	85 c0                	test   %eax,%eax
  801ce9:	78 07                	js     801cf2 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  801ceb:	e8 5d ff ff ff       	call   801c4d <alloc_sockfd>
  801cf0:	89 c1                	mov    %eax,%ecx
}
  801cf2:	89 c8                	mov    %ecx,%eax
  801cf4:	c9                   	leave  
  801cf5:	c3                   	ret    

00801cf6 <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801cf6:	55                   	push   %ebp
  801cf7:	89 e5                	mov    %esp,%ebp
  801cf9:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801cff:	e8 19 ff ff ff       	call   801c1d <fd2sockid>
  801d04:	85 c0                	test   %eax,%eax
  801d06:	78 12                	js     801d1a <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  801d08:	83 ec 04             	sub    $0x4,%esp
  801d0b:	ff 75 10             	pushl  0x10(%ebp)
  801d0e:	ff 75 0c             	pushl  0xc(%ebp)
  801d11:	50                   	push   %eax
  801d12:	e8 2d 01 00 00       	call   801e44 <nsipc_bind>
  801d17:	83 c4 10             	add    $0x10,%esp
}
  801d1a:	c9                   	leave  
  801d1b:	c3                   	ret    

00801d1c <shutdown>:

int
shutdown(int s, int how)
{
  801d1c:	55                   	push   %ebp
  801d1d:	89 e5                	mov    %esp,%ebp
  801d1f:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d22:	8b 45 08             	mov    0x8(%ebp),%eax
  801d25:	e8 f3 fe ff ff       	call   801c1d <fd2sockid>
  801d2a:	85 c0                	test   %eax,%eax
  801d2c:	78 0f                	js     801d3d <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  801d2e:	83 ec 08             	sub    $0x8,%esp
  801d31:	ff 75 0c             	pushl  0xc(%ebp)
  801d34:	50                   	push   %eax
  801d35:	e8 3f 01 00 00       	call   801e79 <nsipc_shutdown>
  801d3a:	83 c4 10             	add    $0x10,%esp
}
  801d3d:	c9                   	leave  
  801d3e:	c3                   	ret    

00801d3f <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d45:	8b 45 08             	mov    0x8(%ebp),%eax
  801d48:	e8 d0 fe ff ff       	call   801c1d <fd2sockid>
  801d4d:	85 c0                	test   %eax,%eax
  801d4f:	78 12                	js     801d63 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  801d51:	83 ec 04             	sub    $0x4,%esp
  801d54:	ff 75 10             	pushl  0x10(%ebp)
  801d57:	ff 75 0c             	pushl  0xc(%ebp)
  801d5a:	50                   	push   %eax
  801d5b:	e8 55 01 00 00       	call   801eb5 <nsipc_connect>
  801d60:	83 c4 10             	add    $0x10,%esp
}
  801d63:	c9                   	leave  
  801d64:	c3                   	ret    

00801d65 <listen>:

int
listen(int s, int backlog)
{
  801d65:	55                   	push   %ebp
  801d66:	89 e5                	mov    %esp,%ebp
  801d68:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  801d6b:	8b 45 08             	mov    0x8(%ebp),%eax
  801d6e:	e8 aa fe ff ff       	call   801c1d <fd2sockid>
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 0f                	js     801d86 <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  801d77:	83 ec 08             	sub    $0x8,%esp
  801d7a:	ff 75 0c             	pushl  0xc(%ebp)
  801d7d:	50                   	push   %eax
  801d7e:	e8 67 01 00 00       	call   801eea <nsipc_listen>
  801d83:	83 c4 10             	add    $0x10,%esp
}
  801d86:	c9                   	leave  
  801d87:	c3                   	ret    

00801d88 <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  801d88:	55                   	push   %ebp
  801d89:	89 e5                	mov    %esp,%ebp
  801d8b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  801d8e:	ff 75 10             	pushl  0x10(%ebp)
  801d91:	ff 75 0c             	pushl  0xc(%ebp)
  801d94:	ff 75 08             	pushl  0x8(%ebp)
  801d97:	e8 3a 02 00 00       	call   801fd6 <nsipc_socket>
  801d9c:	83 c4 10             	add    $0x10,%esp
  801d9f:	85 c0                	test   %eax,%eax
  801da1:	78 05                	js     801da8 <socket+0x20>
		return r;
	return alloc_sockfd(r);
  801da3:	e8 a5 fe ff ff       	call   801c4d <alloc_sockfd>
}
  801da8:	c9                   	leave  
  801da9:	c3                   	ret    

00801daa <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  801daa:	55                   	push   %ebp
  801dab:	89 e5                	mov    %esp,%ebp
  801dad:	53                   	push   %ebx
  801dae:	83 ec 04             	sub    $0x4,%esp
  801db1:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  801db3:	83 3d b0 40 80 00 00 	cmpl   $0x0,0x8040b0
  801dba:	75 12                	jne    801dce <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  801dbc:	83 ec 0c             	sub    $0xc,%esp
  801dbf:	6a 02                	push   $0x2
  801dc1:	e8 d6 07 00 00       	call   80259c <ipc_find_env>
  801dc6:	a3 b0 40 80 00       	mov    %eax,0x8040b0
  801dcb:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  801dce:	6a 07                	push   $0x7
  801dd0:	68 00 60 80 00       	push   $0x806000
  801dd5:	53                   	push   %ebx
  801dd6:	ff 35 b0 40 80 00    	pushl  0x8040b0
  801ddc:	e8 67 07 00 00       	call   802548 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  801de1:	83 c4 0c             	add    $0xc,%esp
  801de4:	6a 00                	push   $0x0
  801de6:	6a 00                	push   $0x0
  801de8:	6a 00                	push   $0x0
  801dea:	e8 f0 06 00 00       	call   8024df <ipc_recv>
}
  801def:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801df2:	c9                   	leave  
  801df3:	c3                   	ret    

00801df4 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  801df4:	55                   	push   %ebp
  801df5:	89 e5                	mov    %esp,%ebp
  801df7:	56                   	push   %esi
  801df8:	53                   	push   %ebx
  801df9:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  801dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  801dff:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  801e04:	8b 06                	mov    (%esi),%eax
  801e06:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  801e0b:	b8 01 00 00 00       	mov    $0x1,%eax
  801e10:	e8 95 ff ff ff       	call   801daa <nsipc>
  801e15:	89 c3                	mov    %eax,%ebx
  801e17:	85 c0                	test   %eax,%eax
  801e19:	78 20                	js     801e3b <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	ff 35 10 60 80 00    	pushl  0x806010
  801e24:	68 00 60 80 00       	push   $0x806000
  801e29:	ff 75 0c             	pushl  0xc(%ebp)
  801e2c:	e8 35 f0 ff ff       	call   800e66 <memmove>
		*addrlen = ret->ret_addrlen;
  801e31:	a1 10 60 80 00       	mov    0x806010,%eax
  801e36:	89 06                	mov    %eax,(%esi)
  801e38:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e40:	5b                   	pop    %ebx
  801e41:	5e                   	pop    %esi
  801e42:	5d                   	pop    %ebp
  801e43:	c3                   	ret    

00801e44 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  801e44:	55                   	push   %ebp
  801e45:	89 e5                	mov    %esp,%ebp
  801e47:	53                   	push   %ebx
  801e48:	83 ec 08             	sub    $0x8,%esp
  801e4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  801e4e:	8b 45 08             	mov    0x8(%ebp),%eax
  801e51:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  801e56:	53                   	push   %ebx
  801e57:	ff 75 0c             	pushl  0xc(%ebp)
  801e5a:	68 04 60 80 00       	push   $0x806004
  801e5f:	e8 02 f0 ff ff       	call   800e66 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  801e64:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  801e6a:	b8 02 00 00 00       	mov    $0x2,%eax
  801e6f:	e8 36 ff ff ff       	call   801daa <nsipc>
}
  801e74:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801e77:	c9                   	leave  
  801e78:	c3                   	ret    

00801e79 <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  801e79:	55                   	push   %ebp
  801e7a:	89 e5                	mov    %esp,%ebp
  801e7c:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  801e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  801e82:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  801e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e8a:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  801e8f:	b8 03 00 00 00       	mov    $0x3,%eax
  801e94:	e8 11 ff ff ff       	call   801daa <nsipc>
}
  801e99:	c9                   	leave  
  801e9a:	c3                   	ret    

00801e9b <nsipc_close>:

int
nsipc_close(int s)
{
  801e9b:	55                   	push   %ebp
  801e9c:	89 e5                	mov    %esp,%ebp
  801e9e:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  801ea1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ea4:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  801ea9:	b8 04 00 00 00       	mov    $0x4,%eax
  801eae:	e8 f7 fe ff ff       	call   801daa <nsipc>
}
  801eb3:	c9                   	leave  
  801eb4:	c3                   	ret    

00801eb5 <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  801eb5:	55                   	push   %ebp
  801eb6:	89 e5                	mov    %esp,%ebp
  801eb8:	53                   	push   %ebx
  801eb9:	83 ec 08             	sub    $0x8,%esp
  801ebc:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  801ebf:	8b 45 08             	mov    0x8(%ebp),%eax
  801ec2:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  801ec7:	53                   	push   %ebx
  801ec8:	ff 75 0c             	pushl  0xc(%ebp)
  801ecb:	68 04 60 80 00       	push   $0x806004
  801ed0:	e8 91 ef ff ff       	call   800e66 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  801ed5:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  801edb:	b8 05 00 00 00       	mov    $0x5,%eax
  801ee0:	e8 c5 fe ff ff       	call   801daa <nsipc>
}
  801ee5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ee8:	c9                   	leave  
  801ee9:	c3                   	ret    

00801eea <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  801eea:	55                   	push   %ebp
  801eeb:	89 e5                	mov    %esp,%ebp
  801eed:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  801ef0:	8b 45 08             	mov    0x8(%ebp),%eax
  801ef3:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  801ef8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801efb:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  801f00:	b8 06 00 00 00       	mov    $0x6,%eax
  801f05:	e8 a0 fe ff ff       	call   801daa <nsipc>
}
  801f0a:	c9                   	leave  
  801f0b:	c3                   	ret    

00801f0c <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  801f0c:	55                   	push   %ebp
  801f0d:	89 e5                	mov    %esp,%ebp
  801f0f:	56                   	push   %esi
  801f10:	53                   	push   %ebx
  801f11:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  801f14:	8b 45 08             	mov    0x8(%ebp),%eax
  801f17:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  801f1c:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  801f22:	8b 45 14             	mov    0x14(%ebp),%eax
  801f25:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  801f2a:	b8 07 00 00 00       	mov    $0x7,%eax
  801f2f:	e8 76 fe ff ff       	call   801daa <nsipc>
  801f34:	89 c3                	mov    %eax,%ebx
  801f36:	85 c0                	test   %eax,%eax
  801f38:	78 35                	js     801f6f <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  801f3a:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  801f3f:	7f 04                	jg     801f45 <nsipc_recv+0x39>
  801f41:	39 c6                	cmp    %eax,%esi
  801f43:	7d 16                	jge    801f5b <nsipc_recv+0x4f>
  801f45:	68 03 2e 80 00       	push   $0x802e03
  801f4a:	68 cb 2d 80 00       	push   $0x802dcb
  801f4f:	6a 62                	push   $0x62
  801f51:	68 18 2e 80 00       	push   $0x802e18
  801f56:	e8 9c e6 ff ff       	call   8005f7 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	50                   	push   %eax
  801f5f:	68 00 60 80 00       	push   $0x806000
  801f64:	ff 75 0c             	pushl  0xc(%ebp)
  801f67:	e8 fa ee ff ff       	call   800e66 <memmove>
  801f6c:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  801f6f:	89 d8                	mov    %ebx,%eax
  801f71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f74:	5b                   	pop    %ebx
  801f75:	5e                   	pop    %esi
  801f76:	5d                   	pop    %ebp
  801f77:	c3                   	ret    

00801f78 <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  801f78:	55                   	push   %ebp
  801f79:	89 e5                	mov    %esp,%ebp
  801f7b:	53                   	push   %ebx
  801f7c:	83 ec 04             	sub    $0x4,%esp
  801f7f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  801f82:	8b 45 08             	mov    0x8(%ebp),%eax
  801f85:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  801f8a:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  801f90:	7e 16                	jle    801fa8 <nsipc_send+0x30>
  801f92:	68 24 2e 80 00       	push   $0x802e24
  801f97:	68 cb 2d 80 00       	push   $0x802dcb
  801f9c:	6a 6d                	push   $0x6d
  801f9e:	68 18 2e 80 00       	push   $0x802e18
  801fa3:	e8 4f e6 ff ff       	call   8005f7 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	53                   	push   %ebx
  801fac:	ff 75 0c             	pushl  0xc(%ebp)
  801faf:	68 0c 60 80 00       	push   $0x80600c
  801fb4:	e8 ad ee ff ff       	call   800e66 <memmove>
	nsipcbuf.send.req_size = size;
  801fb9:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  801fbf:	8b 45 14             	mov    0x14(%ebp),%eax
  801fc2:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  801fc7:	b8 08 00 00 00       	mov    $0x8,%eax
  801fcc:	e8 d9 fd ff ff       	call   801daa <nsipc>
}
  801fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801fd4:	c9                   	leave  
  801fd5:	c3                   	ret    

00801fd6 <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  801fd6:	55                   	push   %ebp
  801fd7:	89 e5                	mov    %esp,%ebp
  801fd9:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  801fdc:	8b 45 08             	mov    0x8(%ebp),%eax
  801fdf:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  801fe4:	8b 45 0c             	mov    0xc(%ebp),%eax
  801fe7:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  801fec:	8b 45 10             	mov    0x10(%ebp),%eax
  801fef:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  801ff4:	b8 09 00 00 00       	mov    $0x9,%eax
  801ff9:	e8 ac fd ff ff       	call   801daa <nsipc>
}
  801ffe:	c9                   	leave  
  801fff:	c3                   	ret    

00802000 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802000:	55                   	push   %ebp
  802001:	89 e5                	mov    %esp,%ebp
  802003:	56                   	push   %esi
  802004:	53                   	push   %ebx
  802005:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802008:	83 ec 0c             	sub    $0xc,%esp
  80200b:	ff 75 08             	pushl  0x8(%ebp)
  80200e:	e8 8b f3 ff ff       	call   80139e <fd2data>
  802013:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802015:	83 c4 08             	add    $0x8,%esp
  802018:	68 30 2e 80 00       	push   $0x802e30
  80201d:	53                   	push   %ebx
  80201e:	e8 b1 ec ff ff       	call   800cd4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802023:	8b 46 04             	mov    0x4(%esi),%eax
  802026:	2b 06                	sub    (%esi),%eax
  802028:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80202e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802035:	00 00 00 
	stat->st_dev = &devpipe;
  802038:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  80203f:	30 80 00 
	return 0;
}
  802042:	b8 00 00 00 00       	mov    $0x0,%eax
  802047:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80204a:	5b                   	pop    %ebx
  80204b:	5e                   	pop    %esi
  80204c:	5d                   	pop    %ebp
  80204d:	c3                   	ret    

0080204e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80204e:	55                   	push   %ebp
  80204f:	89 e5                	mov    %esp,%ebp
  802051:	53                   	push   %ebx
  802052:	83 ec 0c             	sub    $0xc,%esp
  802055:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802058:	53                   	push   %ebx
  802059:	6a 00                	push   $0x0
  80205b:	e8 fc f0 ff ff       	call   80115c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802060:	89 1c 24             	mov    %ebx,(%esp)
  802063:	e8 36 f3 ff ff       	call   80139e <fd2data>
  802068:	83 c4 08             	add    $0x8,%esp
  80206b:	50                   	push   %eax
  80206c:	6a 00                	push   $0x0
  80206e:	e8 e9 f0 ff ff       	call   80115c <sys_page_unmap>
}
  802073:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802076:	c9                   	leave  
  802077:	c3                   	ret    

00802078 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	57                   	push   %edi
  80207c:	56                   	push   %esi
  80207d:	53                   	push   %ebx
  80207e:	83 ec 1c             	sub    $0x1c,%esp
  802081:	89 45 e0             	mov    %eax,-0x20(%ebp)
  802084:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  802086:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80208b:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  80208e:	83 ec 0c             	sub    $0xc,%esp
  802091:	ff 75 e0             	pushl  -0x20(%ebp)
  802094:	e8 3c 05 00 00       	call   8025d5 <pageref>
  802099:	89 c3                	mov    %eax,%ebx
  80209b:	89 3c 24             	mov    %edi,(%esp)
  80209e:	e8 32 05 00 00       	call   8025d5 <pageref>
  8020a3:	83 c4 10             	add    $0x10,%esp
  8020a6:	39 c3                	cmp    %eax,%ebx
  8020a8:	0f 94 c1             	sete   %cl
  8020ab:	0f b6 c9             	movzbl %cl,%ecx
  8020ae:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8020b1:	8b 15 b4 40 80 00    	mov    0x8040b4,%edx
  8020b7:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8020ba:	39 ce                	cmp    %ecx,%esi
  8020bc:	74 1b                	je     8020d9 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8020be:	39 c3                	cmp    %eax,%ebx
  8020c0:	75 c4                	jne    802086 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8020c2:	8b 42 58             	mov    0x58(%edx),%eax
  8020c5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8020c8:	50                   	push   %eax
  8020c9:	56                   	push   %esi
  8020ca:	68 37 2e 80 00       	push   $0x802e37
  8020cf:	e8 fc e5 ff ff       	call   8006d0 <cprintf>
  8020d4:	83 c4 10             	add    $0x10,%esp
  8020d7:	eb ad                	jmp    802086 <_pipeisclosed+0xe>
	}
}
  8020d9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8020dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020df:	5b                   	pop    %ebx
  8020e0:	5e                   	pop    %esi
  8020e1:	5f                   	pop    %edi
  8020e2:	5d                   	pop    %ebp
  8020e3:	c3                   	ret    

008020e4 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8020e4:	55                   	push   %ebp
  8020e5:	89 e5                	mov    %esp,%ebp
  8020e7:	57                   	push   %edi
  8020e8:	56                   	push   %esi
  8020e9:	53                   	push   %ebx
  8020ea:	83 ec 28             	sub    $0x28,%esp
  8020ed:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8020f0:	56                   	push   %esi
  8020f1:	e8 a8 f2 ff ff       	call   80139e <fd2data>
  8020f6:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8020f8:	83 c4 10             	add    $0x10,%esp
  8020fb:	bf 00 00 00 00       	mov    $0x0,%edi
  802100:	eb 4b                	jmp    80214d <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  802102:	89 da                	mov    %ebx,%edx
  802104:	89 f0                	mov    %esi,%eax
  802106:	e8 6d ff ff ff       	call   802078 <_pipeisclosed>
  80210b:	85 c0                	test   %eax,%eax
  80210d:	75 48                	jne    802157 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  80210f:	e8 a4 ef ff ff       	call   8010b8 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802114:	8b 43 04             	mov    0x4(%ebx),%eax
  802117:	8b 0b                	mov    (%ebx),%ecx
  802119:	8d 51 20             	lea    0x20(%ecx),%edx
  80211c:	39 d0                	cmp    %edx,%eax
  80211e:	73 e2                	jae    802102 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802120:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802123:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802127:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80212a:	89 c2                	mov    %eax,%edx
  80212c:	c1 fa 1f             	sar    $0x1f,%edx
  80212f:	89 d1                	mov    %edx,%ecx
  802131:	c1 e9 1b             	shr    $0x1b,%ecx
  802134:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802137:	83 e2 1f             	and    $0x1f,%edx
  80213a:	29 ca                	sub    %ecx,%edx
  80213c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802140:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802144:	83 c0 01             	add    $0x1,%eax
  802147:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80214a:	83 c7 01             	add    $0x1,%edi
  80214d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802150:	75 c2                	jne    802114 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  802152:	8b 45 10             	mov    0x10(%ebp),%eax
  802155:	eb 05                	jmp    80215c <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  802157:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  80215c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80215f:	5b                   	pop    %ebx
  802160:	5e                   	pop    %esi
  802161:	5f                   	pop    %edi
  802162:	5d                   	pop    %ebp
  802163:	c3                   	ret    

00802164 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  802164:	55                   	push   %ebp
  802165:	89 e5                	mov    %esp,%ebp
  802167:	57                   	push   %edi
  802168:	56                   	push   %esi
  802169:	53                   	push   %ebx
  80216a:	83 ec 18             	sub    $0x18,%esp
  80216d:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  802170:	57                   	push   %edi
  802171:	e8 28 f2 ff ff       	call   80139e <fd2data>
  802176:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  802178:	83 c4 10             	add    $0x10,%esp
  80217b:	bb 00 00 00 00       	mov    $0x0,%ebx
  802180:	eb 3d                	jmp    8021bf <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  802182:	85 db                	test   %ebx,%ebx
  802184:	74 04                	je     80218a <devpipe_read+0x26>
				return i;
  802186:	89 d8                	mov    %ebx,%eax
  802188:	eb 44                	jmp    8021ce <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80218a:	89 f2                	mov    %esi,%edx
  80218c:	89 f8                	mov    %edi,%eax
  80218e:	e8 e5 fe ff ff       	call   802078 <_pipeisclosed>
  802193:	85 c0                	test   %eax,%eax
  802195:	75 32                	jne    8021c9 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  802197:	e8 1c ef ff ff       	call   8010b8 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  80219c:	8b 06                	mov    (%esi),%eax
  80219e:	3b 46 04             	cmp    0x4(%esi),%eax
  8021a1:	74 df                	je     802182 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8021a3:	99                   	cltd   
  8021a4:	c1 ea 1b             	shr    $0x1b,%edx
  8021a7:	01 d0                	add    %edx,%eax
  8021a9:	83 e0 1f             	and    $0x1f,%eax
  8021ac:	29 d0                	sub    %edx,%eax
  8021ae:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8021b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8021b6:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8021b9:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8021bc:	83 c3 01             	add    $0x1,%ebx
  8021bf:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8021c2:	75 d8                	jne    80219c <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8021c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8021c7:	eb 05                	jmp    8021ce <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8021c9:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8021ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d1:	5b                   	pop    %ebx
  8021d2:	5e                   	pop    %esi
  8021d3:	5f                   	pop    %edi
  8021d4:	5d                   	pop    %ebp
  8021d5:	c3                   	ret    

008021d6 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8021de:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021e1:	50                   	push   %eax
  8021e2:	e8 ce f1 ff ff       	call   8013b5 <fd_alloc>
  8021e7:	83 c4 10             	add    $0x10,%esp
  8021ea:	89 c2                	mov    %eax,%edx
  8021ec:	85 c0                	test   %eax,%eax
  8021ee:	0f 88 2c 01 00 00    	js     802320 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8021f4:	83 ec 04             	sub    $0x4,%esp
  8021f7:	68 07 04 00 00       	push   $0x407
  8021fc:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ff:	6a 00                	push   $0x0
  802201:	e8 d1 ee ff ff       	call   8010d7 <sys_page_alloc>
  802206:	83 c4 10             	add    $0x10,%esp
  802209:	89 c2                	mov    %eax,%edx
  80220b:	85 c0                	test   %eax,%eax
  80220d:	0f 88 0d 01 00 00    	js     802320 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  802213:	83 ec 0c             	sub    $0xc,%esp
  802216:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802219:	50                   	push   %eax
  80221a:	e8 96 f1 ff ff       	call   8013b5 <fd_alloc>
  80221f:	89 c3                	mov    %eax,%ebx
  802221:	83 c4 10             	add    $0x10,%esp
  802224:	85 c0                	test   %eax,%eax
  802226:	0f 88 e2 00 00 00    	js     80230e <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80222c:	83 ec 04             	sub    $0x4,%esp
  80222f:	68 07 04 00 00       	push   $0x407
  802234:	ff 75 f0             	pushl  -0x10(%ebp)
  802237:	6a 00                	push   $0x0
  802239:	e8 99 ee ff ff       	call   8010d7 <sys_page_alloc>
  80223e:	89 c3                	mov    %eax,%ebx
  802240:	83 c4 10             	add    $0x10,%esp
  802243:	85 c0                	test   %eax,%eax
  802245:	0f 88 c3 00 00 00    	js     80230e <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  80224b:	83 ec 0c             	sub    $0xc,%esp
  80224e:	ff 75 f4             	pushl  -0xc(%ebp)
  802251:	e8 48 f1 ff ff       	call   80139e <fd2data>
  802256:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802258:	83 c4 0c             	add    $0xc,%esp
  80225b:	68 07 04 00 00       	push   $0x407
  802260:	50                   	push   %eax
  802261:	6a 00                	push   $0x0
  802263:	e8 6f ee ff ff       	call   8010d7 <sys_page_alloc>
  802268:	89 c3                	mov    %eax,%ebx
  80226a:	83 c4 10             	add    $0x10,%esp
  80226d:	85 c0                	test   %eax,%eax
  80226f:	0f 88 89 00 00 00    	js     8022fe <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802275:	83 ec 0c             	sub    $0xc,%esp
  802278:	ff 75 f0             	pushl  -0x10(%ebp)
  80227b:	e8 1e f1 ff ff       	call   80139e <fd2data>
  802280:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802287:	50                   	push   %eax
  802288:	6a 00                	push   $0x0
  80228a:	56                   	push   %esi
  80228b:	6a 00                	push   $0x0
  80228d:	e8 88 ee ff ff       	call   80111a <sys_page_map>
  802292:	89 c3                	mov    %eax,%ebx
  802294:	83 c4 20             	add    $0x20,%esp
  802297:	85 c0                	test   %eax,%eax
  802299:	78 55                	js     8022f0 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  80229b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a4:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8022a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022a9:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8022b0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8022b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022b9:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8022bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022be:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8022c5:	83 ec 0c             	sub    $0xc,%esp
  8022c8:	ff 75 f4             	pushl  -0xc(%ebp)
  8022cb:	e8 be f0 ff ff       	call   80138e <fd2num>
  8022d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022d3:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8022d5:	83 c4 04             	add    $0x4,%esp
  8022d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8022db:	e8 ae f0 ff ff       	call   80138e <fd2num>
  8022e0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8022e3:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8022e6:	83 c4 10             	add    $0x10,%esp
  8022e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8022ee:	eb 30                	jmp    802320 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8022f0:	83 ec 08             	sub    $0x8,%esp
  8022f3:	56                   	push   %esi
  8022f4:	6a 00                	push   $0x0
  8022f6:	e8 61 ee ff ff       	call   80115c <sys_page_unmap>
  8022fb:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  8022fe:	83 ec 08             	sub    $0x8,%esp
  802301:	ff 75 f0             	pushl  -0x10(%ebp)
  802304:	6a 00                	push   $0x0
  802306:	e8 51 ee ff ff       	call   80115c <sys_page_unmap>
  80230b:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  80230e:	83 ec 08             	sub    $0x8,%esp
  802311:	ff 75 f4             	pushl  -0xc(%ebp)
  802314:	6a 00                	push   $0x0
  802316:	e8 41 ee ff ff       	call   80115c <sys_page_unmap>
  80231b:	83 c4 10             	add    $0x10,%esp
  80231e:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  802320:	89 d0                	mov    %edx,%eax
  802322:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802325:	5b                   	pop    %ebx
  802326:	5e                   	pop    %esi
  802327:	5d                   	pop    %ebp
  802328:	c3                   	ret    

00802329 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  802329:	55                   	push   %ebp
  80232a:	89 e5                	mov    %esp,%ebp
  80232c:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80232f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802332:	50                   	push   %eax
  802333:	ff 75 08             	pushl  0x8(%ebp)
  802336:	e8 c9 f0 ff ff       	call   801404 <fd_lookup>
  80233b:	83 c4 10             	add    $0x10,%esp
  80233e:	85 c0                	test   %eax,%eax
  802340:	78 18                	js     80235a <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  802342:	83 ec 0c             	sub    $0xc,%esp
  802345:	ff 75 f4             	pushl  -0xc(%ebp)
  802348:	e8 51 f0 ff ff       	call   80139e <fd2data>
	return _pipeisclosed(fd, p);
  80234d:	89 c2                	mov    %eax,%edx
  80234f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802352:	e8 21 fd ff ff       	call   802078 <_pipeisclosed>
  802357:	83 c4 10             	add    $0x10,%esp
}
  80235a:	c9                   	leave  
  80235b:	c3                   	ret    

0080235c <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80235c:	55                   	push   %ebp
  80235d:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  80235f:	b8 00 00 00 00       	mov    $0x0,%eax
  802364:	5d                   	pop    %ebp
  802365:	c3                   	ret    

00802366 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  802366:	55                   	push   %ebp
  802367:	89 e5                	mov    %esp,%ebp
  802369:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80236c:	68 4f 2e 80 00       	push   $0x802e4f
  802371:	ff 75 0c             	pushl  0xc(%ebp)
  802374:	e8 5b e9 ff ff       	call   800cd4 <strcpy>
	return 0;
}
  802379:	b8 00 00 00 00       	mov    $0x0,%eax
  80237e:	c9                   	leave  
  80237f:	c3                   	ret    

00802380 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  802380:	55                   	push   %ebp
  802381:	89 e5                	mov    %esp,%ebp
  802383:	57                   	push   %edi
  802384:	56                   	push   %esi
  802385:	53                   	push   %ebx
  802386:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80238c:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  802391:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  802397:	eb 2d                	jmp    8023c6 <devcons_write+0x46>
		m = n - tot;
  802399:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80239c:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  80239e:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8023a1:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8023a6:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8023a9:	83 ec 04             	sub    $0x4,%esp
  8023ac:	53                   	push   %ebx
  8023ad:	03 45 0c             	add    0xc(%ebp),%eax
  8023b0:	50                   	push   %eax
  8023b1:	57                   	push   %edi
  8023b2:	e8 af ea ff ff       	call   800e66 <memmove>
		sys_cputs(buf, m);
  8023b7:	83 c4 08             	add    $0x8,%esp
  8023ba:	53                   	push   %ebx
  8023bb:	57                   	push   %edi
  8023bc:	e8 5a ec ff ff       	call   80101b <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8023c1:	01 de                	add    %ebx,%esi
  8023c3:	83 c4 10             	add    $0x10,%esp
  8023c6:	89 f0                	mov    %esi,%eax
  8023c8:	3b 75 10             	cmp    0x10(%ebp),%esi
  8023cb:	72 cc                	jb     802399 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8023cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8023d0:	5b                   	pop    %ebx
  8023d1:	5e                   	pop    %esi
  8023d2:	5f                   	pop    %edi
  8023d3:	5d                   	pop    %ebp
  8023d4:	c3                   	ret    

008023d5 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8023d5:	55                   	push   %ebp
  8023d6:	89 e5                	mov    %esp,%ebp
  8023d8:	83 ec 08             	sub    $0x8,%esp
  8023db:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8023e0:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8023e4:	74 2a                	je     802410 <devcons_read+0x3b>
  8023e6:	eb 05                	jmp    8023ed <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8023e8:	e8 cb ec ff ff       	call   8010b8 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8023ed:	e8 47 ec ff ff       	call   801039 <sys_cgetc>
  8023f2:	85 c0                	test   %eax,%eax
  8023f4:	74 f2                	je     8023e8 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8023f6:	85 c0                	test   %eax,%eax
  8023f8:	78 16                	js     802410 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8023fa:	83 f8 04             	cmp    $0x4,%eax
  8023fd:	74 0c                	je     80240b <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  8023ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  802402:	88 02                	mov    %al,(%edx)
	return 1;
  802404:	b8 01 00 00 00       	mov    $0x1,%eax
  802409:	eb 05                	jmp    802410 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  80240b:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  802410:	c9                   	leave  
  802411:	c3                   	ret    

00802412 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  802412:	55                   	push   %ebp
  802413:	89 e5                	mov    %esp,%ebp
  802415:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802418:	8b 45 08             	mov    0x8(%ebp),%eax
  80241b:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  80241e:	6a 01                	push   $0x1
  802420:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802423:	50                   	push   %eax
  802424:	e8 f2 eb ff ff       	call   80101b <sys_cputs>
}
  802429:	83 c4 10             	add    $0x10,%esp
  80242c:	c9                   	leave  
  80242d:	c3                   	ret    

0080242e <getchar>:

int
getchar(void)
{
  80242e:	55                   	push   %ebp
  80242f:	89 e5                	mov    %esp,%ebp
  802431:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  802434:	6a 01                	push   $0x1
  802436:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802439:	50                   	push   %eax
  80243a:	6a 00                	push   $0x0
  80243c:	e8 29 f2 ff ff       	call   80166a <read>
	if (r < 0)
  802441:	83 c4 10             	add    $0x10,%esp
  802444:	85 c0                	test   %eax,%eax
  802446:	78 0f                	js     802457 <getchar+0x29>
		return r;
	if (r < 1)
  802448:	85 c0                	test   %eax,%eax
  80244a:	7e 06                	jle    802452 <getchar+0x24>
		return -E_EOF;
	return c;
  80244c:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  802450:	eb 05                	jmp    802457 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  802452:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  802457:	c9                   	leave  
  802458:	c3                   	ret    

00802459 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  802459:	55                   	push   %ebp
  80245a:	89 e5                	mov    %esp,%ebp
  80245c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80245f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802462:	50                   	push   %eax
  802463:	ff 75 08             	pushl  0x8(%ebp)
  802466:	e8 99 ef ff ff       	call   801404 <fd_lookup>
  80246b:	83 c4 10             	add    $0x10,%esp
  80246e:	85 c0                	test   %eax,%eax
  802470:	78 11                	js     802483 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  802472:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802475:	8b 15 58 30 80 00    	mov    0x803058,%edx
  80247b:	39 10                	cmp    %edx,(%eax)
  80247d:	0f 94 c0             	sete   %al
  802480:	0f b6 c0             	movzbl %al,%eax
}
  802483:	c9                   	leave  
  802484:	c3                   	ret    

00802485 <opencons>:

int
opencons(void)
{
  802485:	55                   	push   %ebp
  802486:	89 e5                	mov    %esp,%ebp
  802488:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80248b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80248e:	50                   	push   %eax
  80248f:	e8 21 ef ff ff       	call   8013b5 <fd_alloc>
  802494:	83 c4 10             	add    $0x10,%esp
		return r;
  802497:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  802499:	85 c0                	test   %eax,%eax
  80249b:	78 3e                	js     8024db <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80249d:	83 ec 04             	sub    $0x4,%esp
  8024a0:	68 07 04 00 00       	push   $0x407
  8024a5:	ff 75 f4             	pushl  -0xc(%ebp)
  8024a8:	6a 00                	push   $0x0
  8024aa:	e8 28 ec ff ff       	call   8010d7 <sys_page_alloc>
  8024af:	83 c4 10             	add    $0x10,%esp
		return r;
  8024b2:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8024b4:	85 c0                	test   %eax,%eax
  8024b6:	78 23                	js     8024db <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8024b8:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8024be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8024c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8024c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8024cd:	83 ec 0c             	sub    $0xc,%esp
  8024d0:	50                   	push   %eax
  8024d1:	e8 b8 ee ff ff       	call   80138e <fd2num>
  8024d6:	89 c2                	mov    %eax,%edx
  8024d8:	83 c4 10             	add    $0x10,%esp
}
  8024db:	89 d0                	mov    %edx,%eax
  8024dd:	c9                   	leave  
  8024de:	c3                   	ret    

008024df <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8024df:	55                   	push   %ebp
  8024e0:	89 e5                	mov    %esp,%ebp
  8024e2:	56                   	push   %esi
  8024e3:	53                   	push   %ebx
  8024e4:	8b 75 08             	mov    0x8(%ebp),%esi
  8024e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8024ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  8024ed:	85 c0                	test   %eax,%eax
  8024ef:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8024f4:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  8024f7:	83 ec 0c             	sub    $0xc,%esp
  8024fa:	50                   	push   %eax
  8024fb:	e8 87 ed ff ff       	call   801287 <sys_ipc_recv>
  802500:	83 c4 10             	add    $0x10,%esp
  802503:	85 c0                	test   %eax,%eax
  802505:	79 16                	jns    80251d <ipc_recv+0x3e>
        if (from_env_store != NULL)
  802507:	85 f6                	test   %esi,%esi
  802509:	74 06                	je     802511 <ipc_recv+0x32>
            *from_env_store = 0;
  80250b:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  802511:	85 db                	test   %ebx,%ebx
  802513:	74 2c                	je     802541 <ipc_recv+0x62>
            *perm_store = 0;
  802515:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80251b:	eb 24                	jmp    802541 <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  80251d:	85 f6                	test   %esi,%esi
  80251f:	74 0a                	je     80252b <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  802521:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802526:	8b 40 74             	mov    0x74(%eax),%eax
  802529:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  80252b:	85 db                	test   %ebx,%ebx
  80252d:	74 0a                	je     802539 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  80252f:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  802534:	8b 40 78             	mov    0x78(%eax),%eax
  802537:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  802539:	a1 b4 40 80 00       	mov    0x8040b4,%eax
  80253e:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  802541:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802544:	5b                   	pop    %ebx
  802545:	5e                   	pop    %esi
  802546:	5d                   	pop    %ebp
  802547:	c3                   	ret    

00802548 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802548:	55                   	push   %ebp
  802549:	89 e5                	mov    %esp,%ebp
  80254b:	57                   	push   %edi
  80254c:	56                   	push   %esi
  80254d:	53                   	push   %ebx
  80254e:	83 ec 0c             	sub    $0xc,%esp
  802551:	8b 7d 08             	mov    0x8(%ebp),%edi
  802554:	8b 75 0c             	mov    0xc(%ebp),%esi
  802557:	8b 45 10             	mov    0x10(%ebp),%eax
  80255a:	85 c0                	test   %eax,%eax
  80255c:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  802561:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802564:	eb 1c                	jmp    802582 <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  802566:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802569:	74 12                	je     80257d <ipc_send+0x35>
  80256b:	50                   	push   %eax
  80256c:	68 5b 2e 80 00       	push   $0x802e5b
  802571:	6a 3b                	push   $0x3b
  802573:	68 71 2e 80 00       	push   $0x802e71
  802578:	e8 7a e0 ff ff       	call   8005f7 <_panic>
		sys_yield();
  80257d:	e8 36 eb ff ff       	call   8010b8 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  802582:	ff 75 14             	pushl  0x14(%ebp)
  802585:	53                   	push   %ebx
  802586:	56                   	push   %esi
  802587:	57                   	push   %edi
  802588:	e8 d7 ec ff ff       	call   801264 <sys_ipc_try_send>
  80258d:	83 c4 10             	add    $0x10,%esp
  802590:	85 c0                	test   %eax,%eax
  802592:	78 d2                	js     802566 <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  802594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802597:	5b                   	pop    %ebx
  802598:	5e                   	pop    %esi
  802599:	5f                   	pop    %edi
  80259a:	5d                   	pop    %ebp
  80259b:	c3                   	ret    

0080259c <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80259c:	55                   	push   %ebp
  80259d:	89 e5                	mov    %esp,%ebp
  80259f:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8025a2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8025a7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8025aa:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8025b0:	8b 52 50             	mov    0x50(%edx),%edx
  8025b3:	39 ca                	cmp    %ecx,%edx
  8025b5:	75 0d                	jne    8025c4 <ipc_find_env+0x28>
			return envs[i].env_id;
  8025b7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8025ba:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8025bf:	8b 40 48             	mov    0x48(%eax),%eax
  8025c2:	eb 0f                	jmp    8025d3 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8025c4:	83 c0 01             	add    $0x1,%eax
  8025c7:	3d 00 04 00 00       	cmp    $0x400,%eax
  8025cc:	75 d9                	jne    8025a7 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  8025ce:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8025d3:	5d                   	pop    %ebp
  8025d4:	c3                   	ret    

008025d5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8025d5:	55                   	push   %ebp
  8025d6:	89 e5                	mov    %esp,%ebp
  8025d8:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025db:	89 d0                	mov    %edx,%eax
  8025dd:	c1 e8 16             	shr    $0x16,%eax
  8025e0:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  8025e7:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8025ec:	f6 c1 01             	test   $0x1,%cl
  8025ef:	74 1d                	je     80260e <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  8025f1:	c1 ea 0c             	shr    $0xc,%edx
  8025f4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  8025fb:	f6 c2 01             	test   $0x1,%dl
  8025fe:	74 0e                	je     80260e <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802600:	c1 ea 0c             	shr    $0xc,%edx
  802603:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  80260a:	ef 
  80260b:	0f b7 c0             	movzwl %ax,%eax
}
  80260e:	5d                   	pop    %ebp
  80260f:	c3                   	ret    

00802610 <__udivdi3>:
  802610:	55                   	push   %ebp
  802611:	57                   	push   %edi
  802612:	56                   	push   %esi
  802613:	53                   	push   %ebx
  802614:	83 ec 1c             	sub    $0x1c,%esp
  802617:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80261b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80261f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802623:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802627:	85 f6                	test   %esi,%esi
  802629:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80262d:	89 ca                	mov    %ecx,%edx
  80262f:	89 f8                	mov    %edi,%eax
  802631:	75 3d                	jne    802670 <__udivdi3+0x60>
  802633:	39 cf                	cmp    %ecx,%edi
  802635:	0f 87 c5 00 00 00    	ja     802700 <__udivdi3+0xf0>
  80263b:	85 ff                	test   %edi,%edi
  80263d:	89 fd                	mov    %edi,%ebp
  80263f:	75 0b                	jne    80264c <__udivdi3+0x3c>
  802641:	b8 01 00 00 00       	mov    $0x1,%eax
  802646:	31 d2                	xor    %edx,%edx
  802648:	f7 f7                	div    %edi
  80264a:	89 c5                	mov    %eax,%ebp
  80264c:	89 c8                	mov    %ecx,%eax
  80264e:	31 d2                	xor    %edx,%edx
  802650:	f7 f5                	div    %ebp
  802652:	89 c1                	mov    %eax,%ecx
  802654:	89 d8                	mov    %ebx,%eax
  802656:	89 cf                	mov    %ecx,%edi
  802658:	f7 f5                	div    %ebp
  80265a:	89 c3                	mov    %eax,%ebx
  80265c:	89 d8                	mov    %ebx,%eax
  80265e:	89 fa                	mov    %edi,%edx
  802660:	83 c4 1c             	add    $0x1c,%esp
  802663:	5b                   	pop    %ebx
  802664:	5e                   	pop    %esi
  802665:	5f                   	pop    %edi
  802666:	5d                   	pop    %ebp
  802667:	c3                   	ret    
  802668:	90                   	nop
  802669:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802670:	39 ce                	cmp    %ecx,%esi
  802672:	77 74                	ja     8026e8 <__udivdi3+0xd8>
  802674:	0f bd fe             	bsr    %esi,%edi
  802677:	83 f7 1f             	xor    $0x1f,%edi
  80267a:	0f 84 98 00 00 00    	je     802718 <__udivdi3+0x108>
  802680:	bb 20 00 00 00       	mov    $0x20,%ebx
  802685:	89 f9                	mov    %edi,%ecx
  802687:	89 c5                	mov    %eax,%ebp
  802689:	29 fb                	sub    %edi,%ebx
  80268b:	d3 e6                	shl    %cl,%esi
  80268d:	89 d9                	mov    %ebx,%ecx
  80268f:	d3 ed                	shr    %cl,%ebp
  802691:	89 f9                	mov    %edi,%ecx
  802693:	d3 e0                	shl    %cl,%eax
  802695:	09 ee                	or     %ebp,%esi
  802697:	89 d9                	mov    %ebx,%ecx
  802699:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80269d:	89 d5                	mov    %edx,%ebp
  80269f:	8b 44 24 08          	mov    0x8(%esp),%eax
  8026a3:	d3 ed                	shr    %cl,%ebp
  8026a5:	89 f9                	mov    %edi,%ecx
  8026a7:	d3 e2                	shl    %cl,%edx
  8026a9:	89 d9                	mov    %ebx,%ecx
  8026ab:	d3 e8                	shr    %cl,%eax
  8026ad:	09 c2                	or     %eax,%edx
  8026af:	89 d0                	mov    %edx,%eax
  8026b1:	89 ea                	mov    %ebp,%edx
  8026b3:	f7 f6                	div    %esi
  8026b5:	89 d5                	mov    %edx,%ebp
  8026b7:	89 c3                	mov    %eax,%ebx
  8026b9:	f7 64 24 0c          	mull   0xc(%esp)
  8026bd:	39 d5                	cmp    %edx,%ebp
  8026bf:	72 10                	jb     8026d1 <__udivdi3+0xc1>
  8026c1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8026c5:	89 f9                	mov    %edi,%ecx
  8026c7:	d3 e6                	shl    %cl,%esi
  8026c9:	39 c6                	cmp    %eax,%esi
  8026cb:	73 07                	jae    8026d4 <__udivdi3+0xc4>
  8026cd:	39 d5                	cmp    %edx,%ebp
  8026cf:	75 03                	jne    8026d4 <__udivdi3+0xc4>
  8026d1:	83 eb 01             	sub    $0x1,%ebx
  8026d4:	31 ff                	xor    %edi,%edi
  8026d6:	89 d8                	mov    %ebx,%eax
  8026d8:	89 fa                	mov    %edi,%edx
  8026da:	83 c4 1c             	add    $0x1c,%esp
  8026dd:	5b                   	pop    %ebx
  8026de:	5e                   	pop    %esi
  8026df:	5f                   	pop    %edi
  8026e0:	5d                   	pop    %ebp
  8026e1:	c3                   	ret    
  8026e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8026e8:	31 ff                	xor    %edi,%edi
  8026ea:	31 db                	xor    %ebx,%ebx
  8026ec:	89 d8                	mov    %ebx,%eax
  8026ee:	89 fa                	mov    %edi,%edx
  8026f0:	83 c4 1c             	add    $0x1c,%esp
  8026f3:	5b                   	pop    %ebx
  8026f4:	5e                   	pop    %esi
  8026f5:	5f                   	pop    %edi
  8026f6:	5d                   	pop    %ebp
  8026f7:	c3                   	ret    
  8026f8:	90                   	nop
  8026f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802700:	89 d8                	mov    %ebx,%eax
  802702:	f7 f7                	div    %edi
  802704:	31 ff                	xor    %edi,%edi
  802706:	89 c3                	mov    %eax,%ebx
  802708:	89 d8                	mov    %ebx,%eax
  80270a:	89 fa                	mov    %edi,%edx
  80270c:	83 c4 1c             	add    $0x1c,%esp
  80270f:	5b                   	pop    %ebx
  802710:	5e                   	pop    %esi
  802711:	5f                   	pop    %edi
  802712:	5d                   	pop    %ebp
  802713:	c3                   	ret    
  802714:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802718:	39 ce                	cmp    %ecx,%esi
  80271a:	72 0c                	jb     802728 <__udivdi3+0x118>
  80271c:	31 db                	xor    %ebx,%ebx
  80271e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802722:	0f 87 34 ff ff ff    	ja     80265c <__udivdi3+0x4c>
  802728:	bb 01 00 00 00       	mov    $0x1,%ebx
  80272d:	e9 2a ff ff ff       	jmp    80265c <__udivdi3+0x4c>
  802732:	66 90                	xchg   %ax,%ax
  802734:	66 90                	xchg   %ax,%ax
  802736:	66 90                	xchg   %ax,%ax
  802738:	66 90                	xchg   %ax,%ax
  80273a:	66 90                	xchg   %ax,%ax
  80273c:	66 90                	xchg   %ax,%ax
  80273e:	66 90                	xchg   %ax,%ax

00802740 <__umoddi3>:
  802740:	55                   	push   %ebp
  802741:	57                   	push   %edi
  802742:	56                   	push   %esi
  802743:	53                   	push   %ebx
  802744:	83 ec 1c             	sub    $0x1c,%esp
  802747:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80274b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80274f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802753:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802757:	85 d2                	test   %edx,%edx
  802759:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80275d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802761:	89 f3                	mov    %esi,%ebx
  802763:	89 3c 24             	mov    %edi,(%esp)
  802766:	89 74 24 04          	mov    %esi,0x4(%esp)
  80276a:	75 1c                	jne    802788 <__umoddi3+0x48>
  80276c:	39 f7                	cmp    %esi,%edi
  80276e:	76 50                	jbe    8027c0 <__umoddi3+0x80>
  802770:	89 c8                	mov    %ecx,%eax
  802772:	89 f2                	mov    %esi,%edx
  802774:	f7 f7                	div    %edi
  802776:	89 d0                	mov    %edx,%eax
  802778:	31 d2                	xor    %edx,%edx
  80277a:	83 c4 1c             	add    $0x1c,%esp
  80277d:	5b                   	pop    %ebx
  80277e:	5e                   	pop    %esi
  80277f:	5f                   	pop    %edi
  802780:	5d                   	pop    %ebp
  802781:	c3                   	ret    
  802782:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802788:	39 f2                	cmp    %esi,%edx
  80278a:	89 d0                	mov    %edx,%eax
  80278c:	77 52                	ja     8027e0 <__umoddi3+0xa0>
  80278e:	0f bd ea             	bsr    %edx,%ebp
  802791:	83 f5 1f             	xor    $0x1f,%ebp
  802794:	75 5a                	jne    8027f0 <__umoddi3+0xb0>
  802796:	3b 54 24 04          	cmp    0x4(%esp),%edx
  80279a:	0f 82 e0 00 00 00    	jb     802880 <__umoddi3+0x140>
  8027a0:	39 0c 24             	cmp    %ecx,(%esp)
  8027a3:	0f 86 d7 00 00 00    	jbe    802880 <__umoddi3+0x140>
  8027a9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8027ad:	8b 54 24 04          	mov    0x4(%esp),%edx
  8027b1:	83 c4 1c             	add    $0x1c,%esp
  8027b4:	5b                   	pop    %ebx
  8027b5:	5e                   	pop    %esi
  8027b6:	5f                   	pop    %edi
  8027b7:	5d                   	pop    %ebp
  8027b8:	c3                   	ret    
  8027b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8027c0:	85 ff                	test   %edi,%edi
  8027c2:	89 fd                	mov    %edi,%ebp
  8027c4:	75 0b                	jne    8027d1 <__umoddi3+0x91>
  8027c6:	b8 01 00 00 00       	mov    $0x1,%eax
  8027cb:	31 d2                	xor    %edx,%edx
  8027cd:	f7 f7                	div    %edi
  8027cf:	89 c5                	mov    %eax,%ebp
  8027d1:	89 f0                	mov    %esi,%eax
  8027d3:	31 d2                	xor    %edx,%edx
  8027d5:	f7 f5                	div    %ebp
  8027d7:	89 c8                	mov    %ecx,%eax
  8027d9:	f7 f5                	div    %ebp
  8027db:	89 d0                	mov    %edx,%eax
  8027dd:	eb 99                	jmp    802778 <__umoddi3+0x38>
  8027df:	90                   	nop
  8027e0:	89 c8                	mov    %ecx,%eax
  8027e2:	89 f2                	mov    %esi,%edx
  8027e4:	83 c4 1c             	add    $0x1c,%esp
  8027e7:	5b                   	pop    %ebx
  8027e8:	5e                   	pop    %esi
  8027e9:	5f                   	pop    %edi
  8027ea:	5d                   	pop    %ebp
  8027eb:	c3                   	ret    
  8027ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8027f0:	8b 34 24             	mov    (%esp),%esi
  8027f3:	bf 20 00 00 00       	mov    $0x20,%edi
  8027f8:	89 e9                	mov    %ebp,%ecx
  8027fa:	29 ef                	sub    %ebp,%edi
  8027fc:	d3 e0                	shl    %cl,%eax
  8027fe:	89 f9                	mov    %edi,%ecx
  802800:	89 f2                	mov    %esi,%edx
  802802:	d3 ea                	shr    %cl,%edx
  802804:	89 e9                	mov    %ebp,%ecx
  802806:	09 c2                	or     %eax,%edx
  802808:	89 d8                	mov    %ebx,%eax
  80280a:	89 14 24             	mov    %edx,(%esp)
  80280d:	89 f2                	mov    %esi,%edx
  80280f:	d3 e2                	shl    %cl,%edx
  802811:	89 f9                	mov    %edi,%ecx
  802813:	89 54 24 04          	mov    %edx,0x4(%esp)
  802817:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80281b:	d3 e8                	shr    %cl,%eax
  80281d:	89 e9                	mov    %ebp,%ecx
  80281f:	89 c6                	mov    %eax,%esi
  802821:	d3 e3                	shl    %cl,%ebx
  802823:	89 f9                	mov    %edi,%ecx
  802825:	89 d0                	mov    %edx,%eax
  802827:	d3 e8                	shr    %cl,%eax
  802829:	89 e9                	mov    %ebp,%ecx
  80282b:	09 d8                	or     %ebx,%eax
  80282d:	89 d3                	mov    %edx,%ebx
  80282f:	89 f2                	mov    %esi,%edx
  802831:	f7 34 24             	divl   (%esp)
  802834:	89 d6                	mov    %edx,%esi
  802836:	d3 e3                	shl    %cl,%ebx
  802838:	f7 64 24 04          	mull   0x4(%esp)
  80283c:	39 d6                	cmp    %edx,%esi
  80283e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802842:	89 d1                	mov    %edx,%ecx
  802844:	89 c3                	mov    %eax,%ebx
  802846:	72 08                	jb     802850 <__umoddi3+0x110>
  802848:	75 11                	jne    80285b <__umoddi3+0x11b>
  80284a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80284e:	73 0b                	jae    80285b <__umoddi3+0x11b>
  802850:	2b 44 24 04          	sub    0x4(%esp),%eax
  802854:	1b 14 24             	sbb    (%esp),%edx
  802857:	89 d1                	mov    %edx,%ecx
  802859:	89 c3                	mov    %eax,%ebx
  80285b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80285f:	29 da                	sub    %ebx,%edx
  802861:	19 ce                	sbb    %ecx,%esi
  802863:	89 f9                	mov    %edi,%ecx
  802865:	89 f0                	mov    %esi,%eax
  802867:	d3 e0                	shl    %cl,%eax
  802869:	89 e9                	mov    %ebp,%ecx
  80286b:	d3 ea                	shr    %cl,%edx
  80286d:	89 e9                	mov    %ebp,%ecx
  80286f:	d3 ee                	shr    %cl,%esi
  802871:	09 d0                	or     %edx,%eax
  802873:	89 f2                	mov    %esi,%edx
  802875:	83 c4 1c             	add    $0x1c,%esp
  802878:	5b                   	pop    %ebx
  802879:	5e                   	pop    %esi
  80287a:	5f                   	pop    %edi
  80287b:	5d                   	pop    %ebp
  80287c:	c3                   	ret    
  80287d:	8d 76 00             	lea    0x0(%esi),%esi
  802880:	29 f9                	sub    %edi,%ecx
  802882:	19 d6                	sbb    %edx,%esi
  802884:	89 74 24 04          	mov    %esi,0x4(%esp)
  802888:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80288c:	e9 18 ff ff ff       	jmp    8027a9 <__umoddi3+0x69>
