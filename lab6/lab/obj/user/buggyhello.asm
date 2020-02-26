
obj/user/buggyhello.debug：     文件格式 elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
    // set thisenv to point at our Env structure in envs[].
    // LAB 3: Your code here.
    thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 08 40 80 00       	mov    %eax,0x804008

    // save the name of the program so that panic() can use it
    if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
        binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

    // call user main routine
    umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

    // exit gracefully
    exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 c6 04 00 00       	call   80055e <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 ea 22 80 00       	push   $0x8022ea
  800111:	6a 23                	push   $0x23
  800113:	68 07 23 80 00       	push   $0x802307
  800118:	e8 c7 13 00 00       	call   8014e4 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 ea 22 80 00       	push   $0x8022ea
  800192:	6a 23                	push   $0x23
  800194:	68 07 23 80 00       	push   $0x802307
  800199:	e8 46 13 00 00       	call   8014e4 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 ea 22 80 00       	push   $0x8022ea
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 07 23 80 00       	push   $0x802307
  8001db:	e8 04 13 00 00       	call   8014e4 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 ea 22 80 00       	push   $0x8022ea
  800216:	6a 23                	push   $0x23
  800218:	68 07 23 80 00       	push   $0x802307
  80021d:	e8 c2 12 00 00       	call   8014e4 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 ea 22 80 00       	push   $0x8022ea
  800258:	6a 23                	push   $0x23
  80025a:	68 07 23 80 00       	push   $0x802307
  80025f:	e8 80 12 00 00       	call   8014e4 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 ea 22 80 00       	push   $0x8022ea
  80029a:	6a 23                	push   $0x23
  80029c:	68 07 23 80 00       	push   $0x802307
  8002a1:	e8 3e 12 00 00       	call   8014e4 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 ea 22 80 00       	push   $0x8022ea
  8002dc:	6a 23                	push   $0x23
  8002de:	68 07 23 80 00       	push   $0x802307
  8002e3:	e8 fc 11 00 00       	call   8014e4 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 ea 22 80 00       	push   $0x8022ea
  800340:	6a 23                	push   $0x23
  800342:	68 07 23 80 00       	push   $0x802307
  800347:	e8 98 11 00 00       	call   8014e4 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <sys_time_msec>:

unsigned int
sys_time_msec(void)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
  800357:	57                   	push   %edi
  800358:	56                   	push   %esi
  800359:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80035a:	ba 00 00 00 00       	mov    $0x0,%edx
  80035f:	b8 0e 00 00 00       	mov    $0xe,%eax
  800364:	89 d1                	mov    %edx,%ecx
  800366:	89 d3                	mov    %edx,%ebx
  800368:	89 d7                	mov    %edx,%edi
  80036a:	89 d6                	mov    %edx,%esi
  80036c:	cd 30                	int    $0x30

unsigned int
sys_time_msec(void)
{
	return (unsigned int) syscall(SYS_time_msec, 0, 0, 0, 0, 0, 0);
}
  80036e:	5b                   	pop    %ebx
  80036f:	5e                   	pop    %esi
  800370:	5f                   	pop    %edi
  800371:	5d                   	pop    %ebp
  800372:	c3                   	ret    

00800373 <sys_packet_try_recv>:

// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
  800373:	55                   	push   %ebp
  800374:	89 e5                	mov    %esp,%ebp
  800376:	57                   	push   %edi
  800377:	56                   	push   %esi
  800378:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800379:	b9 00 00 00 00       	mov    $0x0,%ecx
  80037e:	b8 10 00 00 00       	mov    $0x10,%eax
  800383:	8b 55 08             	mov    0x8(%ebp),%edx
  800386:	89 cb                	mov    %ecx,%ebx
  800388:	89 cf                	mov    %ecx,%edi
  80038a:	89 ce                	mov    %ecx,%esi
  80038c:	cd 30                	int    $0x30
// int sys_packet_try_send(void *data_va, int len){
// 	return  (int) syscall(SYS_packet_try_send, 0 , (uint32_t)data_va, len, 0, 0, 0);
// }
int sys_packet_try_recv(void *data_va){
	return  (int) syscall(SYS_packet_try_recv, 0 , (uint32_t)data_va, 0, 0, 0, 0);
}
  80038e:	5b                   	pop    %ebx
  80038f:	5e                   	pop    %esi
  800390:	5f                   	pop    %edi
  800391:	5d                   	pop    %ebp
  800392:	c3                   	ret    

00800393 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800393:	55                   	push   %ebp
  800394:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800396:	8b 45 08             	mov    0x8(%ebp),%eax
  800399:	05 00 00 00 30       	add    $0x30000000,%eax
  80039e:	c1 e8 0c             	shr    $0xc,%eax
}
  8003a1:	5d                   	pop    %ebp
  8003a2:	c3                   	ret    

008003a3 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8003a3:	55                   	push   %ebp
  8003a4:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	05 00 00 00 30       	add    $0x30000000,%eax
  8003ae:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8003b3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8003b8:	5d                   	pop    %ebp
  8003b9:	c3                   	ret    

008003ba <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8003ba:	55                   	push   %ebp
  8003bb:	89 e5                	mov    %esp,%ebp
  8003bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c0:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003c5:	89 c2                	mov    %eax,%edx
  8003c7:	c1 ea 16             	shr    $0x16,%edx
  8003ca:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003d1:	f6 c2 01             	test   $0x1,%dl
  8003d4:	74 11                	je     8003e7 <fd_alloc+0x2d>
  8003d6:	89 c2                	mov    %eax,%edx
  8003d8:	c1 ea 0c             	shr    $0xc,%edx
  8003db:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003e2:	f6 c2 01             	test   $0x1,%dl
  8003e5:	75 09                	jne    8003f0 <fd_alloc+0x36>
			*fd_store = fd;
  8003e7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003e9:	b8 00 00 00 00       	mov    $0x0,%eax
  8003ee:	eb 17                	jmp    800407 <fd_alloc+0x4d>
  8003f0:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003f5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003fa:	75 c9                	jne    8003c5 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003fc:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  800402:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  800407:	5d                   	pop    %ebp
  800408:	c3                   	ret    

00800409 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800409:	55                   	push   %ebp
  80040a:	89 e5                	mov    %esp,%ebp
  80040c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80040f:	83 f8 1f             	cmp    $0x1f,%eax
  800412:	77 36                	ja     80044a <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800414:	c1 e0 0c             	shl    $0xc,%eax
  800417:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80041c:	89 c2                	mov    %eax,%edx
  80041e:	c1 ea 16             	shr    $0x16,%edx
  800421:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800428:	f6 c2 01             	test   $0x1,%dl
  80042b:	74 24                	je     800451 <fd_lookup+0x48>
  80042d:	89 c2                	mov    %eax,%edx
  80042f:	c1 ea 0c             	shr    $0xc,%edx
  800432:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800439:	f6 c2 01             	test   $0x1,%dl
  80043c:	74 1a                	je     800458 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80043e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800441:	89 02                	mov    %eax,(%edx)
	return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 13                	jmp    80045d <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80044f:	eb 0c                	jmp    80045d <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800451:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800456:	eb 05                	jmp    80045d <fd_lookup+0x54>
  800458:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80045d:	5d                   	pop    %ebp
  80045e:	c3                   	ret    

0080045f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80045f:	55                   	push   %ebp
  800460:	89 e5                	mov    %esp,%ebp
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800468:	ba 94 23 80 00       	mov    $0x802394,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80046d:	eb 13                	jmp    800482 <dev_lookup+0x23>
  80046f:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800472:	39 08                	cmp    %ecx,(%eax)
  800474:	75 0c                	jne    800482 <dev_lookup+0x23>
			*dev = devtab[i];
  800476:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800479:	89 01                	mov    %eax,(%ecx)
			return 0;
  80047b:	b8 00 00 00 00       	mov    $0x0,%eax
  800480:	eb 2e                	jmp    8004b0 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800482:	8b 02                	mov    (%edx),%eax
  800484:	85 c0                	test   %eax,%eax
  800486:	75 e7                	jne    80046f <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800488:	a1 08 40 80 00       	mov    0x804008,%eax
  80048d:	8b 40 48             	mov    0x48(%eax),%eax
  800490:	83 ec 04             	sub    $0x4,%esp
  800493:	51                   	push   %ecx
  800494:	50                   	push   %eax
  800495:	68 18 23 80 00       	push   $0x802318
  80049a:	e8 1e 11 00 00       	call   8015bd <cprintf>
	*dev = 0;
  80049f:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8004b0:	c9                   	leave  
  8004b1:	c3                   	ret    

008004b2 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  8004b2:	55                   	push   %ebp
  8004b3:	89 e5                	mov    %esp,%ebp
  8004b5:	56                   	push   %esi
  8004b6:	53                   	push   %ebx
  8004b7:	83 ec 10             	sub    $0x10,%esp
  8004ba:	8b 75 08             	mov    0x8(%ebp),%esi
  8004bd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8004c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c3:	50                   	push   %eax
  8004c4:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004ca:	c1 e8 0c             	shr    $0xc,%eax
  8004cd:	50                   	push   %eax
  8004ce:	e8 36 ff ff ff       	call   800409 <fd_lookup>
  8004d3:	83 c4 08             	add    $0x8,%esp
  8004d6:	85 c0                	test   %eax,%eax
  8004d8:	78 05                	js     8004df <fd_close+0x2d>
	    || fd != fd2)
  8004da:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004dd:	74 0c                	je     8004eb <fd_close+0x39>
		return (must_exist ? r : 0);
  8004df:	84 db                	test   %bl,%bl
  8004e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8004e6:	0f 44 c2             	cmove  %edx,%eax
  8004e9:	eb 41                	jmp    80052c <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004eb:	83 ec 08             	sub    $0x8,%esp
  8004ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004f1:	50                   	push   %eax
  8004f2:	ff 36                	pushl  (%esi)
  8004f4:	e8 66 ff ff ff       	call   80045f <dev_lookup>
  8004f9:	89 c3                	mov    %eax,%ebx
  8004fb:	83 c4 10             	add    $0x10,%esp
  8004fe:	85 c0                	test   %eax,%eax
  800500:	78 1a                	js     80051c <fd_close+0x6a>
		if (dev->dev_close)
  800502:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800505:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  800508:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  80050d:	85 c0                	test   %eax,%eax
  80050f:	74 0b                	je     80051c <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	56                   	push   %esi
  800515:	ff d0                	call   *%eax
  800517:	89 c3                	mov    %eax,%ebx
  800519:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	56                   	push   %esi
  800520:	6a 00                	push   $0x0
  800522:	e8 c1 fc ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	89 d8                	mov    %ebx,%eax
}
  80052c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80052f:	5b                   	pop    %ebx
  800530:	5e                   	pop    %esi
  800531:	5d                   	pop    %ebp
  800532:	c3                   	ret    

00800533 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800533:	55                   	push   %ebp
  800534:	89 e5                	mov    %esp,%ebp
  800536:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800539:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80053c:	50                   	push   %eax
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	e8 c4 fe ff ff       	call   800409 <fd_lookup>
  800545:	83 c4 08             	add    $0x8,%esp
  800548:	85 c0                	test   %eax,%eax
  80054a:	78 10                	js     80055c <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80054c:	83 ec 08             	sub    $0x8,%esp
  80054f:	6a 01                	push   $0x1
  800551:	ff 75 f4             	pushl  -0xc(%ebp)
  800554:	e8 59 ff ff ff       	call   8004b2 <fd_close>
  800559:	83 c4 10             	add    $0x10,%esp
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <close_all>:

void
close_all(void)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	53                   	push   %ebx
  800562:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800565:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80056a:	83 ec 0c             	sub    $0xc,%esp
  80056d:	53                   	push   %ebx
  80056e:	e8 c0 ff ff ff       	call   800533 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800573:	83 c3 01             	add    $0x1,%ebx
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	83 fb 20             	cmp    $0x20,%ebx
  80057c:	75 ec                	jne    80056a <close_all+0xc>
		close(i);
}
  80057e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800581:	c9                   	leave  
  800582:	c3                   	ret    

00800583 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800583:	55                   	push   %ebp
  800584:	89 e5                	mov    %esp,%ebp
  800586:	57                   	push   %edi
  800587:	56                   	push   %esi
  800588:	53                   	push   %ebx
  800589:	83 ec 2c             	sub    $0x2c,%esp
  80058c:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80058f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800592:	50                   	push   %eax
  800593:	ff 75 08             	pushl  0x8(%ebp)
  800596:	e8 6e fe ff ff       	call   800409 <fd_lookup>
  80059b:	83 c4 08             	add    $0x8,%esp
  80059e:	85 c0                	test   %eax,%eax
  8005a0:	0f 88 c1 00 00 00    	js     800667 <dup+0xe4>
		return r;
	close(newfdnum);
  8005a6:	83 ec 0c             	sub    $0xc,%esp
  8005a9:	56                   	push   %esi
  8005aa:	e8 84 ff ff ff       	call   800533 <close>

	newfd = INDEX2FD(newfdnum);
  8005af:	89 f3                	mov    %esi,%ebx
  8005b1:	c1 e3 0c             	shl    $0xc,%ebx
  8005b4:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  8005ba:	83 c4 04             	add    $0x4,%esp
  8005bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005c0:	e8 de fd ff ff       	call   8003a3 <fd2data>
  8005c5:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005c7:	89 1c 24             	mov    %ebx,(%esp)
  8005ca:	e8 d4 fd ff ff       	call   8003a3 <fd2data>
  8005cf:	83 c4 10             	add    $0x10,%esp
  8005d2:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005d5:	89 f8                	mov    %edi,%eax
  8005d7:	c1 e8 16             	shr    $0x16,%eax
  8005da:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005e1:	a8 01                	test   $0x1,%al
  8005e3:	74 37                	je     80061c <dup+0x99>
  8005e5:	89 f8                	mov    %edi,%eax
  8005e7:	c1 e8 0c             	shr    $0xc,%eax
  8005ea:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005f1:	f6 c2 01             	test   $0x1,%dl
  8005f4:	74 26                	je     80061c <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f6:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fd:	83 ec 0c             	sub    $0xc,%esp
  800600:	25 07 0e 00 00       	and    $0xe07,%eax
  800605:	50                   	push   %eax
  800606:	ff 75 d4             	pushl  -0x2c(%ebp)
  800609:	6a 00                	push   $0x0
  80060b:	57                   	push   %edi
  80060c:	6a 00                	push   $0x0
  80060e:	e8 93 fb ff ff       	call   8001a6 <sys_page_map>
  800613:	89 c7                	mov    %eax,%edi
  800615:	83 c4 20             	add    $0x20,%esp
  800618:	85 c0                	test   %eax,%eax
  80061a:	78 2e                	js     80064a <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80061c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80061f:	89 d0                	mov    %edx,%eax
  800621:	c1 e8 0c             	shr    $0xc,%eax
  800624:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80062b:	83 ec 0c             	sub    $0xc,%esp
  80062e:	25 07 0e 00 00       	and    $0xe07,%eax
  800633:	50                   	push   %eax
  800634:	53                   	push   %ebx
  800635:	6a 00                	push   $0x0
  800637:	52                   	push   %edx
  800638:	6a 00                	push   $0x0
  80063a:	e8 67 fb ff ff       	call   8001a6 <sys_page_map>
  80063f:	89 c7                	mov    %eax,%edi
  800641:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800644:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800646:	85 ff                	test   %edi,%edi
  800648:	79 1d                	jns    800667 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80064a:	83 ec 08             	sub    $0x8,%esp
  80064d:	53                   	push   %ebx
  80064e:	6a 00                	push   $0x0
  800650:	e8 93 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	ff 75 d4             	pushl  -0x2c(%ebp)
  80065b:	6a 00                	push   $0x0
  80065d:	e8 86 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	89 f8                	mov    %edi,%eax
}
  800667:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80066a:	5b                   	pop    %ebx
  80066b:	5e                   	pop    %esi
  80066c:	5f                   	pop    %edi
  80066d:	5d                   	pop    %ebp
  80066e:	c3                   	ret    

0080066f <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80066f:	55                   	push   %ebp
  800670:	89 e5                	mov    %esp,%ebp
  800672:	53                   	push   %ebx
  800673:	83 ec 14             	sub    $0x14,%esp
  800676:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800679:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80067c:	50                   	push   %eax
  80067d:	53                   	push   %ebx
  80067e:	e8 86 fd ff ff       	call   800409 <fd_lookup>
  800683:	83 c4 08             	add    $0x8,%esp
  800686:	89 c2                	mov    %eax,%edx
  800688:	85 c0                	test   %eax,%eax
  80068a:	78 6d                	js     8006f9 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80068c:	83 ec 08             	sub    $0x8,%esp
  80068f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800692:	50                   	push   %eax
  800693:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800696:	ff 30                	pushl  (%eax)
  800698:	e8 c2 fd ff ff       	call   80045f <dev_lookup>
  80069d:	83 c4 10             	add    $0x10,%esp
  8006a0:	85 c0                	test   %eax,%eax
  8006a2:	78 4c                	js     8006f0 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8006a4:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8006a7:	8b 42 08             	mov    0x8(%edx),%eax
  8006aa:	83 e0 03             	and    $0x3,%eax
  8006ad:	83 f8 01             	cmp    $0x1,%eax
  8006b0:	75 21                	jne    8006d3 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8006b2:	a1 08 40 80 00       	mov    0x804008,%eax
  8006b7:	8b 40 48             	mov    0x48(%eax),%eax
  8006ba:	83 ec 04             	sub    $0x4,%esp
  8006bd:	53                   	push   %ebx
  8006be:	50                   	push   %eax
  8006bf:	68 59 23 80 00       	push   $0x802359
  8006c4:	e8 f4 0e 00 00       	call   8015bd <cprintf>
		return -E_INVAL;
  8006c9:	83 c4 10             	add    $0x10,%esp
  8006cc:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006d1:	eb 26                	jmp    8006f9 <read+0x8a>
	}
	if (!dev->dev_read)
  8006d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006d6:	8b 40 08             	mov    0x8(%eax),%eax
  8006d9:	85 c0                	test   %eax,%eax
  8006db:	74 17                	je     8006f4 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	ff 75 10             	pushl  0x10(%ebp)
  8006e3:	ff 75 0c             	pushl  0xc(%ebp)
  8006e6:	52                   	push   %edx
  8006e7:	ff d0                	call   *%eax
  8006e9:	89 c2                	mov    %eax,%edx
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	eb 09                	jmp    8006f9 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f0:	89 c2                	mov    %eax,%edx
  8006f2:	eb 05                	jmp    8006f9 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006f4:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006f9:	89 d0                	mov    %edx,%eax
  8006fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006fe:	c9                   	leave  
  8006ff:	c3                   	ret    

00800700 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800700:	55                   	push   %ebp
  800701:	89 e5                	mov    %esp,%ebp
  800703:	57                   	push   %edi
  800704:	56                   	push   %esi
  800705:	53                   	push   %ebx
  800706:	83 ec 0c             	sub    $0xc,%esp
  800709:	8b 7d 08             	mov    0x8(%ebp),%edi
  80070c:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80070f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800714:	eb 21                	jmp    800737 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  800716:	83 ec 04             	sub    $0x4,%esp
  800719:	89 f0                	mov    %esi,%eax
  80071b:	29 d8                	sub    %ebx,%eax
  80071d:	50                   	push   %eax
  80071e:	89 d8                	mov    %ebx,%eax
  800720:	03 45 0c             	add    0xc(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	57                   	push   %edi
  800725:	e8 45 ff ff ff       	call   80066f <read>
		if (m < 0)
  80072a:	83 c4 10             	add    $0x10,%esp
  80072d:	85 c0                	test   %eax,%eax
  80072f:	78 10                	js     800741 <readn+0x41>
			return m;
		if (m == 0)
  800731:	85 c0                	test   %eax,%eax
  800733:	74 0a                	je     80073f <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800735:	01 c3                	add    %eax,%ebx
  800737:	39 f3                	cmp    %esi,%ebx
  800739:	72 db                	jb     800716 <readn+0x16>
  80073b:	89 d8                	mov    %ebx,%eax
  80073d:	eb 02                	jmp    800741 <readn+0x41>
  80073f:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800741:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800744:	5b                   	pop    %ebx
  800745:	5e                   	pop    %esi
  800746:	5f                   	pop    %edi
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800749:	55                   	push   %ebp
  80074a:	89 e5                	mov    %esp,%ebp
  80074c:	53                   	push   %ebx
  80074d:	83 ec 14             	sub    $0x14,%esp
  800750:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800753:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800756:	50                   	push   %eax
  800757:	53                   	push   %ebx
  800758:	e8 ac fc ff ff       	call   800409 <fd_lookup>
  80075d:	83 c4 08             	add    $0x8,%esp
  800760:	89 c2                	mov    %eax,%edx
  800762:	85 c0                	test   %eax,%eax
  800764:	78 68                	js     8007ce <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800766:	83 ec 08             	sub    $0x8,%esp
  800769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076c:	50                   	push   %eax
  80076d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800770:	ff 30                	pushl  (%eax)
  800772:	e8 e8 fc ff ff       	call   80045f <dev_lookup>
  800777:	83 c4 10             	add    $0x10,%esp
  80077a:	85 c0                	test   %eax,%eax
  80077c:	78 47                	js     8007c5 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80077e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800781:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800785:	75 21                	jne    8007a8 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800787:	a1 08 40 80 00       	mov    0x804008,%eax
  80078c:	8b 40 48             	mov    0x48(%eax),%eax
  80078f:	83 ec 04             	sub    $0x4,%esp
  800792:	53                   	push   %ebx
  800793:	50                   	push   %eax
  800794:	68 75 23 80 00       	push   $0x802375
  800799:	e8 1f 0e 00 00       	call   8015bd <cprintf>
		return -E_INVAL;
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8007a6:	eb 26                	jmp    8007ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8007a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007ab:	8b 52 0c             	mov    0xc(%edx),%edx
  8007ae:	85 d2                	test   %edx,%edx
  8007b0:	74 17                	je     8007c9 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8007b2:	83 ec 04             	sub    $0x4,%esp
  8007b5:	ff 75 10             	pushl  0x10(%ebp)
  8007b8:	ff 75 0c             	pushl  0xc(%ebp)
  8007bb:	50                   	push   %eax
  8007bc:	ff d2                	call   *%edx
  8007be:	89 c2                	mov    %eax,%edx
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	eb 09                	jmp    8007ce <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c5:	89 c2                	mov    %eax,%edx
  8007c7:	eb 05                	jmp    8007ce <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007c9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ce:	89 d0                	mov    %edx,%eax
  8007d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007d3:	c9                   	leave  
  8007d4:	c3                   	ret    

008007d5 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007d5:	55                   	push   %ebp
  8007d6:	89 e5                	mov    %esp,%ebp
  8007d8:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007db:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007de:	50                   	push   %eax
  8007df:	ff 75 08             	pushl  0x8(%ebp)
  8007e2:	e8 22 fc ff ff       	call   800409 <fd_lookup>
  8007e7:	83 c4 08             	add    $0x8,%esp
  8007ea:	85 c0                	test   %eax,%eax
  8007ec:	78 0e                	js     8007fc <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007ee:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f4:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007f7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	53                   	push   %ebx
  800802:	83 ec 14             	sub    $0x14,%esp
  800805:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  800808:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80080b:	50                   	push   %eax
  80080c:	53                   	push   %ebx
  80080d:	e8 f7 fb ff ff       	call   800409 <fd_lookup>
  800812:	83 c4 08             	add    $0x8,%esp
  800815:	89 c2                	mov    %eax,%edx
  800817:	85 c0                	test   %eax,%eax
  800819:	78 65                	js     800880 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800821:	50                   	push   %eax
  800822:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800825:	ff 30                	pushl  (%eax)
  800827:	e8 33 fc ff ff       	call   80045f <dev_lookup>
  80082c:	83 c4 10             	add    $0x10,%esp
  80082f:	85 c0                	test   %eax,%eax
  800831:	78 44                	js     800877 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800833:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800836:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80083a:	75 21                	jne    80085d <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80083c:	a1 08 40 80 00       	mov    0x804008,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800841:	8b 40 48             	mov    0x48(%eax),%eax
  800844:	83 ec 04             	sub    $0x4,%esp
  800847:	53                   	push   %ebx
  800848:	50                   	push   %eax
  800849:	68 38 23 80 00       	push   $0x802338
  80084e:	e8 6a 0d 00 00       	call   8015bd <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800853:	83 c4 10             	add    $0x10,%esp
  800856:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80085b:	eb 23                	jmp    800880 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80085d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800860:	8b 52 18             	mov    0x18(%edx),%edx
  800863:	85 d2                	test   %edx,%edx
  800865:	74 14                	je     80087b <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	ff 75 0c             	pushl  0xc(%ebp)
  80086d:	50                   	push   %eax
  80086e:	ff d2                	call   *%edx
  800870:	89 c2                	mov    %eax,%edx
  800872:	83 c4 10             	add    $0x10,%esp
  800875:	eb 09                	jmp    800880 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800877:	89 c2                	mov    %eax,%edx
  800879:	eb 05                	jmp    800880 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80087b:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800880:	89 d0                	mov    %edx,%eax
  800882:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800885:	c9                   	leave  
  800886:	c3                   	ret    

00800887 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800887:	55                   	push   %ebp
  800888:	89 e5                	mov    %esp,%ebp
  80088a:	53                   	push   %ebx
  80088b:	83 ec 14             	sub    $0x14,%esp
  80088e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800891:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800894:	50                   	push   %eax
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 6c fb ff ff       	call   800409 <fd_lookup>
  80089d:	83 c4 08             	add    $0x8,%esp
  8008a0:	89 c2                	mov    %eax,%edx
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 58                	js     8008fe <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8008ac:	50                   	push   %eax
  8008ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8008b0:	ff 30                	pushl  (%eax)
  8008b2:	e8 a8 fb ff ff       	call   80045f <dev_lookup>
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 37                	js     8008f5 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  8008be:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008c1:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008c5:	74 32                	je     8008f9 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008c7:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008ca:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008d1:	00 00 00 
	stat->st_isdir = 0;
  8008d4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008db:	00 00 00 
	stat->st_dev = dev;
  8008de:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008e4:	83 ec 08             	sub    $0x8,%esp
  8008e7:	53                   	push   %ebx
  8008e8:	ff 75 f0             	pushl  -0x10(%ebp)
  8008eb:	ff 50 14             	call   *0x14(%eax)
  8008ee:	89 c2                	mov    %eax,%edx
  8008f0:	83 c4 10             	add    $0x10,%esp
  8008f3:	eb 09                	jmp    8008fe <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008f5:	89 c2                	mov    %eax,%edx
  8008f7:	eb 05                	jmp    8008fe <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008f9:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008fe:	89 d0                	mov    %edx,%eax
  800900:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800903:	c9                   	leave  
  800904:	c3                   	ret    

00800905 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	56                   	push   %esi
  800909:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80090a:	83 ec 08             	sub    $0x8,%esp
  80090d:	6a 00                	push   $0x0
  80090f:	ff 75 08             	pushl  0x8(%ebp)
  800912:	e8 e3 01 00 00       	call   800afa <open>
  800917:	89 c3                	mov    %eax,%ebx
  800919:	83 c4 10             	add    $0x10,%esp
  80091c:	85 c0                	test   %eax,%eax
  80091e:	78 1b                	js     80093b <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  800920:	83 ec 08             	sub    $0x8,%esp
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	50                   	push   %eax
  800927:	e8 5b ff ff ff       	call   800887 <fstat>
  80092c:	89 c6                	mov    %eax,%esi
	close(fd);
  80092e:	89 1c 24             	mov    %ebx,(%esp)
  800931:	e8 fd fb ff ff       	call   800533 <close>
	return r;
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	89 f0                	mov    %esi,%eax
}
  80093b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80093e:	5b                   	pop    %ebx
  80093f:	5e                   	pop    %esi
  800940:	5d                   	pop    %ebp
  800941:	c3                   	ret    

00800942 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800942:	55                   	push   %ebp
  800943:	89 e5                	mov    %esp,%ebp
  800945:	56                   	push   %esi
  800946:	53                   	push   %ebx
  800947:	89 c6                	mov    %eax,%esi
  800949:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80094b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800952:	75 12                	jne    800966 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800954:	83 ec 0c             	sub    $0xc,%esp
  800957:	6a 01                	push   $0x1
  800959:	e8 67 16 00 00       	call   801fc5 <ipc_find_env>
  80095e:	a3 00 40 80 00       	mov    %eax,0x804000
  800963:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(fsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800966:	6a 07                	push   $0x7
  800968:	68 00 50 80 00       	push   $0x805000
  80096d:	56                   	push   %esi
  80096e:	ff 35 00 40 80 00    	pushl  0x804000
  800974:	e8 f8 15 00 00       	call   801f71 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800979:	83 c4 0c             	add    $0xc,%esp
  80097c:	6a 00                	push   $0x0
  80097e:	53                   	push   %ebx
  80097f:	6a 00                	push   $0x0
  800981:	e8 82 15 00 00       	call   801f08 <ipc_recv>
}
  800986:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800989:	5b                   	pop    %ebx
  80098a:	5e                   	pop    %esi
  80098b:	5d                   	pop    %ebp
  80098c:	c3                   	ret    

0080098d <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80098d:	55                   	push   %ebp
  80098e:	89 e5                	mov    %esp,%ebp
  800990:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800993:	8b 45 08             	mov    0x8(%ebp),%eax
  800996:	8b 40 0c             	mov    0xc(%eax),%eax
  800999:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a1:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 02 00 00 00       	mov    $0x2,%eax
  8009b0:	e8 8d ff ff ff       	call   800942 <fsipc>
}
  8009b5:	c9                   	leave  
  8009b6:	c3                   	ret    

008009b7 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  8009b7:	55                   	push   %ebp
  8009b8:	89 e5                	mov    %esp,%ebp
  8009ba:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c3:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8009cd:	b8 06 00 00 00       	mov    $0x6,%eax
  8009d2:	e8 6b ff ff ff       	call   800942 <fsipc>
}
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	83 ec 04             	sub    $0x4,%esp
  8009e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e6:	8b 40 0c             	mov    0xc(%eax),%eax
  8009e9:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8009f3:	b8 05 00 00 00       	mov    $0x5,%eax
  8009f8:	e8 45 ff ff ff       	call   800942 <fsipc>
  8009fd:	85 c0                	test   %eax,%eax
  8009ff:	78 2c                	js     800a2d <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800a01:	83 ec 08             	sub    $0x8,%esp
  800a04:	68 00 50 80 00       	push   $0x805000
  800a09:	53                   	push   %ebx
  800a0a:	e8 b2 11 00 00       	call   801bc1 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  800a0f:	a1 80 50 80 00       	mov    0x805080,%eax
  800a14:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  800a1a:	a1 84 50 80 00       	mov    0x805084,%eax
  800a1f:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a25:	83 c4 10             	add    $0x10,%esp
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a2d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a30:	c9                   	leave  
  800a31:	c3                   	ret    

00800a32 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a32:	55                   	push   %ebp
  800a33:	89 e5                	mov    %esp,%ebp
  800a35:	83 ec 0c             	sub    $0xc,%esp
  800a38:	8b 45 10             	mov    0x10(%ebp),%eax
  800a3b:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a40:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a45:	0f 47 c2             	cmova  %edx,%eax
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	if ( n > sizeof (fsipcbuf.write.req_buf)) 
		n = sizeof (fsipcbuf.write.req_buf);
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 52 0c             	mov    0xc(%edx),%edx
  800a4e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a54:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a59:	50                   	push   %eax
  800a5a:	ff 75 0c             	pushl  0xc(%ebp)
  800a5d:	68 08 50 80 00       	push   $0x805008
  800a62:	e8 ec 12 00 00       	call   801d53 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a67:	ba 00 00 00 00       	mov    $0x0,%edx
  800a6c:	b8 04 00 00 00       	mov    $0x4,%eax
  800a71:	e8 cc fe ff ff       	call   800942 <fsipc>
	//panic("devfile_write not implemented");
}
  800a76:	c9                   	leave  
  800a77:	c3                   	ret    

00800a78 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a78:	55                   	push   %ebp
  800a79:	89 e5                	mov    %esp,%ebp
  800a7b:	56                   	push   %esi
  800a7c:	53                   	push   %ebx
  800a7d:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a80:	8b 45 08             	mov    0x8(%ebp),%eax
  800a83:	8b 40 0c             	mov    0xc(%eax),%eax
  800a86:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a8b:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a91:	ba 00 00 00 00       	mov    $0x0,%edx
  800a96:	b8 03 00 00 00       	mov    $0x3,%eax
  800a9b:	e8 a2 fe ff ff       	call   800942 <fsipc>
  800aa0:	89 c3                	mov    %eax,%ebx
  800aa2:	85 c0                	test   %eax,%eax
  800aa4:	78 4b                	js     800af1 <devfile_read+0x79>
		return r;
	assert(r <= n);
  800aa6:	39 c6                	cmp    %eax,%esi
  800aa8:	73 16                	jae    800ac0 <devfile_read+0x48>
  800aaa:	68 a8 23 80 00       	push   $0x8023a8
  800aaf:	68 af 23 80 00       	push   $0x8023af
  800ab4:	6a 7c                	push   $0x7c
  800ab6:	68 c4 23 80 00       	push   $0x8023c4
  800abb:	e8 24 0a 00 00       	call   8014e4 <_panic>
	assert(r <= PGSIZE);
  800ac0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800ac5:	7e 16                	jle    800add <devfile_read+0x65>
  800ac7:	68 cf 23 80 00       	push   $0x8023cf
  800acc:	68 af 23 80 00       	push   $0x8023af
  800ad1:	6a 7d                	push   $0x7d
  800ad3:	68 c4 23 80 00       	push   $0x8023c4
  800ad8:	e8 07 0a 00 00       	call   8014e4 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800add:	83 ec 04             	sub    $0x4,%esp
  800ae0:	50                   	push   %eax
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	ff 75 0c             	pushl  0xc(%ebp)
  800ae9:	e8 65 12 00 00       	call   801d53 <memmove>
	return r;
  800aee:	83 c4 10             	add    $0x10,%esp
}
  800af1:	89 d8                	mov    %ebx,%eax
  800af3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800af6:	5b                   	pop    %ebx
  800af7:	5e                   	pop    %esi
  800af8:	5d                   	pop    %ebp
  800af9:	c3                   	ret    

00800afa <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800afa:	55                   	push   %ebp
  800afb:	89 e5                	mov    %esp,%ebp
  800afd:	53                   	push   %ebx
  800afe:	83 ec 20             	sub    $0x20,%esp
  800b01:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800b04:	53                   	push   %ebx
  800b05:	e8 7e 10 00 00       	call   801b88 <strlen>
  800b0a:	83 c4 10             	add    $0x10,%esp
  800b0d:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800b12:	7f 67                	jg     800b7b <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b14:	83 ec 0c             	sub    $0xc,%esp
  800b17:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800b1a:	50                   	push   %eax
  800b1b:	e8 9a f8 ff ff       	call   8003ba <fd_alloc>
  800b20:	83 c4 10             	add    $0x10,%esp
		return r;
  800b23:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800b25:	85 c0                	test   %eax,%eax
  800b27:	78 57                	js     800b80 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	53                   	push   %ebx
  800b2d:	68 00 50 80 00       	push   $0x805000
  800b32:	e8 8a 10 00 00       	call   801bc1 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3a:	a3 00 54 80 00       	mov    %eax,0x805400

	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b3f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b42:	b8 01 00 00 00       	mov    $0x1,%eax
  800b47:	e8 f6 fd ff ff       	call   800942 <fsipc>
  800b4c:	89 c3                	mov    %eax,%ebx
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	85 c0                	test   %eax,%eax
  800b53:	79 14                	jns    800b69 <open+0x6f>
		fd_close(fd, 0);
  800b55:	83 ec 08             	sub    $0x8,%esp
  800b58:	6a 00                	push   $0x0
  800b5a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b5d:	e8 50 f9 ff ff       	call   8004b2 <fd_close>
		return r;
  800b62:	83 c4 10             	add    $0x10,%esp
  800b65:	89 da                	mov    %ebx,%edx
  800b67:	eb 17                	jmp    800b80 <open+0x86>
	}

	return fd2num(fd);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b6f:	e8 1f f8 ff ff       	call   800393 <fd2num>
  800b74:	89 c2                	mov    %eax,%edx
  800b76:	83 c4 10             	add    $0x10,%esp
  800b79:	eb 05                	jmp    800b80 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b7b:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}

	return fd2num(fd);
}
  800b80:	89 d0                	mov    %edx,%eax
  800b82:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b85:	c9                   	leave  
  800b86:	c3                   	ret    

00800b87 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b87:	55                   	push   %ebp
  800b88:	89 e5                	mov    %esp,%ebp
  800b8a:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 08 00 00 00       	mov    $0x8,%eax
  800b97:	e8 a6 fd ff ff       	call   800942 <fsipc>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <devsock_stat>:
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
}

static int
devsock_stat(struct Fd *fd, struct Stat *stat)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<sock>");
  800ba4:	68 db 23 80 00       	push   $0x8023db
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	e8 10 10 00 00       	call   801bc1 <strcpy>
	return 0;
}
  800bb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bb6:	c9                   	leave  
  800bb7:	c3                   	ret    

00800bb8 <devsock_close>:
	return nsipc_shutdown(r, how);
}

static int
devsock_close(struct Fd *fd)
{
  800bb8:	55                   	push   %ebp
  800bb9:	89 e5                	mov    %esp,%ebp
  800bbb:	53                   	push   %ebx
  800bbc:	83 ec 10             	sub    $0x10,%esp
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (pageref(fd) == 1)
  800bc2:	53                   	push   %ebx
  800bc3:	e8 36 14 00 00       	call   801ffe <pageref>
  800bc8:	83 c4 10             	add    $0x10,%esp
		return nsipc_close(fd->fd_sock.sockid);
	else
		return 0;
  800bcb:	ba 00 00 00 00       	mov    $0x0,%edx
}

static int
devsock_close(struct Fd *fd)
{
	if (pageref(fd) == 1)
  800bd0:	83 f8 01             	cmp    $0x1,%eax
  800bd3:	75 10                	jne    800be5 <devsock_close+0x2d>
		return nsipc_close(fd->fd_sock.sockid);
  800bd5:	83 ec 0c             	sub    $0xc,%esp
  800bd8:	ff 73 0c             	pushl  0xc(%ebx)
  800bdb:	e8 c0 02 00 00       	call   800ea0 <nsipc_close>
  800be0:	89 c2                	mov    %eax,%edx
  800be2:	83 c4 10             	add    $0x10,%esp
	else
		return 0;
}
  800be5:	89 d0                	mov    %edx,%eax
  800be7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <devsock_write>:
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
}

static ssize_t
devsock_write(struct Fd *fd, const void *buf, size_t n)
{
  800bec:	55                   	push   %ebp
  800bed:	89 e5                	mov    %esp,%ebp
  800bef:	83 ec 08             	sub    $0x8,%esp
	return nsipc_send(fd->fd_sock.sockid, buf, n, 0);
  800bf2:	6a 00                	push   $0x0
  800bf4:	ff 75 10             	pushl  0x10(%ebp)
  800bf7:	ff 75 0c             	pushl  0xc(%ebp)
  800bfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800bfd:	ff 70 0c             	pushl  0xc(%eax)
  800c00:	e8 78 03 00 00       	call   800f7d <nsipc_send>
}
  800c05:	c9                   	leave  
  800c06:	c3                   	ret    

00800c07 <devsock_read>:
	return nsipc_listen(r, backlog);
}

static ssize_t
devsock_read(struct Fd *fd, void *buf, size_t n)
{
  800c07:	55                   	push   %ebp
  800c08:	89 e5                	mov    %esp,%ebp
  800c0a:	83 ec 08             	sub    $0x8,%esp
	return nsipc_recv(fd->fd_sock.sockid, buf, n, 0);
  800c0d:	6a 00                	push   $0x0
  800c0f:	ff 75 10             	pushl  0x10(%ebp)
  800c12:	ff 75 0c             	pushl  0xc(%ebp)
  800c15:	8b 45 08             	mov    0x8(%ebp),%eax
  800c18:	ff 70 0c             	pushl  0xc(%eax)
  800c1b:	e8 f1 02 00 00       	call   800f11 <nsipc_recv>
}
  800c20:	c9                   	leave  
  800c21:	c3                   	ret    

00800c22 <fd2sockid>:
	.dev_stat =	devsock_stat,
};

static int
fd2sockid(int fd)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	83 ec 20             	sub    $0x20,%esp
	struct Fd *sfd;
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
  800c28:	8d 55 f4             	lea    -0xc(%ebp),%edx
  800c2b:	52                   	push   %edx
  800c2c:	50                   	push   %eax
  800c2d:	e8 d7 f7 ff ff       	call   800409 <fd_lookup>
  800c32:	83 c4 10             	add    $0x10,%esp
  800c35:	85 c0                	test   %eax,%eax
  800c37:	78 17                	js     800c50 <fd2sockid+0x2e>
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
  800c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800c3c:	8b 0d 20 30 80 00    	mov    0x803020,%ecx
  800c42:	39 08                	cmp    %ecx,(%eax)
  800c44:	75 05                	jne    800c4b <fd2sockid+0x29>
		return -E_NOT_SUPP;
	return sfd->fd_sock.sockid;
  800c46:	8b 40 0c             	mov    0xc(%eax),%eax
  800c49:	eb 05                	jmp    800c50 <fd2sockid+0x2e>
	int r;

	if ((r = fd_lookup(fd, &sfd)) < 0)
		return r;
	if (sfd->fd_dev_id != devsock.dev_id)
		return -E_NOT_SUPP;
  800c4b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
	return sfd->fd_sock.sockid;
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <alloc_sockfd>:

static int
alloc_sockfd(int sockid)
{
  800c52:	55                   	push   %ebp
  800c53:	89 e5                	mov    %esp,%ebp
  800c55:	56                   	push   %esi
  800c56:	53                   	push   %ebx
  800c57:	83 ec 1c             	sub    $0x1c,%esp
  800c5a:	89 c6                	mov    %eax,%esi
	struct Fd *sfd;
	int r;

	if ((r = fd_alloc(&sfd)) < 0
  800c5c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800c5f:	50                   	push   %eax
  800c60:	e8 55 f7 ff ff       	call   8003ba <fd_alloc>
  800c65:	89 c3                	mov    %eax,%ebx
  800c67:	83 c4 10             	add    $0x10,%esp
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	78 1b                	js     800c89 <alloc_sockfd+0x37>
	    || (r = sys_page_alloc(0, sfd, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0) {
  800c6e:	83 ec 04             	sub    $0x4,%esp
  800c71:	68 07 04 00 00       	push   $0x407
  800c76:	ff 75 f4             	pushl  -0xc(%ebp)
  800c79:	6a 00                	push   $0x0
  800c7b:	e8 e3 f4 ff ff       	call   800163 <sys_page_alloc>
  800c80:	89 c3                	mov    %eax,%ebx
  800c82:	83 c4 10             	add    $0x10,%esp
  800c85:	85 c0                	test   %eax,%eax
  800c87:	79 10                	jns    800c99 <alloc_sockfd+0x47>
		nsipc_close(sockid);
  800c89:	83 ec 0c             	sub    $0xc,%esp
  800c8c:	56                   	push   %esi
  800c8d:	e8 0e 02 00 00       	call   800ea0 <nsipc_close>
		return r;
  800c92:	83 c4 10             	add    $0x10,%esp
  800c95:	89 d8                	mov    %ebx,%eax
  800c97:	eb 24                	jmp    800cbd <alloc_sockfd+0x6b>
	}

	sfd->fd_dev_id = devsock.dev_id;
  800c99:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800c9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca2:	89 10                	mov    %edx,(%eax)
	sfd->fd_omode = O_RDWR;
  800ca4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ca7:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	sfd->fd_sock.sockid = sockid;
  800cae:	89 70 0c             	mov    %esi,0xc(%eax)
	return fd2num(sfd);
  800cb1:	83 ec 0c             	sub    $0xc,%esp
  800cb4:	50                   	push   %eax
  800cb5:	e8 d9 f6 ff ff       	call   800393 <fd2num>
  800cba:	83 c4 10             	add    $0x10,%esp
}
  800cbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800cc0:	5b                   	pop    %ebx
  800cc1:	5e                   	pop    %esi
  800cc2:	5d                   	pop    %ebp
  800cc3:	c3                   	ret    

00800cc4 <accept>:

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800cc4:	55                   	push   %ebp
  800cc5:	89 e5                	mov    %esp,%ebp
  800cc7:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	e8 50 ff ff ff       	call   800c22 <fd2sockid>
		return r;
  800cd2:	89 c1                	mov    %eax,%ecx

int
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
  800cd4:	85 c0                	test   %eax,%eax
  800cd6:	78 1f                	js     800cf7 <accept+0x33>
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cd8:	83 ec 04             	sub    $0x4,%esp
  800cdb:	ff 75 10             	pushl  0x10(%ebp)
  800cde:	ff 75 0c             	pushl  0xc(%ebp)
  800ce1:	50                   	push   %eax
  800ce2:	e8 12 01 00 00       	call   800df9 <nsipc_accept>
  800ce7:	83 c4 10             	add    $0x10,%esp
		return r;
  800cea:	89 c1                	mov    %eax,%ecx
accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
	int r;
	if ((r = fd2sockid(s)) < 0)
		return r;
	if ((r = nsipc_accept(r, addr, addrlen)) < 0)
  800cec:	85 c0                	test   %eax,%eax
  800cee:	78 07                	js     800cf7 <accept+0x33>
		return r;
	return alloc_sockfd(r);
  800cf0:	e8 5d ff ff ff       	call   800c52 <alloc_sockfd>
  800cf5:	89 c1                	mov    %eax,%ecx
}
  800cf7:	89 c8                	mov    %ecx,%eax
  800cf9:	c9                   	leave  
  800cfa:	c3                   	ret    

00800cfb <bind>:

int
bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800cfb:	55                   	push   %ebp
  800cfc:	89 e5                	mov    %esp,%ebp
  800cfe:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	e8 19 ff ff ff       	call   800c22 <fd2sockid>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	78 12                	js     800d1f <bind+0x24>
		return r;
	return nsipc_bind(r, name, namelen);
  800d0d:	83 ec 04             	sub    $0x4,%esp
  800d10:	ff 75 10             	pushl  0x10(%ebp)
  800d13:	ff 75 0c             	pushl  0xc(%ebp)
  800d16:	50                   	push   %eax
  800d17:	e8 2d 01 00 00       	call   800e49 <nsipc_bind>
  800d1c:	83 c4 10             	add    $0x10,%esp
}
  800d1f:	c9                   	leave  
  800d20:	c3                   	ret    

00800d21 <shutdown>:

int
shutdown(int s, int how)
{
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	e8 f3 fe ff ff       	call   800c22 <fd2sockid>
  800d2f:	85 c0                	test   %eax,%eax
  800d31:	78 0f                	js     800d42 <shutdown+0x21>
		return r;
	return nsipc_shutdown(r, how);
  800d33:	83 ec 08             	sub    $0x8,%esp
  800d36:	ff 75 0c             	pushl  0xc(%ebp)
  800d39:	50                   	push   %eax
  800d3a:	e8 3f 01 00 00       	call   800e7e <nsipc_shutdown>
  800d3f:	83 c4 10             	add    $0x10,%esp
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <connect>:
		return 0;
}

int
connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800d44:	55                   	push   %ebp
  800d45:	89 e5                	mov    %esp,%ebp
  800d47:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4d:	e8 d0 fe ff ff       	call   800c22 <fd2sockid>
  800d52:	85 c0                	test   %eax,%eax
  800d54:	78 12                	js     800d68 <connect+0x24>
		return r;
	return nsipc_connect(r, name, namelen);
  800d56:	83 ec 04             	sub    $0x4,%esp
  800d59:	ff 75 10             	pushl  0x10(%ebp)
  800d5c:	ff 75 0c             	pushl  0xc(%ebp)
  800d5f:	50                   	push   %eax
  800d60:	e8 55 01 00 00       	call   800eba <nsipc_connect>
  800d65:	83 c4 10             	add    $0x10,%esp
}
  800d68:	c9                   	leave  
  800d69:	c3                   	ret    

00800d6a <listen>:

int
listen(int s, int backlog)
{
  800d6a:	55                   	push   %ebp
  800d6b:	89 e5                	mov    %esp,%ebp
  800d6d:	83 ec 08             	sub    $0x8,%esp
	int r;
	if ((r = fd2sockid(s)) < 0)
  800d70:	8b 45 08             	mov    0x8(%ebp),%eax
  800d73:	e8 aa fe ff ff       	call   800c22 <fd2sockid>
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 0f                	js     800d8b <listen+0x21>
		return r;
	return nsipc_listen(r, backlog);
  800d7c:	83 ec 08             	sub    $0x8,%esp
  800d7f:	ff 75 0c             	pushl  0xc(%ebp)
  800d82:	50                   	push   %eax
  800d83:	e8 67 01 00 00       	call   800eef <nsipc_listen>
  800d88:	83 c4 10             	add    $0x10,%esp
}
  800d8b:	c9                   	leave  
  800d8c:	c3                   	ret    

00800d8d <socket>:
	return 0;
}

int
socket(int domain, int type, int protocol)
{
  800d8d:	55                   	push   %ebp
  800d8e:	89 e5                	mov    %esp,%ebp
  800d90:	83 ec 0c             	sub    $0xc,%esp
	int r;
	if ((r = nsipc_socket(domain, type, protocol)) < 0)
  800d93:	ff 75 10             	pushl  0x10(%ebp)
  800d96:	ff 75 0c             	pushl  0xc(%ebp)
  800d99:	ff 75 08             	pushl  0x8(%ebp)
  800d9c:	e8 3a 02 00 00       	call   800fdb <nsipc_socket>
  800da1:	83 c4 10             	add    $0x10,%esp
  800da4:	85 c0                	test   %eax,%eax
  800da6:	78 05                	js     800dad <socket+0x20>
		return r;
	return alloc_sockfd(r);
  800da8:	e8 a5 fe ff ff       	call   800c52 <alloc_sockfd>
}
  800dad:	c9                   	leave  
  800dae:	c3                   	ret    

00800daf <nsipc>:
// may be written back to nsipcbuf.
// type: request code, passed as the simple integer IPC value.
// Returns 0 if successful, < 0 on failure.
static int
nsipc(unsigned type)
{
  800daf:	55                   	push   %ebp
  800db0:	89 e5                	mov    %esp,%ebp
  800db2:	53                   	push   %ebx
  800db3:	83 ec 04             	sub    $0x4,%esp
  800db6:	89 c3                	mov    %eax,%ebx
	static envid_t nsenv;
	if (nsenv == 0)
  800db8:	83 3d 04 40 80 00 00 	cmpl   $0x0,0x804004
  800dbf:	75 12                	jne    800dd3 <nsipc+0x24>
		nsenv = ipc_find_env(ENV_TYPE_NS);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	6a 02                	push   $0x2
  800dc6:	e8 fa 11 00 00       	call   801fc5 <ipc_find_env>
  800dcb:	a3 04 40 80 00       	mov    %eax,0x804004
  800dd0:	83 c4 10             	add    $0x10,%esp
	static_assert(sizeof(nsipcbuf) == PGSIZE);

	if (debug)
		cprintf("[%08x] nsipc %d\n", thisenv->env_id, type);

	ipc_send(nsenv, type, &nsipcbuf, PTE_P|PTE_W|PTE_U);
  800dd3:	6a 07                	push   $0x7
  800dd5:	68 00 60 80 00       	push   $0x806000
  800dda:	53                   	push   %ebx
  800ddb:	ff 35 04 40 80 00    	pushl  0x804004
  800de1:	e8 8b 11 00 00       	call   801f71 <ipc_send>
	return ipc_recv(NULL, NULL, NULL);
  800de6:	83 c4 0c             	add    $0xc,%esp
  800de9:	6a 00                	push   $0x0
  800deb:	6a 00                	push   $0x0
  800ded:	6a 00                	push   $0x0
  800def:	e8 14 11 00 00       	call   801f08 <ipc_recv>
}
  800df4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800df7:	c9                   	leave  
  800df8:	c3                   	ret    

00800df9 <nsipc_accept>:

int
nsipc_accept(int s, struct sockaddr *addr, socklen_t *addrlen)
{
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.accept.req_s = s;
  800e01:	8b 45 08             	mov    0x8(%ebp),%eax
  800e04:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.accept.req_addrlen = *addrlen;
  800e09:	8b 06                	mov    (%esi),%eax
  800e0b:	a3 04 60 80 00       	mov    %eax,0x806004
	if ((r = nsipc(NSREQ_ACCEPT)) >= 0) {
  800e10:	b8 01 00 00 00       	mov    $0x1,%eax
  800e15:	e8 95 ff ff ff       	call   800daf <nsipc>
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	85 c0                	test   %eax,%eax
  800e1e:	78 20                	js     800e40 <nsipc_accept+0x47>
		struct Nsret_accept *ret = &nsipcbuf.acceptRet;
		memmove(addr, &ret->ret_addr, ret->ret_addrlen);
  800e20:	83 ec 04             	sub    $0x4,%esp
  800e23:	ff 35 10 60 80 00    	pushl  0x806010
  800e29:	68 00 60 80 00       	push   $0x806000
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	e8 1d 0f 00 00       	call   801d53 <memmove>
		*addrlen = ret->ret_addrlen;
  800e36:	a1 10 60 80 00       	mov    0x806010,%eax
  800e3b:	89 06                	mov    %eax,(%esi)
  800e3d:	83 c4 10             	add    $0x10,%esp
	}
	return r;
}
  800e40:	89 d8                	mov    %ebx,%eax
  800e42:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5d                   	pop    %ebp
  800e48:	c3                   	ret    

00800e49 <nsipc_bind>:

int
nsipc_bind(int s, struct sockaddr *name, socklen_t namelen)
{
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	53                   	push   %ebx
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.bind.req_s = s;
  800e53:	8b 45 08             	mov    0x8(%ebp),%eax
  800e56:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.bind.req_name, name, namelen);
  800e5b:	53                   	push   %ebx
  800e5c:	ff 75 0c             	pushl  0xc(%ebp)
  800e5f:	68 04 60 80 00       	push   $0x806004
  800e64:	e8 ea 0e 00 00       	call   801d53 <memmove>
	nsipcbuf.bind.req_namelen = namelen;
  800e69:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_BIND);
  800e6f:	b8 02 00 00 00       	mov    $0x2,%eax
  800e74:	e8 36 ff ff ff       	call   800daf <nsipc>
}
  800e79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e7c:	c9                   	leave  
  800e7d:	c3                   	ret    

00800e7e <nsipc_shutdown>:

int
nsipc_shutdown(int s, int how)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.shutdown.req_s = s;
  800e84:	8b 45 08             	mov    0x8(%ebp),%eax
  800e87:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.shutdown.req_how = how;
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_SHUTDOWN);
  800e94:	b8 03 00 00 00       	mov    $0x3,%eax
  800e99:	e8 11 ff ff ff       	call   800daf <nsipc>
}
  800e9e:	c9                   	leave  
  800e9f:	c3                   	ret    

00800ea0 <nsipc_close>:

int
nsipc_close(int s)
{
  800ea0:	55                   	push   %ebp
  800ea1:	89 e5                	mov    %esp,%ebp
  800ea3:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.close.req_s = s;
  800ea6:	8b 45 08             	mov    0x8(%ebp),%eax
  800ea9:	a3 00 60 80 00       	mov    %eax,0x806000
	return nsipc(NSREQ_CLOSE);
  800eae:	b8 04 00 00 00       	mov    $0x4,%eax
  800eb3:	e8 f7 fe ff ff       	call   800daf <nsipc>
}
  800eb8:	c9                   	leave  
  800eb9:	c3                   	ret    

00800eba <nsipc_connect>:

int
nsipc_connect(int s, const struct sockaddr *name, socklen_t namelen)
{
  800eba:	55                   	push   %ebp
  800ebb:	89 e5                	mov    %esp,%ebp
  800ebd:	53                   	push   %ebx
  800ebe:	83 ec 08             	sub    $0x8,%esp
  800ec1:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.connect.req_s = s;
  800ec4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec7:	a3 00 60 80 00       	mov    %eax,0x806000
	memmove(&nsipcbuf.connect.req_name, name, namelen);
  800ecc:	53                   	push   %ebx
  800ecd:	ff 75 0c             	pushl  0xc(%ebp)
  800ed0:	68 04 60 80 00       	push   $0x806004
  800ed5:	e8 79 0e 00 00       	call   801d53 <memmove>
	nsipcbuf.connect.req_namelen = namelen;
  800eda:	89 1d 14 60 80 00    	mov    %ebx,0x806014
	return nsipc(NSREQ_CONNECT);
  800ee0:	b8 05 00 00 00       	mov    $0x5,%eax
  800ee5:	e8 c5 fe ff ff       	call   800daf <nsipc>
}
  800eea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800eed:	c9                   	leave  
  800eee:	c3                   	ret    

00800eef <nsipc_listen>:

int
nsipc_listen(int s, int backlog)
{
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.listen.req_s = s;
  800ef5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef8:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.listen.req_backlog = backlog;
  800efd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f00:	a3 04 60 80 00       	mov    %eax,0x806004
	return nsipc(NSREQ_LISTEN);
  800f05:	b8 06 00 00 00       	mov    $0x6,%eax
  800f0a:	e8 a0 fe ff ff       	call   800daf <nsipc>
}
  800f0f:	c9                   	leave  
  800f10:	c3                   	ret    

00800f11 <nsipc_recv>:

int
nsipc_recv(int s, void *mem, int len, unsigned int flags)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	56                   	push   %esi
  800f15:	53                   	push   %ebx
  800f16:	8b 75 10             	mov    0x10(%ebp),%esi
	int r;

	nsipcbuf.recv.req_s = s;
  800f19:	8b 45 08             	mov    0x8(%ebp),%eax
  800f1c:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.recv.req_len = len;
  800f21:	89 35 04 60 80 00    	mov    %esi,0x806004
	nsipcbuf.recv.req_flags = flags;
  800f27:	8b 45 14             	mov    0x14(%ebp),%eax
  800f2a:	a3 08 60 80 00       	mov    %eax,0x806008

	if ((r = nsipc(NSREQ_RECV)) >= 0) {
  800f2f:	b8 07 00 00 00       	mov    $0x7,%eax
  800f34:	e8 76 fe ff ff       	call   800daf <nsipc>
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	85 c0                	test   %eax,%eax
  800f3d:	78 35                	js     800f74 <nsipc_recv+0x63>
		assert(r < 1600 && r <= len);
  800f3f:	3d 3f 06 00 00       	cmp    $0x63f,%eax
  800f44:	7f 04                	jg     800f4a <nsipc_recv+0x39>
  800f46:	39 c6                	cmp    %eax,%esi
  800f48:	7d 16                	jge    800f60 <nsipc_recv+0x4f>
  800f4a:	68 e7 23 80 00       	push   $0x8023e7
  800f4f:	68 af 23 80 00       	push   $0x8023af
  800f54:	6a 62                	push   $0x62
  800f56:	68 fc 23 80 00       	push   $0x8023fc
  800f5b:	e8 84 05 00 00       	call   8014e4 <_panic>
		memmove(mem, nsipcbuf.recvRet.ret_buf, r);
  800f60:	83 ec 04             	sub    $0x4,%esp
  800f63:	50                   	push   %eax
  800f64:	68 00 60 80 00       	push   $0x806000
  800f69:	ff 75 0c             	pushl  0xc(%ebp)
  800f6c:	e8 e2 0d 00 00       	call   801d53 <memmove>
  800f71:	83 c4 10             	add    $0x10,%esp
	}

	return r;
}
  800f74:	89 d8                	mov    %ebx,%eax
  800f76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800f79:	5b                   	pop    %ebx
  800f7a:	5e                   	pop    %esi
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <nsipc_send>:

int
nsipc_send(int s, const void *buf, int size, unsigned int flags)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	53                   	push   %ebx
  800f81:	83 ec 04             	sub    $0x4,%esp
  800f84:	8b 5d 10             	mov    0x10(%ebp),%ebx
	nsipcbuf.send.req_s = s;
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	a3 00 60 80 00       	mov    %eax,0x806000
	assert(size < 1600);
  800f8f:	81 fb 3f 06 00 00    	cmp    $0x63f,%ebx
  800f95:	7e 16                	jle    800fad <nsipc_send+0x30>
  800f97:	68 08 24 80 00       	push   $0x802408
  800f9c:	68 af 23 80 00       	push   $0x8023af
  800fa1:	6a 6d                	push   $0x6d
  800fa3:	68 fc 23 80 00       	push   $0x8023fc
  800fa8:	e8 37 05 00 00       	call   8014e4 <_panic>
	memmove(&nsipcbuf.send.req_buf, buf, size);
  800fad:	83 ec 04             	sub    $0x4,%esp
  800fb0:	53                   	push   %ebx
  800fb1:	ff 75 0c             	pushl  0xc(%ebp)
  800fb4:	68 0c 60 80 00       	push   $0x80600c
  800fb9:	e8 95 0d 00 00       	call   801d53 <memmove>
	nsipcbuf.send.req_size = size;
  800fbe:	89 1d 04 60 80 00    	mov    %ebx,0x806004
	nsipcbuf.send.req_flags = flags;
  800fc4:	8b 45 14             	mov    0x14(%ebp),%eax
  800fc7:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SEND);
  800fcc:	b8 08 00 00 00       	mov    $0x8,%eax
  800fd1:	e8 d9 fd ff ff       	call   800daf <nsipc>
}
  800fd6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd9:	c9                   	leave  
  800fda:	c3                   	ret    

00800fdb <nsipc_socket>:

int
nsipc_socket(int domain, int type, int protocol)
{
  800fdb:	55                   	push   %ebp
  800fdc:	89 e5                	mov    %esp,%ebp
  800fde:	83 ec 08             	sub    $0x8,%esp
	nsipcbuf.socket.req_domain = domain;
  800fe1:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe4:	a3 00 60 80 00       	mov    %eax,0x806000
	nsipcbuf.socket.req_type = type;
  800fe9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fec:	a3 04 60 80 00       	mov    %eax,0x806004
	nsipcbuf.socket.req_protocol = protocol;
  800ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff4:	a3 08 60 80 00       	mov    %eax,0x806008
	return nsipc(NSREQ_SOCKET);
  800ff9:	b8 09 00 00 00       	mov    $0x9,%eax
  800ffe:	e8 ac fd ff ff       	call   800daf <nsipc>
}
  801003:	c9                   	leave  
  801004:	c3                   	ret    

00801005 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801005:	55                   	push   %ebp
  801006:	89 e5                	mov    %esp,%ebp
  801008:	56                   	push   %esi
  801009:	53                   	push   %ebx
  80100a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80100d:	83 ec 0c             	sub    $0xc,%esp
  801010:	ff 75 08             	pushl  0x8(%ebp)
  801013:	e8 8b f3 ff ff       	call   8003a3 <fd2data>
  801018:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80101a:	83 c4 08             	add    $0x8,%esp
  80101d:	68 14 24 80 00       	push   $0x802414
  801022:	53                   	push   %ebx
  801023:	e8 99 0b 00 00       	call   801bc1 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801028:	8b 46 04             	mov    0x4(%esi),%eax
  80102b:	2b 06                	sub    (%esi),%eax
  80102d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801033:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80103a:	00 00 00 
	stat->st_dev = &devpipe;
  80103d:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  801044:	30 80 00 
	return 0;
}
  801047:	b8 00 00 00 00       	mov    $0x0,%eax
  80104c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80104f:	5b                   	pop    %ebx
  801050:	5e                   	pop    %esi
  801051:	5d                   	pop    %ebp
  801052:	c3                   	ret    

00801053 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801053:	55                   	push   %ebp
  801054:	89 e5                	mov    %esp,%ebp
  801056:	53                   	push   %ebx
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80105d:	53                   	push   %ebx
  80105e:	6a 00                	push   $0x0
  801060:	e8 83 f1 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801065:	89 1c 24             	mov    %ebx,(%esp)
  801068:	e8 36 f3 ff ff       	call   8003a3 <fd2data>
  80106d:	83 c4 08             	add    $0x8,%esp
  801070:	50                   	push   %eax
  801071:	6a 00                	push   $0x0
  801073:	e8 70 f1 ff ff       	call   8001e8 <sys_page_unmap>
}
  801078:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80107b:	c9                   	leave  
  80107c:	c3                   	ret    

0080107d <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	57                   	push   %edi
  801081:	56                   	push   %esi
  801082:	53                   	push   %ebx
  801083:	83 ec 1c             	sub    $0x1c,%esp
  801086:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801089:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  80108b:	a1 08 40 80 00       	mov    0x804008,%eax
  801090:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  801093:	83 ec 0c             	sub    $0xc,%esp
  801096:	ff 75 e0             	pushl  -0x20(%ebp)
  801099:	e8 60 0f 00 00       	call   801ffe <pageref>
  80109e:	89 c3                	mov    %eax,%ebx
  8010a0:	89 3c 24             	mov    %edi,(%esp)
  8010a3:	e8 56 0f 00 00       	call   801ffe <pageref>
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	39 c3                	cmp    %eax,%ebx
  8010ad:	0f 94 c1             	sete   %cl
  8010b0:	0f b6 c9             	movzbl %cl,%ecx
  8010b3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  8010b6:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8010bc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8010bf:	39 ce                	cmp    %ecx,%esi
  8010c1:	74 1b                	je     8010de <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  8010c3:	39 c3                	cmp    %eax,%ebx
  8010c5:	75 c4                	jne    80108b <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8010c7:	8b 42 58             	mov    0x58(%edx),%eax
  8010ca:	ff 75 e4             	pushl  -0x1c(%ebp)
  8010cd:	50                   	push   %eax
  8010ce:	56                   	push   %esi
  8010cf:	68 1b 24 80 00       	push   $0x80241b
  8010d4:	e8 e4 04 00 00       	call   8015bd <cprintf>
  8010d9:	83 c4 10             	add    $0x10,%esp
  8010dc:	eb ad                	jmp    80108b <_pipeisclosed+0xe>
	}
}
  8010de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8010e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e4:	5b                   	pop    %ebx
  8010e5:	5e                   	pop    %esi
  8010e6:	5f                   	pop    %edi
  8010e7:	5d                   	pop    %ebp
  8010e8:	c3                   	ret    

008010e9 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  8010e9:	55                   	push   %ebp
  8010ea:	89 e5                	mov    %esp,%ebp
  8010ec:	57                   	push   %edi
  8010ed:	56                   	push   %esi
  8010ee:	53                   	push   %ebx
  8010ef:	83 ec 28             	sub    $0x28,%esp
  8010f2:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  8010f5:	56                   	push   %esi
  8010f6:	e8 a8 f2 ff ff       	call   8003a3 <fd2data>
  8010fb:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8010fd:	83 c4 10             	add    $0x10,%esp
  801100:	bf 00 00 00 00       	mov    $0x0,%edi
  801105:	eb 4b                	jmp    801152 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  801107:	89 da                	mov    %ebx,%edx
  801109:	89 f0                	mov    %esi,%eax
  80110b:	e8 6d ff ff ff       	call   80107d <_pipeisclosed>
  801110:	85 c0                	test   %eax,%eax
  801112:	75 48                	jne    80115c <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  801114:	e8 2b f0 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801119:	8b 43 04             	mov    0x4(%ebx),%eax
  80111c:	8b 0b                	mov    (%ebx),%ecx
  80111e:	8d 51 20             	lea    0x20(%ecx),%edx
  801121:	39 d0                	cmp    %edx,%eax
  801123:	73 e2                	jae    801107 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801125:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801128:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80112c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80112f:	89 c2                	mov    %eax,%edx
  801131:	c1 fa 1f             	sar    $0x1f,%edx
  801134:	89 d1                	mov    %edx,%ecx
  801136:	c1 e9 1b             	shr    $0x1b,%ecx
  801139:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80113c:	83 e2 1f             	and    $0x1f,%edx
  80113f:	29 ca                	sub    %ecx,%edx
  801141:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801145:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801149:	83 c0 01             	add    $0x1,%eax
  80114c:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80114f:	83 c7 01             	add    $0x1,%edi
  801152:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801155:	75 c2                	jne    801119 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  801157:	8b 45 10             	mov    0x10(%ebp),%eax
  80115a:	eb 05                	jmp    801161 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  80115c:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  801161:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801164:	5b                   	pop    %ebx
  801165:	5e                   	pop    %esi
  801166:	5f                   	pop    %edi
  801167:	5d                   	pop    %ebp
  801168:	c3                   	ret    

00801169 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  801169:	55                   	push   %ebp
  80116a:	89 e5                	mov    %esp,%ebp
  80116c:	57                   	push   %edi
  80116d:	56                   	push   %esi
  80116e:	53                   	push   %ebx
  80116f:	83 ec 18             	sub    $0x18,%esp
  801172:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  801175:	57                   	push   %edi
  801176:	e8 28 f2 ff ff       	call   8003a3 <fd2data>
  80117b:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  80117d:	83 c4 10             	add    $0x10,%esp
  801180:	bb 00 00 00 00       	mov    $0x0,%ebx
  801185:	eb 3d                	jmp    8011c4 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  801187:	85 db                	test   %ebx,%ebx
  801189:	74 04                	je     80118f <devpipe_read+0x26>
				return i;
  80118b:	89 d8                	mov    %ebx,%eax
  80118d:	eb 44                	jmp    8011d3 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  80118f:	89 f2                	mov    %esi,%edx
  801191:	89 f8                	mov    %edi,%eax
  801193:	e8 e5 fe ff ff       	call   80107d <_pipeisclosed>
  801198:	85 c0                	test   %eax,%eax
  80119a:	75 32                	jne    8011ce <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  80119c:	e8 a3 ef ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  8011a1:	8b 06                	mov    (%esi),%eax
  8011a3:	3b 46 04             	cmp    0x4(%esi),%eax
  8011a6:	74 df                	je     801187 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8011a8:	99                   	cltd   
  8011a9:	c1 ea 1b             	shr    $0x1b,%edx
  8011ac:	01 d0                	add    %edx,%eax
  8011ae:	83 e0 1f             	and    $0x1f,%eax
  8011b1:	29 d0                	sub    %edx,%eax
  8011b3:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  8011b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011bb:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  8011be:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  8011c1:	83 c3 01             	add    $0x1,%ebx
  8011c4:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  8011c7:	75 d8                	jne    8011a1 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  8011c9:	8b 45 10             	mov    0x10(%ebp),%eax
  8011cc:	eb 05                	jmp    8011d3 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  8011ce:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  8011d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d6:	5b                   	pop    %ebx
  8011d7:	5e                   	pop    %esi
  8011d8:	5f                   	pop    %edi
  8011d9:	5d                   	pop    %ebp
  8011da:	c3                   	ret    

008011db <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  8011db:	55                   	push   %ebp
  8011dc:	89 e5                	mov    %esp,%ebp
  8011de:	56                   	push   %esi
  8011df:	53                   	push   %ebx
  8011e0:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  8011e3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	e8 ce f1 ff ff       	call   8003ba <fd_alloc>
  8011ec:	83 c4 10             	add    $0x10,%esp
  8011ef:	89 c2                	mov    %eax,%edx
  8011f1:	85 c0                	test   %eax,%eax
  8011f3:	0f 88 2c 01 00 00    	js     801325 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8011f9:	83 ec 04             	sub    $0x4,%esp
  8011fc:	68 07 04 00 00       	push   $0x407
  801201:	ff 75 f4             	pushl  -0xc(%ebp)
  801204:	6a 00                	push   $0x0
  801206:	e8 58 ef ff ff       	call   800163 <sys_page_alloc>
  80120b:	83 c4 10             	add    $0x10,%esp
  80120e:	89 c2                	mov    %eax,%edx
  801210:	85 c0                	test   %eax,%eax
  801212:	0f 88 0d 01 00 00    	js     801325 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  801218:	83 ec 0c             	sub    $0xc,%esp
  80121b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80121e:	50                   	push   %eax
  80121f:	e8 96 f1 ff ff       	call   8003ba <fd_alloc>
  801224:	89 c3                	mov    %eax,%ebx
  801226:	83 c4 10             	add    $0x10,%esp
  801229:	85 c0                	test   %eax,%eax
  80122b:	0f 88 e2 00 00 00    	js     801313 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801231:	83 ec 04             	sub    $0x4,%esp
  801234:	68 07 04 00 00       	push   $0x407
  801239:	ff 75 f0             	pushl  -0x10(%ebp)
  80123c:	6a 00                	push   $0x0
  80123e:	e8 20 ef ff ff       	call   800163 <sys_page_alloc>
  801243:	89 c3                	mov    %eax,%ebx
  801245:	83 c4 10             	add    $0x10,%esp
  801248:	85 c0                	test   %eax,%eax
  80124a:	0f 88 c3 00 00 00    	js     801313 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  801250:	83 ec 0c             	sub    $0xc,%esp
  801253:	ff 75 f4             	pushl  -0xc(%ebp)
  801256:	e8 48 f1 ff ff       	call   8003a3 <fd2data>
  80125b:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80125d:	83 c4 0c             	add    $0xc,%esp
  801260:	68 07 04 00 00       	push   $0x407
  801265:	50                   	push   %eax
  801266:	6a 00                	push   $0x0
  801268:	e8 f6 ee ff ff       	call   800163 <sys_page_alloc>
  80126d:	89 c3                	mov    %eax,%ebx
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	0f 88 89 00 00 00    	js     801303 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80127a:	83 ec 0c             	sub    $0xc,%esp
  80127d:	ff 75 f0             	pushl  -0x10(%ebp)
  801280:	e8 1e f1 ff ff       	call   8003a3 <fd2data>
  801285:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80128c:	50                   	push   %eax
  80128d:	6a 00                	push   $0x0
  80128f:	56                   	push   %esi
  801290:	6a 00                	push   $0x0
  801292:	e8 0f ef ff ff       	call   8001a6 <sys_page_map>
  801297:	89 c3                	mov    %eax,%ebx
  801299:	83 c4 20             	add    $0x20,%esp
  80129c:	85 c0                	test   %eax,%eax
  80129e:	78 55                	js     8012f5 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  8012a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012a9:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  8012ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012ae:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  8012b5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8012bb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012be:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  8012c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012c3:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  8012ca:	83 ec 0c             	sub    $0xc,%esp
  8012cd:	ff 75 f4             	pushl  -0xc(%ebp)
  8012d0:	e8 be f0 ff ff       	call   800393 <fd2num>
  8012d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d8:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8012da:	83 c4 04             	add    $0x4,%esp
  8012dd:	ff 75 f0             	pushl  -0x10(%ebp)
  8012e0:	e8 ae f0 ff ff       	call   800393 <fd2num>
  8012e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012e8:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8012eb:	83 c4 10             	add    $0x10,%esp
  8012ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8012f3:	eb 30                	jmp    801325 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  8012f5:	83 ec 08             	sub    $0x8,%esp
  8012f8:	56                   	push   %esi
  8012f9:	6a 00                	push   $0x0
  8012fb:	e8 e8 ee ff ff       	call   8001e8 <sys_page_unmap>
  801300:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  801303:	83 ec 08             	sub    $0x8,%esp
  801306:	ff 75 f0             	pushl  -0x10(%ebp)
  801309:	6a 00                	push   $0x0
  80130b:	e8 d8 ee ff ff       	call   8001e8 <sys_page_unmap>
  801310:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  801313:	83 ec 08             	sub    $0x8,%esp
  801316:	ff 75 f4             	pushl  -0xc(%ebp)
  801319:	6a 00                	push   $0x0
  80131b:	e8 c8 ee ff ff       	call   8001e8 <sys_page_unmap>
  801320:	83 c4 10             	add    $0x10,%esp
  801323:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  801325:	89 d0                	mov    %edx,%eax
  801327:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80132a:	5b                   	pop    %ebx
  80132b:	5e                   	pop    %esi
  80132c:	5d                   	pop    %ebp
  80132d:	c3                   	ret    

0080132e <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  80132e:	55                   	push   %ebp
  80132f:	89 e5                	mov    %esp,%ebp
  801331:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801334:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801337:	50                   	push   %eax
  801338:	ff 75 08             	pushl  0x8(%ebp)
  80133b:	e8 c9 f0 ff ff       	call   800409 <fd_lookup>
  801340:	83 c4 10             	add    $0x10,%esp
  801343:	85 c0                	test   %eax,%eax
  801345:	78 18                	js     80135f <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  801347:	83 ec 0c             	sub    $0xc,%esp
  80134a:	ff 75 f4             	pushl  -0xc(%ebp)
  80134d:	e8 51 f0 ff ff       	call   8003a3 <fd2data>
	return _pipeisclosed(fd, p);
  801352:	89 c2                	mov    %eax,%edx
  801354:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801357:	e8 21 fd ff ff       	call   80107d <_pipeisclosed>
  80135c:	83 c4 10             	add    $0x10,%esp
}
  80135f:	c9                   	leave  
  801360:	c3                   	ret    

00801361 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801361:	55                   	push   %ebp
  801362:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  801364:	b8 00 00 00 00       	mov    $0x0,%eax
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    

0080136b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801371:	68 33 24 80 00       	push   $0x802433
  801376:	ff 75 0c             	pushl  0xc(%ebp)
  801379:	e8 43 08 00 00       	call   801bc1 <strcpy>
	return 0;
}
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	c9                   	leave  
  801384:	c3                   	ret    

00801385 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  801385:	55                   	push   %ebp
  801386:	89 e5                	mov    %esp,%ebp
  801388:	57                   	push   %edi
  801389:	56                   	push   %esi
  80138a:	53                   	push   %ebx
  80138b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  801391:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  801396:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  80139c:	eb 2d                	jmp    8013cb <devcons_write+0x46>
		m = n - tot;
  80139e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013a1:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  8013a3:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  8013a6:	ba 7f 00 00 00       	mov    $0x7f,%edx
  8013ab:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  8013ae:	83 ec 04             	sub    $0x4,%esp
  8013b1:	53                   	push   %ebx
  8013b2:	03 45 0c             	add    0xc(%ebp),%eax
  8013b5:	50                   	push   %eax
  8013b6:	57                   	push   %edi
  8013b7:	e8 97 09 00 00       	call   801d53 <memmove>
		sys_cputs(buf, m);
  8013bc:	83 c4 08             	add    $0x8,%esp
  8013bf:	53                   	push   %ebx
  8013c0:	57                   	push   %edi
  8013c1:	e8 e1 ec ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  8013c6:	01 de                	add    %ebx,%esi
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	89 f0                	mov    %esi,%eax
  8013cd:	3b 75 10             	cmp    0x10(%ebp),%esi
  8013d0:	72 cc                	jb     80139e <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  8013d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d5:	5b                   	pop    %ebx
  8013d6:	5e                   	pop    %esi
  8013d7:	5f                   	pop    %edi
  8013d8:	5d                   	pop    %ebp
  8013d9:	c3                   	ret    

008013da <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  8013e5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8013e9:	74 2a                	je     801415 <devcons_read+0x3b>
  8013eb:	eb 05                	jmp    8013f2 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  8013ed:	e8 52 ed ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  8013f2:	e8 ce ec ff ff       	call   8000c5 <sys_cgetc>
  8013f7:	85 c0                	test   %eax,%eax
  8013f9:	74 f2                	je     8013ed <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  8013fb:	85 c0                	test   %eax,%eax
  8013fd:	78 16                	js     801415 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  8013ff:	83 f8 04             	cmp    $0x4,%eax
  801402:	74 0c                	je     801410 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  801404:	8b 55 0c             	mov    0xc(%ebp),%edx
  801407:	88 02                	mov    %al,(%edx)
	return 1;
  801409:	b8 01 00 00 00       	mov    $0x1,%eax
  80140e:	eb 05                	jmp    801415 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  801415:	c9                   	leave  
  801416:	c3                   	ret    

00801417 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>
//控制台I/O文件类型的驱动 
void
cputchar(int ch)
{
  801417:	55                   	push   %ebp
  801418:	89 e5                	mov    %esp,%ebp
  80141a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80141d:	8b 45 08             	mov    0x8(%ebp),%eax
  801420:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  801423:	6a 01                	push   $0x1
  801425:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801428:	50                   	push   %eax
  801429:	e8 79 ec ff ff       	call   8000a7 <sys_cputs>
}
  80142e:	83 c4 10             	add    $0x10,%esp
  801431:	c9                   	leave  
  801432:	c3                   	ret    

00801433 <getchar>:

int
getchar(void)
{
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  801439:	6a 01                	push   $0x1
  80143b:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80143e:	50                   	push   %eax
  80143f:	6a 00                	push   $0x0
  801441:	e8 29 f2 ff ff       	call   80066f <read>
	if (r < 0)
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	85 c0                	test   %eax,%eax
  80144b:	78 0f                	js     80145c <getchar+0x29>
		return r;
	if (r < 1)
  80144d:	85 c0                	test   %eax,%eax
  80144f:	7e 06                	jle    801457 <getchar+0x24>
		return -E_EOF;
	return c;
  801451:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  801455:	eb 05                	jmp    80145c <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  801457:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  80145c:	c9                   	leave  
  80145d:	c3                   	ret    

0080145e <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  80145e:	55                   	push   %ebp
  80145f:	89 e5                	mov    %esp,%ebp
  801461:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801464:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801467:	50                   	push   %eax
  801468:	ff 75 08             	pushl  0x8(%ebp)
  80146b:	e8 99 ef ff ff       	call   800409 <fd_lookup>
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	85 c0                	test   %eax,%eax
  801475:	78 11                	js     801488 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  801477:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147a:	8b 15 58 30 80 00    	mov    0x803058,%edx
  801480:	39 10                	cmp    %edx,(%eax)
  801482:	0f 94 c0             	sete   %al
  801485:	0f b6 c0             	movzbl %al,%eax
}
  801488:	c9                   	leave  
  801489:	c3                   	ret    

0080148a <opencons>:

int
opencons(void)
{
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801490:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801493:	50                   	push   %eax
  801494:	e8 21 ef ff ff       	call   8003ba <fd_alloc>
  801499:	83 c4 10             	add    $0x10,%esp
		return r;
  80149c:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80149e:	85 c0                	test   %eax,%eax
  8014a0:	78 3e                	js     8014e0 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014a2:	83 ec 04             	sub    $0x4,%esp
  8014a5:	68 07 04 00 00       	push   $0x407
  8014aa:	ff 75 f4             	pushl  -0xc(%ebp)
  8014ad:	6a 00                	push   $0x0
  8014af:	e8 af ec ff ff       	call   800163 <sys_page_alloc>
  8014b4:	83 c4 10             	add    $0x10,%esp
		return r;
  8014b7:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8014b9:	85 c0                	test   %eax,%eax
  8014bb:	78 23                	js     8014e0 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  8014bd:	8b 15 58 30 80 00    	mov    0x803058,%edx
  8014c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014c6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8014c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cb:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8014d2:	83 ec 0c             	sub    $0xc,%esp
  8014d5:	50                   	push   %eax
  8014d6:	e8 b8 ee ff ff       	call   800393 <fd2num>
  8014db:	89 c2                	mov    %eax,%edx
  8014dd:	83 c4 10             	add    $0x10,%esp
}
  8014e0:	89 d0                	mov    %edx,%eax
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    

008014e4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8014e4:	55                   	push   %ebp
  8014e5:	89 e5                	mov    %esp,%ebp
  8014e7:	56                   	push   %esi
  8014e8:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8014e9:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8014ec:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8014f2:	e8 2e ec ff ff       	call   800125 <sys_getenvid>
  8014f7:	83 ec 0c             	sub    $0xc,%esp
  8014fa:	ff 75 0c             	pushl  0xc(%ebp)
  8014fd:	ff 75 08             	pushl  0x8(%ebp)
  801500:	56                   	push   %esi
  801501:	50                   	push   %eax
  801502:	68 40 24 80 00       	push   $0x802440
  801507:	e8 b1 00 00 00       	call   8015bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80150c:	83 c4 18             	add    $0x18,%esp
  80150f:	53                   	push   %ebx
  801510:	ff 75 10             	pushl  0x10(%ebp)
  801513:	e8 54 00 00 00       	call   80156c <vcprintf>
	cprintf("\n");
  801518:	c7 04 24 2c 24 80 00 	movl   $0x80242c,(%esp)
  80151f:	e8 99 00 00 00       	call   8015bd <cprintf>
  801524:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801527:	cc                   	int3   
  801528:	eb fd                	jmp    801527 <_panic+0x43>

0080152a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80152a:	55                   	push   %ebp
  80152b:	89 e5                	mov    %esp,%ebp
  80152d:	53                   	push   %ebx
  80152e:	83 ec 04             	sub    $0x4,%esp
  801531:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801534:	8b 13                	mov    (%ebx),%edx
  801536:	8d 42 01             	lea    0x1(%edx),%eax
  801539:	89 03                	mov    %eax,(%ebx)
  80153b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80153e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801542:	3d ff 00 00 00       	cmp    $0xff,%eax
  801547:	75 1a                	jne    801563 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801549:	83 ec 08             	sub    $0x8,%esp
  80154c:	68 ff 00 00 00       	push   $0xff
  801551:	8d 43 08             	lea    0x8(%ebx),%eax
  801554:	50                   	push   %eax
  801555:	e8 4d eb ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  80155a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801560:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  801563:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  801567:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80156a:	c9                   	leave  
  80156b:	c3                   	ret    

0080156c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80156c:	55                   	push   %ebp
  80156d:	89 e5                	mov    %esp,%ebp
  80156f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  801575:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80157c:	00 00 00 
	b.cnt = 0;
  80157f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801586:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801589:	ff 75 0c             	pushl  0xc(%ebp)
  80158c:	ff 75 08             	pushl  0x8(%ebp)
  80158f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801595:	50                   	push   %eax
  801596:	68 2a 15 80 00       	push   $0x80152a
  80159b:	e8 1a 01 00 00       	call   8016ba <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8015a0:	83 c4 08             	add    $0x8,%esp
  8015a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8015a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8015af:	50                   	push   %eax
  8015b0:	e8 f2 ea ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  8015b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8015bb:	c9                   	leave  
  8015bc:	c3                   	ret    

008015bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8015bd:	55                   	push   %ebp
  8015be:	89 e5                	mov    %esp,%ebp
  8015c0:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8015c3:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8015c6:	50                   	push   %eax
  8015c7:	ff 75 08             	pushl  0x8(%ebp)
  8015ca:	e8 9d ff ff ff       	call   80156c <vcprintf>
	va_end(ap);

	return cnt;
}
  8015cf:	c9                   	leave  
  8015d0:	c3                   	ret    

008015d1 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8015d1:	55                   	push   %ebp
  8015d2:	89 e5                	mov    %esp,%ebp
  8015d4:	57                   	push   %edi
  8015d5:	56                   	push   %esi
  8015d6:	53                   	push   %ebx
  8015d7:	83 ec 1c             	sub    $0x1c,%esp
  8015da:	89 c7                	mov    %eax,%edi
  8015dc:	89 d6                	mov    %edx,%esi
  8015de:	8b 45 08             	mov    0x8(%ebp),%eax
  8015e1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8015e4:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e7:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8015ea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8015ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015f2:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8015f5:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  8015f8:	39 d3                	cmp    %edx,%ebx
  8015fa:	72 05                	jb     801601 <printnum+0x30>
  8015fc:	39 45 10             	cmp    %eax,0x10(%ebp)
  8015ff:	77 45                	ja     801646 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	ff 75 18             	pushl  0x18(%ebp)
  801607:	8b 45 14             	mov    0x14(%ebp),%eax
  80160a:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80160d:	53                   	push   %ebx
  80160e:	ff 75 10             	pushl  0x10(%ebp)
  801611:	83 ec 08             	sub    $0x8,%esp
  801614:	ff 75 e4             	pushl  -0x1c(%ebp)
  801617:	ff 75 e0             	pushl  -0x20(%ebp)
  80161a:	ff 75 dc             	pushl  -0x24(%ebp)
  80161d:	ff 75 d8             	pushl  -0x28(%ebp)
  801620:	e8 1b 0a 00 00       	call   802040 <__udivdi3>
  801625:	83 c4 18             	add    $0x18,%esp
  801628:	52                   	push   %edx
  801629:	50                   	push   %eax
  80162a:	89 f2                	mov    %esi,%edx
  80162c:	89 f8                	mov    %edi,%eax
  80162e:	e8 9e ff ff ff       	call   8015d1 <printnum>
  801633:	83 c4 20             	add    $0x20,%esp
  801636:	eb 18                	jmp    801650 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801638:	83 ec 08             	sub    $0x8,%esp
  80163b:	56                   	push   %esi
  80163c:	ff 75 18             	pushl  0x18(%ebp)
  80163f:	ff d7                	call   *%edi
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 03                	jmp    801649 <printnum+0x78>
  801646:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801649:	83 eb 01             	sub    $0x1,%ebx
  80164c:	85 db                	test   %ebx,%ebx
  80164e:	7f e8                	jg     801638 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  801650:	83 ec 08             	sub    $0x8,%esp
  801653:	56                   	push   %esi
  801654:	83 ec 04             	sub    $0x4,%esp
  801657:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165a:	ff 75 e0             	pushl  -0x20(%ebp)
  80165d:	ff 75 dc             	pushl  -0x24(%ebp)
  801660:	ff 75 d8             	pushl  -0x28(%ebp)
  801663:	e8 08 0b 00 00       	call   802170 <__umoddi3>
  801668:	83 c4 14             	add    $0x14,%esp
  80166b:	0f be 80 63 24 80 00 	movsbl 0x802463(%eax),%eax
  801672:	50                   	push   %eax
  801673:	ff d7                	call   *%edi
}
  801675:	83 c4 10             	add    $0x10,%esp
  801678:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80167b:	5b                   	pop    %ebx
  80167c:	5e                   	pop    %esi
  80167d:	5f                   	pop    %edi
  80167e:	5d                   	pop    %ebp
  80167f:	c3                   	ret    

00801680 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801680:	55                   	push   %ebp
  801681:	89 e5                	mov    %esp,%ebp
  801683:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801686:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80168a:	8b 10                	mov    (%eax),%edx
  80168c:	3b 50 04             	cmp    0x4(%eax),%edx
  80168f:	73 0a                	jae    80169b <sprintputch+0x1b>
		*b->buf++ = ch;
  801691:	8d 4a 01             	lea    0x1(%edx),%ecx
  801694:	89 08                	mov    %ecx,(%eax)
  801696:	8b 45 08             	mov    0x8(%ebp),%eax
  801699:	88 02                	mov    %al,(%edx)
}
  80169b:	5d                   	pop    %ebp
  80169c:	c3                   	ret    

0080169d <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8016a3:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8016a6:	50                   	push   %eax
  8016a7:	ff 75 10             	pushl  0x10(%ebp)
  8016aa:	ff 75 0c             	pushl  0xc(%ebp)
  8016ad:	ff 75 08             	pushl  0x8(%ebp)
  8016b0:	e8 05 00 00 00       	call   8016ba <vprintfmt>
	va_end(ap);
}
  8016b5:	83 c4 10             	add    $0x10,%esp
  8016b8:	c9                   	leave  
  8016b9:	c3                   	ret    

008016ba <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	57                   	push   %edi
  8016be:	56                   	push   %esi
  8016bf:	53                   	push   %ebx
  8016c0:	83 ec 2c             	sub    $0x2c,%esp
  8016c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8016c6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8016c9:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016cc:	eb 12                	jmp    8016e0 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8016ce:	85 c0                	test   %eax,%eax
  8016d0:	0f 84 42 04 00 00    	je     801b18 <vprintfmt+0x45e>
				return;
			putch(ch, putdat);
  8016d6:	83 ec 08             	sub    $0x8,%esp
  8016d9:	53                   	push   %ebx
  8016da:	50                   	push   %eax
  8016db:	ff d6                	call   *%esi
  8016dd:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8016e0:	83 c7 01             	add    $0x1,%edi
  8016e3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8016e7:	83 f8 25             	cmp    $0x25,%eax
  8016ea:	75 e2                	jne    8016ce <vprintfmt+0x14>
  8016ec:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  8016f0:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8016f7:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8016fe:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801705:	b9 00 00 00 00       	mov    $0x0,%ecx
  80170a:	eb 07                	jmp    801713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80170c:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80170f:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801713:	8d 47 01             	lea    0x1(%edi),%eax
  801716:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801719:	0f b6 07             	movzbl (%edi),%eax
  80171c:	0f b6 d0             	movzbl %al,%edx
  80171f:	83 e8 23             	sub    $0x23,%eax
  801722:	3c 55                	cmp    $0x55,%al
  801724:	0f 87 d3 03 00 00    	ja     801afd <vprintfmt+0x443>
  80172a:	0f b6 c0             	movzbl %al,%eax
  80172d:	ff 24 85 a0 25 80 00 	jmp    *0x8025a0(,%eax,4)
  801734:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  801737:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  80173b:	eb d6                	jmp    801713 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80173d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801740:	b8 00 00 00 00       	mov    $0x0,%eax
  801745:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  801748:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80174b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80174f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801752:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801755:	83 f9 09             	cmp    $0x9,%ecx
  801758:	77 3f                	ja     801799 <vprintfmt+0xdf>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80175a:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80175d:	eb e9                	jmp    801748 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80175f:	8b 45 14             	mov    0x14(%ebp),%eax
  801762:	8b 00                	mov    (%eax),%eax
  801764:	89 45 d0             	mov    %eax,-0x30(%ebp)
  801767:	8b 45 14             	mov    0x14(%ebp),%eax
  80176a:	8d 40 04             	lea    0x4(%eax),%eax
  80176d:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801770:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801773:	eb 2a                	jmp    80179f <vprintfmt+0xe5>
  801775:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801778:	85 c0                	test   %eax,%eax
  80177a:	ba 00 00 00 00       	mov    $0x0,%edx
  80177f:	0f 49 d0             	cmovns %eax,%edx
  801782:	89 55 e0             	mov    %edx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801785:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801788:	eb 89                	jmp    801713 <vprintfmt+0x59>
  80178a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80178d:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801794:	e9 7a ff ff ff       	jmp    801713 <vprintfmt+0x59>
  801799:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80179c:	89 45 d0             	mov    %eax,-0x30(%ebp)

		process_precision:
			if (width < 0)
  80179f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8017a3:	0f 89 6a ff ff ff    	jns    801713 <vprintfmt+0x59>
				width = precision, precision = -1;
  8017a9:	8b 45 d0             	mov    -0x30(%ebp),%eax
  8017ac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8017af:	c7 45 d0 ff ff ff ff 	movl   $0xffffffff,-0x30(%ebp)
  8017b6:	e9 58 ff ff ff       	jmp    801713 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8017bb:	83 c1 01             	add    $0x1,%ecx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  8017c1:	e9 4d ff ff ff       	jmp    801713 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8017c9:	8d 78 04             	lea    0x4(%eax),%edi
  8017cc:	83 ec 08             	sub    $0x8,%esp
  8017cf:	53                   	push   %ebx
  8017d0:	ff 30                	pushl  (%eax)
  8017d2:	ff d6                	call   *%esi
			break;
  8017d4:	83 c4 10             	add    $0x10,%esp
			lflag++;
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8017d7:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8017da:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  8017dd:	e9 fe fe ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  8017e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8017e5:	8d 78 04             	lea    0x4(%eax),%edi
  8017e8:	8b 00                	mov    (%eax),%eax
  8017ea:	99                   	cltd   
  8017eb:	31 d0                	xor    %edx,%eax
  8017ed:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8017ef:	83 f8 0f             	cmp    $0xf,%eax
  8017f2:	7f 0b                	jg     8017ff <vprintfmt+0x145>
  8017f4:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  8017fb:	85 d2                	test   %edx,%edx
  8017fd:	75 1b                	jne    80181a <vprintfmt+0x160>
				printfmt(putch, putdat, "error %d", err);
  8017ff:	50                   	push   %eax
  801800:	68 7b 24 80 00       	push   $0x80247b
  801805:	53                   	push   %ebx
  801806:	56                   	push   %esi
  801807:	e8 91 fe ff ff       	call   80169d <printfmt>
  80180c:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80180f:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801812:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801815:	e9 c6 fe ff ff       	jmp    8016e0 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80181a:	52                   	push   %edx
  80181b:	68 c1 23 80 00       	push   $0x8023c1
  801820:	53                   	push   %ebx
  801821:	56                   	push   %esi
  801822:	e8 76 fe ff ff       	call   80169d <printfmt>
  801827:	83 c4 10             	add    $0x10,%esp
			putch(va_arg(ap, int), putdat);
			break;

		// error message
		case 'e':
			err = va_arg(ap, int);
  80182a:	89 7d 14             	mov    %edi,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80182d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801830:	e9 ab fe ff ff       	jmp    8016e0 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801835:	8b 45 14             	mov    0x14(%ebp),%eax
  801838:	83 c0 04             	add    $0x4,%eax
  80183b:	89 45 cc             	mov    %eax,-0x34(%ebp)
  80183e:	8b 45 14             	mov    0x14(%ebp),%eax
  801841:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  801843:	85 ff                	test   %edi,%edi
  801845:	b8 74 24 80 00       	mov    $0x802474,%eax
  80184a:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  80184d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801851:	0f 8e 94 00 00 00    	jle    8018eb <vprintfmt+0x231>
  801857:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  80185b:	0f 84 98 00 00 00    	je     8018f9 <vprintfmt+0x23f>
				for (width -= strnlen(p, precision); width > 0; width--)
  801861:	83 ec 08             	sub    $0x8,%esp
  801864:	ff 75 d0             	pushl  -0x30(%ebp)
  801867:	57                   	push   %edi
  801868:	e8 33 03 00 00       	call   801ba0 <strnlen>
  80186d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801870:	29 c1                	sub    %eax,%ecx
  801872:	89 4d c8             	mov    %ecx,-0x38(%ebp)
  801875:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801878:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80187c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80187f:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801882:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801884:	eb 0f                	jmp    801895 <vprintfmt+0x1db>
					putch(padc, putdat);
  801886:	83 ec 08             	sub    $0x8,%esp
  801889:	53                   	push   %ebx
  80188a:	ff 75 e0             	pushl  -0x20(%ebp)
  80188d:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80188f:	83 ef 01             	sub    $0x1,%edi
  801892:	83 c4 10             	add    $0x10,%esp
  801895:	85 ff                	test   %edi,%edi
  801897:	7f ed                	jg     801886 <vprintfmt+0x1cc>
  801899:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80189c:	8b 4d c8             	mov    -0x38(%ebp),%ecx
  80189f:	85 c9                	test   %ecx,%ecx
  8018a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8018a6:	0f 49 c1             	cmovns %ecx,%eax
  8018a9:	29 c1                	sub    %eax,%ecx
  8018ab:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ae:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018b1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018b4:	89 cb                	mov    %ecx,%ebx
  8018b6:	eb 4d                	jmp    801905 <vprintfmt+0x24b>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8018b8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8018bc:	74 1b                	je     8018d9 <vprintfmt+0x21f>
  8018be:	0f be c0             	movsbl %al,%eax
  8018c1:	83 e8 20             	sub    $0x20,%eax
  8018c4:	83 f8 5e             	cmp    $0x5e,%eax
  8018c7:	76 10                	jbe    8018d9 <vprintfmt+0x21f>
					putch('?', putdat);
  8018c9:	83 ec 08             	sub    $0x8,%esp
  8018cc:	ff 75 0c             	pushl  0xc(%ebp)
  8018cf:	6a 3f                	push   $0x3f
  8018d1:	ff 55 08             	call   *0x8(%ebp)
  8018d4:	83 c4 10             	add    $0x10,%esp
  8018d7:	eb 0d                	jmp    8018e6 <vprintfmt+0x22c>
				else
					putch(ch, putdat);
  8018d9:	83 ec 08             	sub    $0x8,%esp
  8018dc:	ff 75 0c             	pushl  0xc(%ebp)
  8018df:	52                   	push   %edx
  8018e0:	ff 55 08             	call   *0x8(%ebp)
  8018e3:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8018e6:	83 eb 01             	sub    $0x1,%ebx
  8018e9:	eb 1a                	jmp    801905 <vprintfmt+0x24b>
  8018eb:	89 75 08             	mov    %esi,0x8(%ebp)
  8018ee:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018f1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8018f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8018f7:	eb 0c                	jmp    801905 <vprintfmt+0x24b>
  8018f9:	89 75 08             	mov    %esi,0x8(%ebp)
  8018fc:	8b 75 d0             	mov    -0x30(%ebp),%esi
  8018ff:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801902:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801905:	83 c7 01             	add    $0x1,%edi
  801908:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80190c:	0f be d0             	movsbl %al,%edx
  80190f:	85 d2                	test   %edx,%edx
  801911:	74 23                	je     801936 <vprintfmt+0x27c>
  801913:	85 f6                	test   %esi,%esi
  801915:	78 a1                	js     8018b8 <vprintfmt+0x1fe>
  801917:	83 ee 01             	sub    $0x1,%esi
  80191a:	79 9c                	jns    8018b8 <vprintfmt+0x1fe>
  80191c:	89 df                	mov    %ebx,%edi
  80191e:	8b 75 08             	mov    0x8(%ebp),%esi
  801921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801924:	eb 18                	jmp    80193e <vprintfmt+0x284>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	53                   	push   %ebx
  80192a:	6a 20                	push   $0x20
  80192c:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80192e:	83 ef 01             	sub    $0x1,%edi
  801931:	83 c4 10             	add    $0x10,%esp
  801934:	eb 08                	jmp    80193e <vprintfmt+0x284>
  801936:	89 df                	mov    %ebx,%edi
  801938:	8b 75 08             	mov    0x8(%ebp),%esi
  80193b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80193e:	85 ff                	test   %edi,%edi
  801940:	7f e4                	jg     801926 <vprintfmt+0x26c>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  801942:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801945:	89 45 14             	mov    %eax,0x14(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801948:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80194b:	e9 90 fd ff ff       	jmp    8016e0 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801950:	83 f9 01             	cmp    $0x1,%ecx
  801953:	7e 19                	jle    80196e <vprintfmt+0x2b4>
		return va_arg(*ap, long long);
  801955:	8b 45 14             	mov    0x14(%ebp),%eax
  801958:	8b 50 04             	mov    0x4(%eax),%edx
  80195b:	8b 00                	mov    (%eax),%eax
  80195d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801960:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801963:	8b 45 14             	mov    0x14(%ebp),%eax
  801966:	8d 40 08             	lea    0x8(%eax),%eax
  801969:	89 45 14             	mov    %eax,0x14(%ebp)
  80196c:	eb 38                	jmp    8019a6 <vprintfmt+0x2ec>
	else if (lflag)
  80196e:	85 c9                	test   %ecx,%ecx
  801970:	74 1b                	je     80198d <vprintfmt+0x2d3>
		return va_arg(*ap, long);
  801972:	8b 45 14             	mov    0x14(%ebp),%eax
  801975:	8b 00                	mov    (%eax),%eax
  801977:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80197a:	89 c1                	mov    %eax,%ecx
  80197c:	c1 f9 1f             	sar    $0x1f,%ecx
  80197f:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801982:	8b 45 14             	mov    0x14(%ebp),%eax
  801985:	8d 40 04             	lea    0x4(%eax),%eax
  801988:	89 45 14             	mov    %eax,0x14(%ebp)
  80198b:	eb 19                	jmp    8019a6 <vprintfmt+0x2ec>
	else
		return va_arg(*ap, int);
  80198d:	8b 45 14             	mov    0x14(%ebp),%eax
  801990:	8b 00                	mov    (%eax),%eax
  801992:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801995:	89 c1                	mov    %eax,%ecx
  801997:	c1 f9 1f             	sar    $0x1f,%ecx
  80199a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80199d:	8b 45 14             	mov    0x14(%ebp),%eax
  8019a0:	8d 40 04             	lea    0x4(%eax),%eax
  8019a3:	89 45 14             	mov    %eax,0x14(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8019a6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019a9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8019ac:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8019b1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8019b5:	0f 89 0e 01 00 00    	jns    801ac9 <vprintfmt+0x40f>
				putch('-', putdat);
  8019bb:	83 ec 08             	sub    $0x8,%esp
  8019be:	53                   	push   %ebx
  8019bf:	6a 2d                	push   $0x2d
  8019c1:	ff d6                	call   *%esi
				num = -(long long) num;
  8019c3:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8019c6:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019c9:	f7 da                	neg    %edx
  8019cb:	83 d1 00             	adc    $0x0,%ecx
  8019ce:	f7 d9                	neg    %ecx
  8019d0:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  8019d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019d8:	e9 ec 00 00 00       	jmp    801ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8019dd:	83 f9 01             	cmp    $0x1,%ecx
  8019e0:	7e 18                	jle    8019fa <vprintfmt+0x340>
		return va_arg(*ap, unsigned long long);
  8019e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8019e5:	8b 10                	mov    (%eax),%edx
  8019e7:	8b 48 04             	mov    0x4(%eax),%ecx
  8019ea:	8d 40 08             	lea    0x8(%eax),%eax
  8019ed:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  8019f0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8019f5:	e9 cf 00 00 00       	jmp    801ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8019fa:	85 c9                	test   %ecx,%ecx
  8019fc:	74 1a                	je     801a18 <vprintfmt+0x35e>
		return va_arg(*ap, unsigned long);
  8019fe:	8b 45 14             	mov    0x14(%ebp),%eax
  801a01:	8b 10                	mov    (%eax),%edx
  801a03:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a08:	8d 40 04             	lea    0x4(%eax),%eax
  801a0b:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a13:	e9 b1 00 00 00       	jmp    801ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801a18:	8b 45 14             	mov    0x14(%ebp),%eax
  801a1b:	8b 10                	mov    (%eax),%edx
  801a1d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801a22:	8d 40 04             	lea    0x4(%eax),%eax
  801a25:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
			base = 10;
  801a28:	b8 0a 00 00 00       	mov    $0xa,%eax
  801a2d:	e9 97 00 00 00       	jmp    801ac9 <vprintfmt+0x40f>
			goto number;

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	53                   	push   %ebx
  801a36:	6a 58                	push   $0x58
  801a38:	ff d6                	call   *%esi
			putch('X', putdat);
  801a3a:	83 c4 08             	add    $0x8,%esp
  801a3d:	53                   	push   %ebx
  801a3e:	6a 58                	push   $0x58
  801a40:	ff d6                	call   *%esi
			putch('X', putdat);
  801a42:	83 c4 08             	add    $0x8,%esp
  801a45:	53                   	push   %ebx
  801a46:	6a 58                	push   $0x58
  801a48:	ff d6                	call   *%esi
			break;
  801a4a:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801a4d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			break;
  801a50:	e9 8b fc ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// pointer
		case 'p':
			putch('0', putdat);
  801a55:	83 ec 08             	sub    $0x8,%esp
  801a58:	53                   	push   %ebx
  801a59:	6a 30                	push   $0x30
  801a5b:	ff d6                	call   *%esi
			putch('x', putdat);
  801a5d:	83 c4 08             	add    $0x8,%esp
  801a60:	53                   	push   %ebx
  801a61:	6a 78                	push   $0x78
  801a63:	ff d6                	call   *%esi
			num = (unsigned long long)
  801a65:	8b 45 14             	mov    0x14(%ebp),%eax
  801a68:	8b 10                	mov    (%eax),%edx
  801a6a:	b9 00 00 00 00       	mov    $0x0,%ecx
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  801a6f:	83 c4 10             	add    $0x10,%esp
		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  801a72:	8d 40 04             	lea    0x4(%eax),%eax
  801a75:	89 45 14             	mov    %eax,0x14(%ebp)
			base = 16;
  801a78:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801a7d:	eb 4a                	jmp    801ac9 <vprintfmt+0x40f>
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801a7f:	83 f9 01             	cmp    $0x1,%ecx
  801a82:	7e 15                	jle    801a99 <vprintfmt+0x3df>
		return va_arg(*ap, unsigned long long);
  801a84:	8b 45 14             	mov    0x14(%ebp),%eax
  801a87:	8b 10                	mov    (%eax),%edx
  801a89:	8b 48 04             	mov    0x4(%eax),%ecx
  801a8c:	8d 40 08             	lea    0x8(%eax),%eax
  801a8f:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801a92:	b8 10 00 00 00       	mov    $0x10,%eax
  801a97:	eb 30                	jmp    801ac9 <vprintfmt+0x40f>
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801a99:	85 c9                	test   %ecx,%ecx
  801a9b:	74 17                	je     801ab4 <vprintfmt+0x3fa>
		return va_arg(*ap, unsigned long);
  801a9d:	8b 45 14             	mov    0x14(%ebp),%eax
  801aa0:	8b 10                	mov    (%eax),%edx
  801aa2:	b9 00 00 00 00       	mov    $0x0,%ecx
  801aa7:	8d 40 04             	lea    0x4(%eax),%eax
  801aaa:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801aad:	b8 10 00 00 00       	mov    $0x10,%eax
  801ab2:	eb 15                	jmp    801ac9 <vprintfmt+0x40f>
	if (lflag >= 2)
		return va_arg(*ap, unsigned long long);
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
  801ab4:	8b 45 14             	mov    0x14(%ebp),%eax
  801ab7:	8b 10                	mov    (%eax),%edx
  801ab9:	b9 00 00 00 00       	mov    $0x0,%ecx
  801abe:	8d 40 04             	lea    0x4(%eax),%eax
  801ac1:	89 45 14             	mov    %eax,0x14(%ebp)
			goto number;

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
			base = 16;
  801ac4:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801ac9:	83 ec 0c             	sub    $0xc,%esp
  801acc:	0f be 7d d4          	movsbl -0x2c(%ebp),%edi
  801ad0:	57                   	push   %edi
  801ad1:	ff 75 e0             	pushl  -0x20(%ebp)
  801ad4:	50                   	push   %eax
  801ad5:	51                   	push   %ecx
  801ad6:	52                   	push   %edx
  801ad7:	89 da                	mov    %ebx,%edx
  801ad9:	89 f0                	mov    %esi,%eax
  801adb:	e8 f1 fa ff ff       	call   8015d1 <printnum>
			break;
  801ae0:	83 c4 20             	add    $0x20,%esp
  801ae3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801ae6:	e9 f5 fb ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801aeb:	83 ec 08             	sub    $0x8,%esp
  801aee:	53                   	push   %ebx
  801aef:	52                   	push   %edx
  801af0:	ff d6                	call   *%esi
			break;
  801af2:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801af5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801af8:	e9 e3 fb ff ff       	jmp    8016e0 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801afd:	83 ec 08             	sub    $0x8,%esp
  801b00:	53                   	push   %ebx
  801b01:	6a 25                	push   $0x25
  801b03:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	eb 03                	jmp    801b0d <vprintfmt+0x453>
  801b0a:	83 ef 01             	sub    $0x1,%edi
  801b0d:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801b11:	75 f7                	jne    801b0a <vprintfmt+0x450>
  801b13:	e9 c8 fb ff ff       	jmp    8016e0 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801b18:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1b:	5b                   	pop    %ebx
  801b1c:	5e                   	pop    %esi
  801b1d:	5f                   	pop    %edi
  801b1e:	5d                   	pop    %ebp
  801b1f:	c3                   	ret    

00801b20 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801b20:	55                   	push   %ebp
  801b21:	89 e5                	mov    %esp,%ebp
  801b23:	83 ec 18             	sub    $0x18,%esp
  801b26:	8b 45 08             	mov    0x8(%ebp),%eax
  801b29:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801b2c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801b2f:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801b33:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801b36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801b3d:	85 c0                	test   %eax,%eax
  801b3f:	74 26                	je     801b67 <vsnprintf+0x47>
  801b41:	85 d2                	test   %edx,%edx
  801b43:	7e 22                	jle    801b67 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801b45:	ff 75 14             	pushl  0x14(%ebp)
  801b48:	ff 75 10             	pushl  0x10(%ebp)
  801b4b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801b4e:	50                   	push   %eax
  801b4f:	68 80 16 80 00       	push   $0x801680
  801b54:	e8 61 fb ff ff       	call   8016ba <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801b59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801b5c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b62:	83 c4 10             	add    $0x10,%esp
  801b65:	eb 05                	jmp    801b6c <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801b67:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801b6c:	c9                   	leave  
  801b6d:	c3                   	ret    

00801b6e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801b6e:	55                   	push   %ebp
  801b6f:	89 e5                	mov    %esp,%ebp
  801b71:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801b74:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801b77:	50                   	push   %eax
  801b78:	ff 75 10             	pushl  0x10(%ebp)
  801b7b:	ff 75 0c             	pushl  0xc(%ebp)
  801b7e:	ff 75 08             	pushl  0x8(%ebp)
  801b81:	e8 9a ff ff ff       	call   801b20 <vsnprintf>
	va_end(ap);

	return rc;
}
  801b86:	c9                   	leave  
  801b87:	c3                   	ret    

00801b88 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801b88:	55                   	push   %ebp
  801b89:	89 e5                	mov    %esp,%ebp
  801b8b:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801b8e:	b8 00 00 00 00       	mov    $0x0,%eax
  801b93:	eb 03                	jmp    801b98 <strlen+0x10>
		n++;
  801b95:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  801b98:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801b9c:	75 f7                	jne    801b95 <strlen+0xd>
		n++;
	return n;
}
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801ba0:	55                   	push   %ebp
  801ba1:	89 e5                	mov    %esp,%ebp
  801ba3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801ba9:	ba 00 00 00 00       	mov    $0x0,%edx
  801bae:	eb 03                	jmp    801bb3 <strnlen+0x13>
		n++;
  801bb0:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801bb3:	39 c2                	cmp    %eax,%edx
  801bb5:	74 08                	je     801bbf <strnlen+0x1f>
  801bb7:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  801bbb:	75 f3                	jne    801bb0 <strnlen+0x10>
  801bbd:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  801bbf:	5d                   	pop    %ebp
  801bc0:	c3                   	ret    

00801bc1 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801bc1:	55                   	push   %ebp
  801bc2:	89 e5                	mov    %esp,%ebp
  801bc4:	53                   	push   %ebx
  801bc5:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801bcb:	89 c2                	mov    %eax,%edx
  801bcd:	83 c2 01             	add    $0x1,%edx
  801bd0:	83 c1 01             	add    $0x1,%ecx
  801bd3:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801bd7:	88 5a ff             	mov    %bl,-0x1(%edx)
  801bda:	84 db                	test   %bl,%bl
  801bdc:	75 ef                	jne    801bcd <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801bde:	5b                   	pop    %ebx
  801bdf:	5d                   	pop    %ebp
  801be0:	c3                   	ret    

00801be1 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801be1:	55                   	push   %ebp
  801be2:	89 e5                	mov    %esp,%ebp
  801be4:	53                   	push   %ebx
  801be5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801be8:	53                   	push   %ebx
  801be9:	e8 9a ff ff ff       	call   801b88 <strlen>
  801bee:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801bf1:	ff 75 0c             	pushl  0xc(%ebp)
  801bf4:	01 d8                	add    %ebx,%eax
  801bf6:	50                   	push   %eax
  801bf7:	e8 c5 ff ff ff       	call   801bc1 <strcpy>
	return dst;
}
  801bfc:	89 d8                	mov    %ebx,%eax
  801bfe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c01:	c9                   	leave  
  801c02:	c3                   	ret    

00801c03 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801c03:	55                   	push   %ebp
  801c04:	89 e5                	mov    %esp,%ebp
  801c06:	56                   	push   %esi
  801c07:	53                   	push   %ebx
  801c08:	8b 75 08             	mov    0x8(%ebp),%esi
  801c0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c0e:	89 f3                	mov    %esi,%ebx
  801c10:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c13:	89 f2                	mov    %esi,%edx
  801c15:	eb 0f                	jmp    801c26 <strncpy+0x23>
		*dst++ = *src;
  801c17:	83 c2 01             	add    $0x1,%edx
  801c1a:	0f b6 01             	movzbl (%ecx),%eax
  801c1d:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801c20:	80 39 01             	cmpb   $0x1,(%ecx)
  801c23:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801c26:	39 da                	cmp    %ebx,%edx
  801c28:	75 ed                	jne    801c17 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801c2a:	89 f0                	mov    %esi,%eax
  801c2c:	5b                   	pop    %ebx
  801c2d:	5e                   	pop    %esi
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801c30:	55                   	push   %ebp
  801c31:	89 e5                	mov    %esp,%ebp
  801c33:	56                   	push   %esi
  801c34:	53                   	push   %ebx
  801c35:	8b 75 08             	mov    0x8(%ebp),%esi
  801c38:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c3b:	8b 55 10             	mov    0x10(%ebp),%edx
  801c3e:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801c40:	85 d2                	test   %edx,%edx
  801c42:	74 21                	je     801c65 <strlcpy+0x35>
  801c44:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801c48:	89 f2                	mov    %esi,%edx
  801c4a:	eb 09                	jmp    801c55 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801c4c:	83 c2 01             	add    $0x1,%edx
  801c4f:	83 c1 01             	add    $0x1,%ecx
  801c52:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801c55:	39 c2                	cmp    %eax,%edx
  801c57:	74 09                	je     801c62 <strlcpy+0x32>
  801c59:	0f b6 19             	movzbl (%ecx),%ebx
  801c5c:	84 db                	test   %bl,%bl
  801c5e:	75 ec                	jne    801c4c <strlcpy+0x1c>
  801c60:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801c62:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801c65:	29 f0                	sub    %esi,%eax
}
  801c67:	5b                   	pop    %ebx
  801c68:	5e                   	pop    %esi
  801c69:	5d                   	pop    %ebp
  801c6a:	c3                   	ret    

00801c6b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801c6b:	55                   	push   %ebp
  801c6c:	89 e5                	mov    %esp,%ebp
  801c6e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c71:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801c74:	eb 06                	jmp    801c7c <strcmp+0x11>
		p++, q++;
  801c76:	83 c1 01             	add    $0x1,%ecx
  801c79:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801c7c:	0f b6 01             	movzbl (%ecx),%eax
  801c7f:	84 c0                	test   %al,%al
  801c81:	74 04                	je     801c87 <strcmp+0x1c>
  801c83:	3a 02                	cmp    (%edx),%al
  801c85:	74 ef                	je     801c76 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801c87:	0f b6 c0             	movzbl %al,%eax
  801c8a:	0f b6 12             	movzbl (%edx),%edx
  801c8d:	29 d0                	sub    %edx,%eax
}
  801c8f:	5d                   	pop    %ebp
  801c90:	c3                   	ret    

00801c91 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	53                   	push   %ebx
  801c95:	8b 45 08             	mov    0x8(%ebp),%eax
  801c98:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c9b:	89 c3                	mov    %eax,%ebx
  801c9d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801ca0:	eb 06                	jmp    801ca8 <strncmp+0x17>
		n--, p++, q++;
  801ca2:	83 c0 01             	add    $0x1,%eax
  801ca5:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  801ca8:	39 d8                	cmp    %ebx,%eax
  801caa:	74 15                	je     801cc1 <strncmp+0x30>
  801cac:	0f b6 08             	movzbl (%eax),%ecx
  801caf:	84 c9                	test   %cl,%cl
  801cb1:	74 04                	je     801cb7 <strncmp+0x26>
  801cb3:	3a 0a                	cmp    (%edx),%cl
  801cb5:	74 eb                	je     801ca2 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  801cb7:	0f b6 00             	movzbl (%eax),%eax
  801cba:	0f b6 12             	movzbl (%edx),%edx
  801cbd:	29 d0                	sub    %edx,%eax
  801cbf:	eb 05                	jmp    801cc6 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  801cc1:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801cc6:	5b                   	pop    %ebx
  801cc7:	5d                   	pop    %ebp
  801cc8:	c3                   	ret    

00801cc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	8b 45 08             	mov    0x8(%ebp),%eax
  801ccf:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cd3:	eb 07                	jmp    801cdc <strchr+0x13>
		if (*s == c)
  801cd5:	38 ca                	cmp    %cl,%dl
  801cd7:	74 0f                	je     801ce8 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801cd9:	83 c0 01             	add    $0x1,%eax
  801cdc:	0f b6 10             	movzbl (%eax),%edx
  801cdf:	84 d2                	test   %dl,%dl
  801ce1:	75 f2                	jne    801cd5 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801ce3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    

00801cea <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801cea:	55                   	push   %ebp
  801ceb:	89 e5                	mov    %esp,%ebp
  801ced:	8b 45 08             	mov    0x8(%ebp),%eax
  801cf0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801cf4:	eb 03                	jmp    801cf9 <strfind+0xf>
  801cf6:	83 c0 01             	add    $0x1,%eax
  801cf9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801cfc:	38 ca                	cmp    %cl,%dl
  801cfe:	74 04                	je     801d04 <strfind+0x1a>
  801d00:	84 d2                	test   %dl,%dl
  801d02:	75 f2                	jne    801cf6 <strfind+0xc>
			break;
	return (char *) s;
}
  801d04:	5d                   	pop    %ebp
  801d05:	c3                   	ret    

00801d06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801d06:	55                   	push   %ebp
  801d07:	89 e5                	mov    %esp,%ebp
  801d09:	57                   	push   %edi
  801d0a:	56                   	push   %esi
  801d0b:	53                   	push   %ebx
  801d0c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801d12:	85 c9                	test   %ecx,%ecx
  801d14:	74 36                	je     801d4c <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801d16:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801d1c:	75 28                	jne    801d46 <memset+0x40>
  801d1e:	f6 c1 03             	test   $0x3,%cl
  801d21:	75 23                	jne    801d46 <memset+0x40>
		c &= 0xFF;
  801d23:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801d27:	89 d3                	mov    %edx,%ebx
  801d29:	c1 e3 08             	shl    $0x8,%ebx
  801d2c:	89 d6                	mov    %edx,%esi
  801d2e:	c1 e6 18             	shl    $0x18,%esi
  801d31:	89 d0                	mov    %edx,%eax
  801d33:	c1 e0 10             	shl    $0x10,%eax
  801d36:	09 f0                	or     %esi,%eax
  801d38:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801d3a:	89 d8                	mov    %ebx,%eax
  801d3c:	09 d0                	or     %edx,%eax
  801d3e:	c1 e9 02             	shr    $0x2,%ecx
  801d41:	fc                   	cld    
  801d42:	f3 ab                	rep stos %eax,%es:(%edi)
  801d44:	eb 06                	jmp    801d4c <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801d46:	8b 45 0c             	mov    0xc(%ebp),%eax
  801d49:	fc                   	cld    
  801d4a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801d4c:	89 f8                	mov    %edi,%eax
  801d4e:	5b                   	pop    %ebx
  801d4f:	5e                   	pop    %esi
  801d50:	5f                   	pop    %edi
  801d51:	5d                   	pop    %ebp
  801d52:	c3                   	ret    

00801d53 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801d53:	55                   	push   %ebp
  801d54:	89 e5                	mov    %esp,%ebp
  801d56:	57                   	push   %edi
  801d57:	56                   	push   %esi
  801d58:	8b 45 08             	mov    0x8(%ebp),%eax
  801d5b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d5e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801d61:	39 c6                	cmp    %eax,%esi
  801d63:	73 35                	jae    801d9a <memmove+0x47>
  801d65:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801d68:	39 d0                	cmp    %edx,%eax
  801d6a:	73 2e                	jae    801d9a <memmove+0x47>
		s += n;
		d += n;
  801d6c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d6f:	89 d6                	mov    %edx,%esi
  801d71:	09 fe                	or     %edi,%esi
  801d73:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801d79:	75 13                	jne    801d8e <memmove+0x3b>
  801d7b:	f6 c1 03             	test   $0x3,%cl
  801d7e:	75 0e                	jne    801d8e <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801d80:	83 ef 04             	sub    $0x4,%edi
  801d83:	8d 72 fc             	lea    -0x4(%edx),%esi
  801d86:	c1 e9 02             	shr    $0x2,%ecx
  801d89:	fd                   	std    
  801d8a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801d8c:	eb 09                	jmp    801d97 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  801d8e:	83 ef 01             	sub    $0x1,%edi
  801d91:	8d 72 ff             	lea    -0x1(%edx),%esi
  801d94:	fd                   	std    
  801d95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801d97:	fc                   	cld    
  801d98:	eb 1d                	jmp    801db7 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801d9a:	89 f2                	mov    %esi,%edx
  801d9c:	09 c2                	or     %eax,%edx
  801d9e:	f6 c2 03             	test   $0x3,%dl
  801da1:	75 0f                	jne    801db2 <memmove+0x5f>
  801da3:	f6 c1 03             	test   $0x3,%cl
  801da6:	75 0a                	jne    801db2 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  801da8:	c1 e9 02             	shr    $0x2,%ecx
  801dab:	89 c7                	mov    %eax,%edi
  801dad:	fc                   	cld    
  801dae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801db0:	eb 05                	jmp    801db7 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801db2:	89 c7                	mov    %eax,%edi
  801db4:	fc                   	cld    
  801db5:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801db7:	5e                   	pop    %esi
  801db8:	5f                   	pop    %edi
  801db9:	5d                   	pop    %ebp
  801dba:	c3                   	ret    

00801dbb <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  801dbe:	ff 75 10             	pushl  0x10(%ebp)
  801dc1:	ff 75 0c             	pushl  0xc(%ebp)
  801dc4:	ff 75 08             	pushl  0x8(%ebp)
  801dc7:	e8 87 ff ff ff       	call   801d53 <memmove>
}
  801dcc:	c9                   	leave  
  801dcd:	c3                   	ret    

00801dce <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801dce:	55                   	push   %ebp
  801dcf:	89 e5                	mov    %esp,%ebp
  801dd1:	56                   	push   %esi
  801dd2:	53                   	push   %ebx
  801dd3:	8b 45 08             	mov    0x8(%ebp),%eax
  801dd6:	8b 55 0c             	mov    0xc(%ebp),%edx
  801dd9:	89 c6                	mov    %eax,%esi
  801ddb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dde:	eb 1a                	jmp    801dfa <memcmp+0x2c>
		if (*s1 != *s2)
  801de0:	0f b6 08             	movzbl (%eax),%ecx
  801de3:	0f b6 1a             	movzbl (%edx),%ebx
  801de6:	38 d9                	cmp    %bl,%cl
  801de8:	74 0a                	je     801df4 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801dea:	0f b6 c1             	movzbl %cl,%eax
  801ded:	0f b6 db             	movzbl %bl,%ebx
  801df0:	29 d8                	sub    %ebx,%eax
  801df2:	eb 0f                	jmp    801e03 <memcmp+0x35>
		s1++, s2++;
  801df4:	83 c0 01             	add    $0x1,%eax
  801df7:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801dfa:	39 f0                	cmp    %esi,%eax
  801dfc:	75 e2                	jne    801de0 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801dfe:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5d                   	pop    %ebp
  801e06:	c3                   	ret    

00801e07 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801e07:	55                   	push   %ebp
  801e08:	89 e5                	mov    %esp,%ebp
  801e0a:	53                   	push   %ebx
  801e0b:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801e0e:	89 c1                	mov    %eax,%ecx
  801e10:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801e13:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e17:	eb 0a                	jmp    801e23 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801e19:	0f b6 10             	movzbl (%eax),%edx
  801e1c:	39 da                	cmp    %ebx,%edx
  801e1e:	74 07                	je     801e27 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801e20:	83 c0 01             	add    $0x1,%eax
  801e23:	39 c8                	cmp    %ecx,%eax
  801e25:	72 f2                	jb     801e19 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801e27:	5b                   	pop    %ebx
  801e28:	5d                   	pop    %ebp
  801e29:	c3                   	ret    

00801e2a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801e2a:	55                   	push   %ebp
  801e2b:	89 e5                	mov    %esp,%ebp
  801e2d:	57                   	push   %edi
  801e2e:	56                   	push   %esi
  801e2f:	53                   	push   %ebx
  801e30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e36:	eb 03                	jmp    801e3b <strtol+0x11>
		s++;
  801e38:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801e3b:	0f b6 01             	movzbl (%ecx),%eax
  801e3e:	3c 20                	cmp    $0x20,%al
  801e40:	74 f6                	je     801e38 <strtol+0xe>
  801e42:	3c 09                	cmp    $0x9,%al
  801e44:	74 f2                	je     801e38 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801e46:	3c 2b                	cmp    $0x2b,%al
  801e48:	75 0a                	jne    801e54 <strtol+0x2a>
		s++;
  801e4a:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801e4d:	bf 00 00 00 00       	mov    $0x0,%edi
  801e52:	eb 11                	jmp    801e65 <strtol+0x3b>
  801e54:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801e59:	3c 2d                	cmp    $0x2d,%al
  801e5b:	75 08                	jne    801e65 <strtol+0x3b>
		s++, neg = 1;
  801e5d:	83 c1 01             	add    $0x1,%ecx
  801e60:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801e65:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801e6b:	75 15                	jne    801e82 <strtol+0x58>
  801e6d:	80 39 30             	cmpb   $0x30,(%ecx)
  801e70:	75 10                	jne    801e82 <strtol+0x58>
  801e72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801e76:	75 7c                	jne    801ef4 <strtol+0xca>
		s += 2, base = 16;
  801e78:	83 c1 02             	add    $0x2,%ecx
  801e7b:	bb 10 00 00 00       	mov    $0x10,%ebx
  801e80:	eb 16                	jmp    801e98 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801e82:	85 db                	test   %ebx,%ebx
  801e84:	75 12                	jne    801e98 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801e86:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801e8b:	80 39 30             	cmpb   $0x30,(%ecx)
  801e8e:	75 08                	jne    801e98 <strtol+0x6e>
		s++, base = 8;
  801e90:	83 c1 01             	add    $0x1,%ecx
  801e93:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  801e98:	b8 00 00 00 00       	mov    $0x0,%eax
  801e9d:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801ea0:	0f b6 11             	movzbl (%ecx),%edx
  801ea3:	8d 72 d0             	lea    -0x30(%edx),%esi
  801ea6:	89 f3                	mov    %esi,%ebx
  801ea8:	80 fb 09             	cmp    $0x9,%bl
  801eab:	77 08                	ja     801eb5 <strtol+0x8b>
			dig = *s - '0';
  801ead:	0f be d2             	movsbl %dl,%edx
  801eb0:	83 ea 30             	sub    $0x30,%edx
  801eb3:	eb 22                	jmp    801ed7 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  801eb5:	8d 72 9f             	lea    -0x61(%edx),%esi
  801eb8:	89 f3                	mov    %esi,%ebx
  801eba:	80 fb 19             	cmp    $0x19,%bl
  801ebd:	77 08                	ja     801ec7 <strtol+0x9d>
			dig = *s - 'a' + 10;
  801ebf:	0f be d2             	movsbl %dl,%edx
  801ec2:	83 ea 57             	sub    $0x57,%edx
  801ec5:	eb 10                	jmp    801ed7 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801ec7:	8d 72 bf             	lea    -0x41(%edx),%esi
  801eca:	89 f3                	mov    %esi,%ebx
  801ecc:	80 fb 19             	cmp    $0x19,%bl
  801ecf:	77 16                	ja     801ee7 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801ed1:	0f be d2             	movsbl %dl,%edx
  801ed4:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801ed7:	3b 55 10             	cmp    0x10(%ebp),%edx
  801eda:	7d 0b                	jge    801ee7 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801edc:	83 c1 01             	add    $0x1,%ecx
  801edf:	0f af 45 10          	imul   0x10(%ebp),%eax
  801ee3:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801ee5:	eb b9                	jmp    801ea0 <strtol+0x76>

	if (endptr)
  801ee7:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801eeb:	74 0d                	je     801efa <strtol+0xd0>
		*endptr = (char *) s;
  801eed:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ef0:	89 0e                	mov    %ecx,(%esi)
  801ef2:	eb 06                	jmp    801efa <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801ef4:	85 db                	test   %ebx,%ebx
  801ef6:	74 98                	je     801e90 <strtol+0x66>
  801ef8:	eb 9e                	jmp    801e98 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801efa:	89 c2                	mov    %eax,%edx
  801efc:	f7 da                	neg    %edx
  801efe:	85 ff                	test   %edi,%edi
  801f00:	0f 45 c2             	cmovne %edx,%eax
}
  801f03:	5b                   	pop    %ebx
  801f04:	5e                   	pop    %esi
  801f05:	5f                   	pop    %edi
  801f06:	5d                   	pop    %ebp
  801f07:	c3                   	ret    

00801f08 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801f08:	55                   	push   %ebp
  801f09:	89 e5                	mov    %esp,%ebp
  801f0b:	56                   	push   %esi
  801f0c:	53                   	push   %ebx
  801f0d:	8b 75 08             	mov    0x8(%ebp),%esi
  801f10:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f13:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	pg = (pg == NULL ? (void *)UTOP : pg);
  801f16:	85 c0                	test   %eax,%eax
  801f18:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801f1d:	0f 44 c2             	cmove  %edx,%eax
    int r;
    if ((r = sys_ipc_recv(pg)) < 0) {
  801f20:	83 ec 0c             	sub    $0xc,%esp
  801f23:	50                   	push   %eax
  801f24:	e8 ea e3 ff ff       	call   800313 <sys_ipc_recv>
  801f29:	83 c4 10             	add    $0x10,%esp
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	79 16                	jns    801f46 <ipc_recv+0x3e>
        if (from_env_store != NULL)
  801f30:	85 f6                	test   %esi,%esi
  801f32:	74 06                	je     801f3a <ipc_recv+0x32>
            *from_env_store = 0;
  801f34:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
        if (perm_store != NULL)
  801f3a:	85 db                	test   %ebx,%ebx
  801f3c:	74 2c                	je     801f6a <ipc_recv+0x62>
            *perm_store = 0;
  801f3e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  801f44:	eb 24                	jmp    801f6a <ipc_recv+0x62>
        return r;
    }
    if (from_env_store != NULL)
  801f46:	85 f6                	test   %esi,%esi
  801f48:	74 0a                	je     801f54 <ipc_recv+0x4c>
        *from_env_store = thisenv->env_ipc_from;
  801f4a:	a1 08 40 80 00       	mov    0x804008,%eax
  801f4f:	8b 40 74             	mov    0x74(%eax),%eax
  801f52:	89 06                	mov    %eax,(%esi)
    if (perm_store != NULL)
  801f54:	85 db                	test   %ebx,%ebx
  801f56:	74 0a                	je     801f62 <ipc_recv+0x5a>
        *perm_store = thisenv->env_ipc_perm;
  801f58:	a1 08 40 80 00       	mov    0x804008,%eax
  801f5d:	8b 40 78             	mov    0x78(%eax),%eax
  801f60:	89 03                	mov    %eax,(%ebx)
    return thisenv->env_ipc_value;
  801f62:	a1 08 40 80 00       	mov    0x804008,%eax
  801f67:	8b 40 70             	mov    0x70(%eax),%eax
	//panic("ipc_recv not implemented");
	return 0;
}
  801f6a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f6d:	5b                   	pop    %ebx
  801f6e:	5e                   	pop    %esi
  801f6f:	5d                   	pop    %ebp
  801f70:	c3                   	ret    

00801f71 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801f71:	55                   	push   %ebp
  801f72:	89 e5                	mov    %esp,%ebp
  801f74:	57                   	push   %edi
  801f75:	56                   	push   %esi
  801f76:	53                   	push   %ebx
  801f77:	83 ec 0c             	sub    $0xc,%esp
  801f7a:	8b 7d 08             	mov    0x8(%ebp),%edi
  801f7d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801f80:	8b 45 10             	mov    0x10(%ebp),%eax
  801f83:	85 c0                	test   %eax,%eax
  801f85:	bb 00 00 c0 ee       	mov    $0xeec00000,%ebx
  801f8a:	0f 45 d8             	cmovne %eax,%ebx
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801f8d:	eb 1c                	jmp    801fab <ipc_send+0x3a>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
  801f8f:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801f92:	74 12                	je     801fa6 <ipc_send+0x35>
  801f94:	50                   	push   %eax
  801f95:	68 60 27 80 00       	push   $0x802760
  801f9a:	6a 3b                	push   $0x3b
  801f9c:	68 76 27 80 00       	push   $0x802776
  801fa1:	e8 3e f5 ff ff       	call   8014e4 <_panic>
		sys_yield();
  801fa6:	e8 99 e1 ff ff       	call   800144 <sys_yield>
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int r;
	//cprintf("send to envid = %d\n",to_env);
	while((r=sys_ipc_try_send(to_env,val, (pg == NULL ? (void *)UTOP : pg),perm))<0){
  801fab:	ff 75 14             	pushl  0x14(%ebp)
  801fae:	53                   	push   %ebx
  801faf:	56                   	push   %esi
  801fb0:	57                   	push   %edi
  801fb1:	e8 3a e3 ff ff       	call   8002f0 <sys_ipc_try_send>
  801fb6:	83 c4 10             	add    $0x10,%esp
  801fb9:	85 c0                	test   %eax,%eax
  801fbb:	78 d2                	js     801f8f <ipc_send+0x1e>
		if(r!=-E_IPC_NOT_RECV)panic("sys_ipc_try_send: %e\n", r);
		sys_yield();
	}
	//panic("ipc_send not implemented");
}
  801fbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc0:	5b                   	pop    %ebx
  801fc1:	5e                   	pop    %esi
  801fc2:	5f                   	pop    %edi
  801fc3:	5d                   	pop    %ebp
  801fc4:	c3                   	ret    

00801fc5 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801fc5:	55                   	push   %ebp
  801fc6:	89 e5                	mov    %esp,%ebp
  801fc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801fcb:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801fd0:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801fd3:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801fd9:	8b 52 50             	mov    0x50(%edx),%edx
  801fdc:	39 ca                	cmp    %ecx,%edx
  801fde:	75 0d                	jne    801fed <ipc_find_env+0x28>
			return envs[i].env_id;
  801fe0:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801fe3:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801fe8:	8b 40 48             	mov    0x48(%eax),%eax
  801feb:	eb 0f                	jmp    801ffc <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801fed:	83 c0 01             	add    $0x1,%eax
  801ff0:	3d 00 04 00 00       	cmp    $0x400,%eax
  801ff5:	75 d9                	jne    801fd0 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ffc:	5d                   	pop    %ebp
  801ffd:	c3                   	ret    

00801ffe <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ffe:	55                   	push   %ebp
  801fff:	89 e5                	mov    %esp,%ebp
  802001:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802004:	89 d0                	mov    %edx,%eax
  802006:	c1 e8 16             	shr    $0x16,%eax
  802009:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  802010:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802015:	f6 c1 01             	test   $0x1,%cl
  802018:	74 1d                	je     802037 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  80201a:	c1 ea 0c             	shr    $0xc,%edx
  80201d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  802024:	f6 c2 01             	test   $0x1,%dl
  802027:	74 0e                	je     802037 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802029:	c1 ea 0c             	shr    $0xc,%edx
  80202c:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  802033:	ef 
  802034:	0f b7 c0             	movzwl %ax,%eax
}
  802037:	5d                   	pop    %ebp
  802038:	c3                   	ret    
  802039:	66 90                	xchg   %ax,%ax
  80203b:	66 90                	xchg   %ax,%ax
  80203d:	66 90                	xchg   %ax,%ax
  80203f:	90                   	nop

00802040 <__udivdi3>:
  802040:	55                   	push   %ebp
  802041:	57                   	push   %edi
  802042:	56                   	push   %esi
  802043:	53                   	push   %ebx
  802044:	83 ec 1c             	sub    $0x1c,%esp
  802047:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  80204b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  80204f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  802053:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802057:	85 f6                	test   %esi,%esi
  802059:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80205d:	89 ca                	mov    %ecx,%edx
  80205f:	89 f8                	mov    %edi,%eax
  802061:	75 3d                	jne    8020a0 <__udivdi3+0x60>
  802063:	39 cf                	cmp    %ecx,%edi
  802065:	0f 87 c5 00 00 00    	ja     802130 <__udivdi3+0xf0>
  80206b:	85 ff                	test   %edi,%edi
  80206d:	89 fd                	mov    %edi,%ebp
  80206f:	75 0b                	jne    80207c <__udivdi3+0x3c>
  802071:	b8 01 00 00 00       	mov    $0x1,%eax
  802076:	31 d2                	xor    %edx,%edx
  802078:	f7 f7                	div    %edi
  80207a:	89 c5                	mov    %eax,%ebp
  80207c:	89 c8                	mov    %ecx,%eax
  80207e:	31 d2                	xor    %edx,%edx
  802080:	f7 f5                	div    %ebp
  802082:	89 c1                	mov    %eax,%ecx
  802084:	89 d8                	mov    %ebx,%eax
  802086:	89 cf                	mov    %ecx,%edi
  802088:	f7 f5                	div    %ebp
  80208a:	89 c3                	mov    %eax,%ebx
  80208c:	89 d8                	mov    %ebx,%eax
  80208e:	89 fa                	mov    %edi,%edx
  802090:	83 c4 1c             	add    $0x1c,%esp
  802093:	5b                   	pop    %ebx
  802094:	5e                   	pop    %esi
  802095:	5f                   	pop    %edi
  802096:	5d                   	pop    %ebp
  802097:	c3                   	ret    
  802098:	90                   	nop
  802099:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8020a0:	39 ce                	cmp    %ecx,%esi
  8020a2:	77 74                	ja     802118 <__udivdi3+0xd8>
  8020a4:	0f bd fe             	bsr    %esi,%edi
  8020a7:	83 f7 1f             	xor    $0x1f,%edi
  8020aa:	0f 84 98 00 00 00    	je     802148 <__udivdi3+0x108>
  8020b0:	bb 20 00 00 00       	mov    $0x20,%ebx
  8020b5:	89 f9                	mov    %edi,%ecx
  8020b7:	89 c5                	mov    %eax,%ebp
  8020b9:	29 fb                	sub    %edi,%ebx
  8020bb:	d3 e6                	shl    %cl,%esi
  8020bd:	89 d9                	mov    %ebx,%ecx
  8020bf:	d3 ed                	shr    %cl,%ebp
  8020c1:	89 f9                	mov    %edi,%ecx
  8020c3:	d3 e0                	shl    %cl,%eax
  8020c5:	09 ee                	or     %ebp,%esi
  8020c7:	89 d9                	mov    %ebx,%ecx
  8020c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8020cd:	89 d5                	mov    %edx,%ebp
  8020cf:	8b 44 24 08          	mov    0x8(%esp),%eax
  8020d3:	d3 ed                	shr    %cl,%ebp
  8020d5:	89 f9                	mov    %edi,%ecx
  8020d7:	d3 e2                	shl    %cl,%edx
  8020d9:	89 d9                	mov    %ebx,%ecx
  8020db:	d3 e8                	shr    %cl,%eax
  8020dd:	09 c2                	or     %eax,%edx
  8020df:	89 d0                	mov    %edx,%eax
  8020e1:	89 ea                	mov    %ebp,%edx
  8020e3:	f7 f6                	div    %esi
  8020e5:	89 d5                	mov    %edx,%ebp
  8020e7:	89 c3                	mov    %eax,%ebx
  8020e9:	f7 64 24 0c          	mull   0xc(%esp)
  8020ed:	39 d5                	cmp    %edx,%ebp
  8020ef:	72 10                	jb     802101 <__udivdi3+0xc1>
  8020f1:	8b 74 24 08          	mov    0x8(%esp),%esi
  8020f5:	89 f9                	mov    %edi,%ecx
  8020f7:	d3 e6                	shl    %cl,%esi
  8020f9:	39 c6                	cmp    %eax,%esi
  8020fb:	73 07                	jae    802104 <__udivdi3+0xc4>
  8020fd:	39 d5                	cmp    %edx,%ebp
  8020ff:	75 03                	jne    802104 <__udivdi3+0xc4>
  802101:	83 eb 01             	sub    $0x1,%ebx
  802104:	31 ff                	xor    %edi,%edi
  802106:	89 d8                	mov    %ebx,%eax
  802108:	89 fa                	mov    %edi,%edx
  80210a:	83 c4 1c             	add    $0x1c,%esp
  80210d:	5b                   	pop    %ebx
  80210e:	5e                   	pop    %esi
  80210f:	5f                   	pop    %edi
  802110:	5d                   	pop    %ebp
  802111:	c3                   	ret    
  802112:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802118:	31 ff                	xor    %edi,%edi
  80211a:	31 db                	xor    %ebx,%ebx
  80211c:	89 d8                	mov    %ebx,%eax
  80211e:	89 fa                	mov    %edi,%edx
  802120:	83 c4 1c             	add    $0x1c,%esp
  802123:	5b                   	pop    %ebx
  802124:	5e                   	pop    %esi
  802125:	5f                   	pop    %edi
  802126:	5d                   	pop    %ebp
  802127:	c3                   	ret    
  802128:	90                   	nop
  802129:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802130:	89 d8                	mov    %ebx,%eax
  802132:	f7 f7                	div    %edi
  802134:	31 ff                	xor    %edi,%edi
  802136:	89 c3                	mov    %eax,%ebx
  802138:	89 d8                	mov    %ebx,%eax
  80213a:	89 fa                	mov    %edi,%edx
  80213c:	83 c4 1c             	add    $0x1c,%esp
  80213f:	5b                   	pop    %ebx
  802140:	5e                   	pop    %esi
  802141:	5f                   	pop    %edi
  802142:	5d                   	pop    %ebp
  802143:	c3                   	ret    
  802144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802148:	39 ce                	cmp    %ecx,%esi
  80214a:	72 0c                	jb     802158 <__udivdi3+0x118>
  80214c:	31 db                	xor    %ebx,%ebx
  80214e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  802152:	0f 87 34 ff ff ff    	ja     80208c <__udivdi3+0x4c>
  802158:	bb 01 00 00 00       	mov    $0x1,%ebx
  80215d:	e9 2a ff ff ff       	jmp    80208c <__udivdi3+0x4c>
  802162:	66 90                	xchg   %ax,%ax
  802164:	66 90                	xchg   %ax,%ax
  802166:	66 90                	xchg   %ax,%ax
  802168:	66 90                	xchg   %ax,%ax
  80216a:	66 90                	xchg   %ax,%ax
  80216c:	66 90                	xchg   %ax,%ax
  80216e:	66 90                	xchg   %ax,%ax

00802170 <__umoddi3>:
  802170:	55                   	push   %ebp
  802171:	57                   	push   %edi
  802172:	56                   	push   %esi
  802173:	53                   	push   %ebx
  802174:	83 ec 1c             	sub    $0x1c,%esp
  802177:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80217b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  80217f:	8b 74 24 34          	mov    0x34(%esp),%esi
  802183:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802187:	85 d2                	test   %edx,%edx
  802189:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  80218d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802191:	89 f3                	mov    %esi,%ebx
  802193:	89 3c 24             	mov    %edi,(%esp)
  802196:	89 74 24 04          	mov    %esi,0x4(%esp)
  80219a:	75 1c                	jne    8021b8 <__umoddi3+0x48>
  80219c:	39 f7                	cmp    %esi,%edi
  80219e:	76 50                	jbe    8021f0 <__umoddi3+0x80>
  8021a0:	89 c8                	mov    %ecx,%eax
  8021a2:	89 f2                	mov    %esi,%edx
  8021a4:	f7 f7                	div    %edi
  8021a6:	89 d0                	mov    %edx,%eax
  8021a8:	31 d2                	xor    %edx,%edx
  8021aa:	83 c4 1c             	add    $0x1c,%esp
  8021ad:	5b                   	pop    %ebx
  8021ae:	5e                   	pop    %esi
  8021af:	5f                   	pop    %edi
  8021b0:	5d                   	pop    %ebp
  8021b1:	c3                   	ret    
  8021b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8021b8:	39 f2                	cmp    %esi,%edx
  8021ba:	89 d0                	mov    %edx,%eax
  8021bc:	77 52                	ja     802210 <__umoddi3+0xa0>
  8021be:	0f bd ea             	bsr    %edx,%ebp
  8021c1:	83 f5 1f             	xor    $0x1f,%ebp
  8021c4:	75 5a                	jne    802220 <__umoddi3+0xb0>
  8021c6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  8021ca:	0f 82 e0 00 00 00    	jb     8022b0 <__umoddi3+0x140>
  8021d0:	39 0c 24             	cmp    %ecx,(%esp)
  8021d3:	0f 86 d7 00 00 00    	jbe    8022b0 <__umoddi3+0x140>
  8021d9:	8b 44 24 08          	mov    0x8(%esp),%eax
  8021dd:	8b 54 24 04          	mov    0x4(%esp),%edx
  8021e1:	83 c4 1c             	add    $0x1c,%esp
  8021e4:	5b                   	pop    %ebx
  8021e5:	5e                   	pop    %esi
  8021e6:	5f                   	pop    %edi
  8021e7:	5d                   	pop    %ebp
  8021e8:	c3                   	ret    
  8021e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8021f0:	85 ff                	test   %edi,%edi
  8021f2:	89 fd                	mov    %edi,%ebp
  8021f4:	75 0b                	jne    802201 <__umoddi3+0x91>
  8021f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8021fb:	31 d2                	xor    %edx,%edx
  8021fd:	f7 f7                	div    %edi
  8021ff:	89 c5                	mov    %eax,%ebp
  802201:	89 f0                	mov    %esi,%eax
  802203:	31 d2                	xor    %edx,%edx
  802205:	f7 f5                	div    %ebp
  802207:	89 c8                	mov    %ecx,%eax
  802209:	f7 f5                	div    %ebp
  80220b:	89 d0                	mov    %edx,%eax
  80220d:	eb 99                	jmp    8021a8 <__umoddi3+0x38>
  80220f:	90                   	nop
  802210:	89 c8                	mov    %ecx,%eax
  802212:	89 f2                	mov    %esi,%edx
  802214:	83 c4 1c             	add    $0x1c,%esp
  802217:	5b                   	pop    %ebx
  802218:	5e                   	pop    %esi
  802219:	5f                   	pop    %edi
  80221a:	5d                   	pop    %ebp
  80221b:	c3                   	ret    
  80221c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  802220:	8b 34 24             	mov    (%esp),%esi
  802223:	bf 20 00 00 00       	mov    $0x20,%edi
  802228:	89 e9                	mov    %ebp,%ecx
  80222a:	29 ef                	sub    %ebp,%edi
  80222c:	d3 e0                	shl    %cl,%eax
  80222e:	89 f9                	mov    %edi,%ecx
  802230:	89 f2                	mov    %esi,%edx
  802232:	d3 ea                	shr    %cl,%edx
  802234:	89 e9                	mov    %ebp,%ecx
  802236:	09 c2                	or     %eax,%edx
  802238:	89 d8                	mov    %ebx,%eax
  80223a:	89 14 24             	mov    %edx,(%esp)
  80223d:	89 f2                	mov    %esi,%edx
  80223f:	d3 e2                	shl    %cl,%edx
  802241:	89 f9                	mov    %edi,%ecx
  802243:	89 54 24 04          	mov    %edx,0x4(%esp)
  802247:	8b 54 24 0c          	mov    0xc(%esp),%edx
  80224b:	d3 e8                	shr    %cl,%eax
  80224d:	89 e9                	mov    %ebp,%ecx
  80224f:	89 c6                	mov    %eax,%esi
  802251:	d3 e3                	shl    %cl,%ebx
  802253:	89 f9                	mov    %edi,%ecx
  802255:	89 d0                	mov    %edx,%eax
  802257:	d3 e8                	shr    %cl,%eax
  802259:	89 e9                	mov    %ebp,%ecx
  80225b:	09 d8                	or     %ebx,%eax
  80225d:	89 d3                	mov    %edx,%ebx
  80225f:	89 f2                	mov    %esi,%edx
  802261:	f7 34 24             	divl   (%esp)
  802264:	89 d6                	mov    %edx,%esi
  802266:	d3 e3                	shl    %cl,%ebx
  802268:	f7 64 24 04          	mull   0x4(%esp)
  80226c:	39 d6                	cmp    %edx,%esi
  80226e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  802272:	89 d1                	mov    %edx,%ecx
  802274:	89 c3                	mov    %eax,%ebx
  802276:	72 08                	jb     802280 <__umoddi3+0x110>
  802278:	75 11                	jne    80228b <__umoddi3+0x11b>
  80227a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  80227e:	73 0b                	jae    80228b <__umoddi3+0x11b>
  802280:	2b 44 24 04          	sub    0x4(%esp),%eax
  802284:	1b 14 24             	sbb    (%esp),%edx
  802287:	89 d1                	mov    %edx,%ecx
  802289:	89 c3                	mov    %eax,%ebx
  80228b:	8b 54 24 08          	mov    0x8(%esp),%edx
  80228f:	29 da                	sub    %ebx,%edx
  802291:	19 ce                	sbb    %ecx,%esi
  802293:	89 f9                	mov    %edi,%ecx
  802295:	89 f0                	mov    %esi,%eax
  802297:	d3 e0                	shl    %cl,%eax
  802299:	89 e9                	mov    %ebp,%ecx
  80229b:	d3 ea                	shr    %cl,%edx
  80229d:	89 e9                	mov    %ebp,%ecx
  80229f:	d3 ee                	shr    %cl,%esi
  8022a1:	09 d0                	or     %edx,%eax
  8022a3:	89 f2                	mov    %esi,%edx
  8022a5:	83 c4 1c             	add    $0x1c,%esp
  8022a8:	5b                   	pop    %ebx
  8022a9:	5e                   	pop    %esi
  8022aa:	5f                   	pop    %edi
  8022ab:	5d                   	pop    %ebp
  8022ac:	c3                   	ret    
  8022ad:	8d 76 00             	lea    0x0(%esi),%esi
  8022b0:	29 f9                	sub    %edi,%ecx
  8022b2:	19 d6                	sbb    %edx,%esi
  8022b4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8022b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022bc:	e9 18 ff ff ff       	jmp    8021d9 <__umoddi3+0x69>
