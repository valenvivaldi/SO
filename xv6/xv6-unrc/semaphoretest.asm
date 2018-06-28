
_semaphoretest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:
int empty;
int full;

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 ec 02 00 00       	call   2fd <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 bc 04 00 00       	call   4df <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <encolar>:



void
encolar (int nuevo)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 08             	sub    $0x8,%esp
  semdown(ql);
  2f:	a1 40 08 00 00       	mov    0x840,%eax
  34:	83 ec 0c             	sub    $0xc,%esp
  37:	50                   	push   %eax
  38:	e8 42 05 00 00       	call   57f <semdown>
  3d:	83 c4 10             	add    $0x10,%esp
  printf(1,"PRODUCE\n");
  40:	83 ec 08             	sub    $0x8,%esp
  43:	68 8f 05 00 00       	push   $0x58f
  48:	6a 01                	push   $0x1
  4a:	e8 b1 ff ff ff       	call   0 <printf>
  4f:	83 c4 10             	add    $0x10,%esp
  write(fd, "+1", sizeof("+1"));
  52:	a1 38 08 00 00       	mov    0x838,%eax
  57:	83 ec 04             	sub    $0x4,%esp
  5a:	6a 03                	push   $0x3
  5c:	68 98 05 00 00       	push   $0x598
  61:	50                   	push   %eax
  62:	e8 78 04 00 00       	call   4df <write>
  67:	83 c4 10             	add    $0x10,%esp
  semup(ql);
  6a:	a1 40 08 00 00       	mov    0x840,%eax
  6f:	83 ec 0c             	sub    $0xc,%esp
  72:	50                   	push   %eax
  73:	e8 0f 05 00 00       	call   587 <semup>
  78:	83 c4 10             	add    $0x10,%esp

}
  7b:	90                   	nop
  7c:	c9                   	leave  
  7d:	c3                   	ret    

0000007e <desencolar>:

int
desencolar()
{
  7e:	55                   	push   %ebp
  7f:	89 e5                	mov    %esp,%ebp
  81:	83 ec 08             	sub    $0x8,%esp

  semdown(ql);
  84:	a1 40 08 00 00       	mov    0x840,%eax
  89:	83 ec 0c             	sub    $0xc,%esp
  8c:	50                   	push   %eax
  8d:	e8 ed 04 00 00       	call   57f <semdown>
  92:	83 c4 10             	add    $0x10,%esp
  printf(1,"CONSUME\n");
  95:	83 ec 08             	sub    $0x8,%esp
  98:	68 9b 05 00 00       	push   $0x59b
  9d:	6a 01                	push   $0x1
  9f:	e8 5c ff ff ff       	call   0 <printf>
  a4:	83 c4 10             	add    $0x10,%esp
  write(fd, "-1", sizeof("-1"));
  a7:	a1 38 08 00 00       	mov    0x838,%eax
  ac:	83 ec 04             	sub    $0x4,%esp
  af:	6a 03                	push   $0x3
  b1:	68 a4 05 00 00       	push   $0x5a4
  b6:	50                   	push   %eax
  b7:	e8 23 04 00 00       	call   4df <write>
  bc:	83 c4 10             	add    $0x10,%esp
  semup(ql);
  bf:	a1 40 08 00 00       	mov    0x840,%eax
  c4:	83 ec 0c             	sub    $0xc,%esp
  c7:	50                   	push   %eax
  c8:	e8 ba 04 00 00       	call   587 <semup>
  cd:	83 c4 10             	add    $0x10,%esp

  return 0;
  d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  d5:	c9                   	leave  
  d6:	c3                   	ret    

000000d7 <consumidor>:


void
consumidor(void)
{
  d7:	55                   	push   %ebp
  d8:	89 e5                	mov    %esp,%ebp
  da:	83 ec 08             	sub    $0x8,%esp
  for(;;) {
    semdown(empty);
  dd:	a1 44 08 00 00       	mov    0x844,%eax
  e2:	83 ec 0c             	sub    $0xc,%esp
  e5:	50                   	push   %eax
  e6:	e8 94 04 00 00       	call   57f <semdown>
  eb:	83 c4 10             	add    $0x10,%esp
    //printf(1,"RESTE UNO EN EMPTY\n");
    desencolar();
  ee:	e8 8b ff ff ff       	call   7e <desencolar>
    semup(full);
  f3:	a1 3c 08 00 00       	mov    0x83c,%eax
  f8:	83 ec 0c             	sub    $0xc,%esp
  fb:	50                   	push   %eax
  fc:	e8 86 04 00 00       	call   587 <semup>
 101:	83 c4 10             	add    $0x10,%esp
    //printf(1,"SUME UNO EN FULL\n");
    printf(1,"-------\n");
 104:	83 ec 08             	sub    $0x8,%esp
 107:	68 a7 05 00 00       	push   $0x5a7
 10c:	6a 01                	push   $0x1
 10e:	e8 ed fe ff ff       	call   0 <printf>
 113:	83 c4 10             	add    $0x10,%esp
  }
 116:	eb c5                	jmp    dd <consumidor+0x6>

00000118 <productor>:
}

void
productor(void)
{
 118:	55                   	push   %ebp
 119:	89 e5                	mov    %esp,%ebp
 11b:	83 ec 18             	sub    $0x18,%esp
  int i;
  for(i=0;i<CANTPRODUCCIONES;i++) {
 11e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 125:	eb 34                	jmp    15b <productor+0x43>

    semdown(full);
 127:	a1 3c 08 00 00       	mov    0x83c,%eax
 12c:	83 ec 0c             	sub    $0xc,%esp
 12f:	50                   	push   %eax
 130:	e8 4a 04 00 00       	call   57f <semdown>
 135:	83 c4 10             	add    $0x10,%esp
    //printf(1,"RESTE UNO EN FULL\n");
    encolar(i);
 138:	83 ec 0c             	sub    $0xc,%esp
 13b:	ff 75 f4             	pushl  -0xc(%ebp)
 13e:	e8 e6 fe ff ff       	call   29 <encolar>
 143:	83 c4 10             	add    $0x10,%esp
    semup(empty);
 146:	a1 44 08 00 00       	mov    0x844,%eax
 14b:	83 ec 0c             	sub    $0xc,%esp
 14e:	50                   	push   %eax
 14f:	e8 33 04 00 00       	call   587 <semup>
 154:	83 c4 10             	add    $0x10,%esp

void
productor(void)
{
  int i;
  for(i=0;i<CANTPRODUCCIONES;i++) {
 157:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 15b:	81 7d f4 c7 00 00 00 	cmpl   $0xc7,-0xc(%ebp)
 162:	7e c3                	jle    127 <productor+0xf>
    encolar(i);
    semup(empty);
    //printf(1,"SUME UNO EN EMPTY\n");
    //printf(1,"--------------------\n");
  }
}
 164:	90                   	nop
 165:	c9                   	leave  
 166:	c3                   	ret    

00000167 <semtest>:

void
semtest(void)
{
 167:	55                   	push   %ebp
 168:	89 e5                	mov    %esp,%ebp
 16a:	83 ec 18             	sub    $0x18,%esp
  int i;
  int pid=1;
 16d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
  fd=open("logProdCons", O_CREATE|O_RDWR);
 174:	83 ec 08             	sub    $0x8,%esp
 177:	68 02 02 00 00       	push   $0x202
 17c:	68 b0 05 00 00       	push   $0x5b0
 181:	e8 79 03 00 00       	call   4ff <open>
 186:	83 c4 10             	add    $0x10,%esp
 189:	a3 38 08 00 00       	mov    %eax,0x838

  for(i=0;i<CANTPRODUCTORES;i++){
 18e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 195:	eb 26                	jmp    1bd <semtest+0x56>

    pid=fork();
 197:	e8 1b 03 00 00       	call   4b7 <fork>
 19c:	89 45 f0             	mov    %eax,-0x10(%ebp)

    if(pid==0){
 19f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a3:	75 14                	jne    1b9 <semtest+0x52>
      printf(1,"SE INICIA UN HIJO PRODUCTOR\n" );
 1a5:	83 ec 08             	sub    $0x8,%esp
 1a8:	68 bc 05 00 00       	push   $0x5bc
 1ad:	6a 01                	push   $0x1
 1af:	e8 4c fe ff ff       	call   0 <printf>
 1b4:	83 c4 10             	add    $0x10,%esp
      break;
 1b7:	eb 0a                	jmp    1c3 <semtest+0x5c>
{
  int i;
  int pid=1;
  fd=open("logProdCons", O_CREATE|O_RDWR);

  for(i=0;i<CANTPRODUCTORES;i++){
 1b9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1bd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c1:	7e d4                	jle    197 <semtest+0x30>
      printf(1,"SE INICIA UN HIJO PRODUCTOR\n" );
      break;
    }

  }
  if(pid==0){
 1c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c7:	75 05                	jne    1ce <semtest+0x67>
    productor();
 1c9:	e8 4a ff ff ff       	call   118 <productor>
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
 1ce:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d5:	eb 26                	jmp    1fd <semtest+0x96>
    pid=fork();
 1d7:	e8 db 02 00 00       	call   4b7 <fork>
 1dc:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(pid==0){
 1df:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1e3:	75 14                	jne    1f9 <semtest+0x92>
      printf(1,"SE INICIA UN HIJO CONSUMIDOR\n" );
 1e5:	83 ec 08             	sub    $0x8,%esp
 1e8:	68 d9 05 00 00       	push   $0x5d9
 1ed:	6a 01                	push   $0x1
 1ef:	e8 0c fe ff ff       	call   0 <printf>
 1f4:	83 c4 10             	add    $0x10,%esp
      break;
 1f7:	eb 0a                	jmp    203 <semtest+0x9c>
  }
  if(pid==0){
    productor();
  }

  for(i=0;i<CANTCONSUMIDORES;i++){
 1f9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
 1fd:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 201:	7e d4                	jle    1d7 <semtest+0x70>
      printf(1,"SE INICIA UN HIJO CONSUMIDOR\n" );
      break;
    }

  }
  if(pid==0){
 203:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 207:	75 05                	jne    20e <semtest+0xa7>
    consumidor();
 209:	e8 c9 fe ff ff       	call   d7 <consumidor>
  }


}
 20e:	90                   	nop
 20f:	c9                   	leave  
 210:	c3                   	ret    

00000211 <main>:


int
main(void)
{
 211:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 215:	83 e4 f0             	and    $0xfffffff0,%esp
 218:	ff 71 fc             	pushl  -0x4(%ecx)
 21b:	55                   	push   %ebp
 21c:	89 e5                	mov    %esp,%ebp
 21e:	51                   	push   %ecx
 21f:	83 ec 04             	sub    $0x4,%esp

  ql = semget(-1,1);
 222:	83 ec 08             	sub    $0x8,%esp
 225:	6a 01                	push   $0x1
 227:	6a ff                	push   $0xffffffff
 229:	e8 41 03 00 00       	call   56f <semget>
 22e:	83 c4 10             	add    $0x10,%esp
 231:	a3 40 08 00 00       	mov    %eax,0x840
  full= semget(-1,TAMANIOBUFFER);
 236:	83 ec 08             	sub    $0x8,%esp
 239:	6a 0a                	push   $0xa
 23b:	6a ff                	push   $0xffffffff
 23d:	e8 2d 03 00 00       	call   56f <semget>
 242:	83 c4 10             	add    $0x10,%esp
 245:	a3 3c 08 00 00       	mov    %eax,0x83c
  empty= semget(-1,0);
 24a:	83 ec 08             	sub    $0x8,%esp
 24d:	6a 00                	push   $0x0
 24f:	6a ff                	push   $0xffffffff
 251:	e8 19 03 00 00       	call   56f <semget>
 256:	83 c4 10             	add    $0x10,%esp
 259:	a3 44 08 00 00       	mov    %eax,0x844

  semtest();
 25e:	e8 04 ff ff ff       	call   167 <semtest>
  exit();
 263:	e8 57 02 00 00       	call   4bf <exit>

00000268 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
 268:	55                   	push   %ebp
 269:	89 e5                	mov    %esp,%ebp
 26b:	57                   	push   %edi
 26c:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
 26d:	8b 4d 08             	mov    0x8(%ebp),%ecx
 270:	8b 55 10             	mov    0x10(%ebp),%edx
 273:	8b 45 0c             	mov    0xc(%ebp),%eax
 276:	89 cb                	mov    %ecx,%ebx
 278:	89 df                	mov    %ebx,%edi
 27a:	89 d1                	mov    %edx,%ecx
 27c:	fc                   	cld    
 27d:	f3 aa                	rep stos %al,%es:(%edi)
 27f:	89 ca                	mov    %ecx,%edx
 281:	89 fb                	mov    %edi,%ebx
 283:	89 5d 08             	mov    %ebx,0x8(%ebp)
 286:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
 289:	90                   	nop
 28a:	5b                   	pop    %ebx
 28b:	5f                   	pop    %edi
 28c:	5d                   	pop    %ebp
 28d:	c3                   	ret    

0000028e <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
 28e:	55                   	push   %ebp
 28f:	89 e5                	mov    %esp,%ebp
 291:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
 294:	8b 45 08             	mov    0x8(%ebp),%eax
 297:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
 29a:	90                   	nop
 29b:	8b 45 08             	mov    0x8(%ebp),%eax
 29e:	8d 50 01             	lea    0x1(%eax),%edx
 2a1:	89 55 08             	mov    %edx,0x8(%ebp)
 2a4:	8b 55 0c             	mov    0xc(%ebp),%edx
 2a7:	8d 4a 01             	lea    0x1(%edx),%ecx
 2aa:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 2ad:	0f b6 12             	movzbl (%edx),%edx
 2b0:	88 10                	mov    %dl,(%eax)
 2b2:	0f b6 00             	movzbl (%eax),%eax
 2b5:	84 c0                	test   %al,%al
 2b7:	75 e2                	jne    29b <strcpy+0xd>
    ;
  return os;
 2b9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2bc:	c9                   	leave  
 2bd:	c3                   	ret    

000002be <strcmp>:

int
strcmp(const char *p, const char *q)
{
 2be:	55                   	push   %ebp
 2bf:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 2c1:	eb 08                	jmp    2cb <strcmp+0xd>
    p++, q++;
 2c3:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 2c7:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 2cb:	8b 45 08             	mov    0x8(%ebp),%eax
 2ce:	0f b6 00             	movzbl (%eax),%eax
 2d1:	84 c0                	test   %al,%al
 2d3:	74 10                	je     2e5 <strcmp+0x27>
 2d5:	8b 45 08             	mov    0x8(%ebp),%eax
 2d8:	0f b6 10             	movzbl (%eax),%edx
 2db:	8b 45 0c             	mov    0xc(%ebp),%eax
 2de:	0f b6 00             	movzbl (%eax),%eax
 2e1:	38 c2                	cmp    %al,%dl
 2e3:	74 de                	je     2c3 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 2e5:	8b 45 08             	mov    0x8(%ebp),%eax
 2e8:	0f b6 00             	movzbl (%eax),%eax
 2eb:	0f b6 d0             	movzbl %al,%edx
 2ee:	8b 45 0c             	mov    0xc(%ebp),%eax
 2f1:	0f b6 00             	movzbl (%eax),%eax
 2f4:	0f b6 c0             	movzbl %al,%eax
 2f7:	29 c2                	sub    %eax,%edx
 2f9:	89 d0                	mov    %edx,%eax
}
 2fb:	5d                   	pop    %ebp
 2fc:	c3                   	ret    

000002fd <strlen>:

uint
strlen(char *s)
{
 2fd:	55                   	push   %ebp
 2fe:	89 e5                	mov    %esp,%ebp
 300:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 303:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 30a:	eb 04                	jmp    310 <strlen+0x13>
 30c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 310:	8b 55 fc             	mov    -0x4(%ebp),%edx
 313:	8b 45 08             	mov    0x8(%ebp),%eax
 316:	01 d0                	add    %edx,%eax
 318:	0f b6 00             	movzbl (%eax),%eax
 31b:	84 c0                	test   %al,%al
 31d:	75 ed                	jne    30c <strlen+0xf>
    ;
  return n;
 31f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 322:	c9                   	leave  
 323:	c3                   	ret    

00000324 <memset>:

void*
memset(void *dst, int c, uint n)
{
 324:	55                   	push   %ebp
 325:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 327:	8b 45 10             	mov    0x10(%ebp),%eax
 32a:	50                   	push   %eax
 32b:	ff 75 0c             	pushl  0xc(%ebp)
 32e:	ff 75 08             	pushl  0x8(%ebp)
 331:	e8 32 ff ff ff       	call   268 <stosb>
 336:	83 c4 0c             	add    $0xc,%esp
  return dst;
 339:	8b 45 08             	mov    0x8(%ebp),%eax
}
 33c:	c9                   	leave  
 33d:	c3                   	ret    

0000033e <strchr>:

char*
strchr(const char *s, char c)
{
 33e:	55                   	push   %ebp
 33f:	89 e5                	mov    %esp,%ebp
 341:	83 ec 04             	sub    $0x4,%esp
 344:	8b 45 0c             	mov    0xc(%ebp),%eax
 347:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 34a:	eb 14                	jmp    360 <strchr+0x22>
    if(*s == c)
 34c:	8b 45 08             	mov    0x8(%ebp),%eax
 34f:	0f b6 00             	movzbl (%eax),%eax
 352:	3a 45 fc             	cmp    -0x4(%ebp),%al
 355:	75 05                	jne    35c <strchr+0x1e>
      return (char*)s;
 357:	8b 45 08             	mov    0x8(%ebp),%eax
 35a:	eb 13                	jmp    36f <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 35c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 360:	8b 45 08             	mov    0x8(%ebp),%eax
 363:	0f b6 00             	movzbl (%eax),%eax
 366:	84 c0                	test   %al,%al
 368:	75 e2                	jne    34c <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 36a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 36f:	c9                   	leave  
 370:	c3                   	ret    

00000371 <gets>:

char*
gets(char *buf, int max)
{
 371:	55                   	push   %ebp
 372:	89 e5                	mov    %esp,%ebp
 374:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 377:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 37e:	eb 42                	jmp    3c2 <gets+0x51>
    cc = read(0, &c, 1);
 380:	83 ec 04             	sub    $0x4,%esp
 383:	6a 01                	push   $0x1
 385:	8d 45 ef             	lea    -0x11(%ebp),%eax
 388:	50                   	push   %eax
 389:	6a 00                	push   $0x0
 38b:	e8 47 01 00 00       	call   4d7 <read>
 390:	83 c4 10             	add    $0x10,%esp
 393:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 396:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 39a:	7e 33                	jle    3cf <gets+0x5e>
      break;
    buf[i++] = c;
 39c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 39f:	8d 50 01             	lea    0x1(%eax),%edx
 3a2:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3a5:	89 c2                	mov    %eax,%edx
 3a7:	8b 45 08             	mov    0x8(%ebp),%eax
 3aa:	01 c2                	add    %eax,%edx
 3ac:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3b0:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 3b2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3b6:	3c 0a                	cmp    $0xa,%al
 3b8:	74 16                	je     3d0 <gets+0x5f>
 3ba:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 3be:	3c 0d                	cmp    $0xd,%al
 3c0:	74 0e                	je     3d0 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 3c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3c5:	83 c0 01             	add    $0x1,%eax
 3c8:	3b 45 0c             	cmp    0xc(%ebp),%eax
 3cb:	7c b3                	jl     380 <gets+0xf>
 3cd:	eb 01                	jmp    3d0 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 3cf:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 3d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
 3d3:	8b 45 08             	mov    0x8(%ebp),%eax
 3d6:	01 d0                	add    %edx,%eax
 3d8:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
}
 3de:	c9                   	leave  
 3df:	c3                   	ret    

000003e0 <stat>:

int
stat(char *n, struct stat *st)
{
 3e0:	55                   	push   %ebp
 3e1:	89 e5                	mov    %esp,%ebp
 3e3:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 3e6:	83 ec 08             	sub    $0x8,%esp
 3e9:	6a 00                	push   $0x0
 3eb:	ff 75 08             	pushl  0x8(%ebp)
 3ee:	e8 0c 01 00 00       	call   4ff <open>
 3f3:	83 c4 10             	add    $0x10,%esp
 3f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 3f9:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fd:	79 07                	jns    406 <stat+0x26>
    return -1;
 3ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 404:	eb 25                	jmp    42b <stat+0x4b>
  r = fstat(fd, st);
 406:	83 ec 08             	sub    $0x8,%esp
 409:	ff 75 0c             	pushl  0xc(%ebp)
 40c:	ff 75 f4             	pushl  -0xc(%ebp)
 40f:	e8 03 01 00 00       	call   517 <fstat>
 414:	83 c4 10             	add    $0x10,%esp
 417:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 41a:	83 ec 0c             	sub    $0xc,%esp
 41d:	ff 75 f4             	pushl  -0xc(%ebp)
 420:	e8 c2 00 00 00       	call   4e7 <close>
 425:	83 c4 10             	add    $0x10,%esp
  return r;
 428:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 42b:	c9                   	leave  
 42c:	c3                   	ret    

0000042d <atoi>:

int
atoi(const char *s)
{
 42d:	55                   	push   %ebp
 42e:	89 e5                	mov    %esp,%ebp
 430:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 433:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 43a:	eb 25                	jmp    461 <atoi+0x34>
    n = n*10 + *s++ - '0';
 43c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 43f:	89 d0                	mov    %edx,%eax
 441:	c1 e0 02             	shl    $0x2,%eax
 444:	01 d0                	add    %edx,%eax
 446:	01 c0                	add    %eax,%eax
 448:	89 c1                	mov    %eax,%ecx
 44a:	8b 45 08             	mov    0x8(%ebp),%eax
 44d:	8d 50 01             	lea    0x1(%eax),%edx
 450:	89 55 08             	mov    %edx,0x8(%ebp)
 453:	0f b6 00             	movzbl (%eax),%eax
 456:	0f be c0             	movsbl %al,%eax
 459:	01 c8                	add    %ecx,%eax
 45b:	83 e8 30             	sub    $0x30,%eax
 45e:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 461:	8b 45 08             	mov    0x8(%ebp),%eax
 464:	0f b6 00             	movzbl (%eax),%eax
 467:	3c 2f                	cmp    $0x2f,%al
 469:	7e 0a                	jle    475 <atoi+0x48>
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	0f b6 00             	movzbl (%eax),%eax
 471:	3c 39                	cmp    $0x39,%al
 473:	7e c7                	jle    43c <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 475:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 478:	c9                   	leave  
 479:	c3                   	ret    

0000047a <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 47a:	55                   	push   %ebp
 47b:	89 e5                	mov    %esp,%ebp
 47d:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 480:	8b 45 08             	mov    0x8(%ebp),%eax
 483:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 486:	8b 45 0c             	mov    0xc(%ebp),%eax
 489:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 48c:	eb 17                	jmp    4a5 <memmove+0x2b>
    *dst++ = *src++;
 48e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 491:	8d 50 01             	lea    0x1(%eax),%edx
 494:	89 55 fc             	mov    %edx,-0x4(%ebp)
 497:	8b 55 f8             	mov    -0x8(%ebp),%edx
 49a:	8d 4a 01             	lea    0x1(%edx),%ecx
 49d:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 4a0:	0f b6 12             	movzbl (%edx),%edx
 4a3:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 4a5:	8b 45 10             	mov    0x10(%ebp),%eax
 4a8:	8d 50 ff             	lea    -0x1(%eax),%edx
 4ab:	89 55 10             	mov    %edx,0x10(%ebp)
 4ae:	85 c0                	test   %eax,%eax
 4b0:	7f dc                	jg     48e <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 4b2:	8b 45 08             	mov    0x8(%ebp),%eax
}
 4b5:	c9                   	leave  
 4b6:	c3                   	ret    

000004b7 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 4b7:	b8 01 00 00 00       	mov    $0x1,%eax
 4bc:	cd 40                	int    $0x40
 4be:	c3                   	ret    

000004bf <exit>:
SYSCALL(exit)
 4bf:	b8 02 00 00 00       	mov    $0x2,%eax
 4c4:	cd 40                	int    $0x40
 4c6:	c3                   	ret    

000004c7 <wait>:
SYSCALL(wait)
 4c7:	b8 03 00 00 00       	mov    $0x3,%eax
 4cc:	cd 40                	int    $0x40
 4ce:	c3                   	ret    

000004cf <pipe>:
SYSCALL(pipe)
 4cf:	b8 04 00 00 00       	mov    $0x4,%eax
 4d4:	cd 40                	int    $0x40
 4d6:	c3                   	ret    

000004d7 <read>:
SYSCALL(read)
 4d7:	b8 05 00 00 00       	mov    $0x5,%eax
 4dc:	cd 40                	int    $0x40
 4de:	c3                   	ret    

000004df <write>:
SYSCALL(write)
 4df:	b8 10 00 00 00       	mov    $0x10,%eax
 4e4:	cd 40                	int    $0x40
 4e6:	c3                   	ret    

000004e7 <close>:
SYSCALL(close)
 4e7:	b8 15 00 00 00       	mov    $0x15,%eax
 4ec:	cd 40                	int    $0x40
 4ee:	c3                   	ret    

000004ef <kill>:
SYSCALL(kill)
 4ef:	b8 06 00 00 00       	mov    $0x6,%eax
 4f4:	cd 40                	int    $0x40
 4f6:	c3                   	ret    

000004f7 <exec>:
SYSCALL(exec)
 4f7:	b8 07 00 00 00       	mov    $0x7,%eax
 4fc:	cd 40                	int    $0x40
 4fe:	c3                   	ret    

000004ff <open>:
SYSCALL(open)
 4ff:	b8 0f 00 00 00       	mov    $0xf,%eax
 504:	cd 40                	int    $0x40
 506:	c3                   	ret    

00000507 <mknod>:
SYSCALL(mknod)
 507:	b8 11 00 00 00       	mov    $0x11,%eax
 50c:	cd 40                	int    $0x40
 50e:	c3                   	ret    

0000050f <unlink>:
SYSCALL(unlink)
 50f:	b8 12 00 00 00       	mov    $0x12,%eax
 514:	cd 40                	int    $0x40
 516:	c3                   	ret    

00000517 <fstat>:
SYSCALL(fstat)
 517:	b8 08 00 00 00       	mov    $0x8,%eax
 51c:	cd 40                	int    $0x40
 51e:	c3                   	ret    

0000051f <link>:
SYSCALL(link)
 51f:	b8 13 00 00 00       	mov    $0x13,%eax
 524:	cd 40                	int    $0x40
 526:	c3                   	ret    

00000527 <mkdir>:
SYSCALL(mkdir)
 527:	b8 14 00 00 00       	mov    $0x14,%eax
 52c:	cd 40                	int    $0x40
 52e:	c3                   	ret    

0000052f <chdir>:
SYSCALL(chdir)
 52f:	b8 09 00 00 00       	mov    $0x9,%eax
 534:	cd 40                	int    $0x40
 536:	c3                   	ret    

00000537 <dup>:
SYSCALL(dup)
 537:	b8 0a 00 00 00       	mov    $0xa,%eax
 53c:	cd 40                	int    $0x40
 53e:	c3                   	ret    

0000053f <getpid>:
SYSCALL(getpid)
 53f:	b8 0b 00 00 00       	mov    $0xb,%eax
 544:	cd 40                	int    $0x40
 546:	c3                   	ret    

00000547 <sbrk>:
SYSCALL(sbrk)
 547:	b8 0c 00 00 00       	mov    $0xc,%eax
 54c:	cd 40                	int    $0x40
 54e:	c3                   	ret    

0000054f <sleep>:
SYSCALL(sleep)
 54f:	b8 0d 00 00 00       	mov    $0xd,%eax
 554:	cd 40                	int    $0x40
 556:	c3                   	ret    

00000557 <uptime>:
SYSCALL(uptime)
 557:	b8 0e 00 00 00       	mov    $0xe,%eax
 55c:	cd 40                	int    $0x40
 55e:	c3                   	ret    

0000055f <procstat>:
SYSCALL(procstat)
 55f:	b8 16 00 00 00       	mov    $0x16,%eax
 564:	cd 40                	int    $0x40
 566:	c3                   	ret    

00000567 <setpriority>:
SYSCALL(setpriority)
 567:	b8 17 00 00 00       	mov    $0x17,%eax
 56c:	cd 40                	int    $0x40
 56e:	c3                   	ret    

0000056f <semget>:
SYSCALL(semget)
 56f:	b8 18 00 00 00       	mov    $0x18,%eax
 574:	cd 40                	int    $0x40
 576:	c3                   	ret    

00000577 <semfree>:
SYSCALL(semfree)
 577:	b8 19 00 00 00       	mov    $0x19,%eax
 57c:	cd 40                	int    $0x40
 57e:	c3                   	ret    

0000057f <semdown>:
SYSCALL(semdown)
 57f:	b8 1a 00 00 00       	mov    $0x1a,%eax
 584:	cd 40                	int    $0x40
 586:	c3                   	ret    

00000587 <semup>:
SYSCALL(semup)
 587:	b8 1b 00 00 00       	mov    $0x1b,%eax
 58c:	cd 40                	int    $0x40
 58e:	c3                   	ret    
