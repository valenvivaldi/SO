
_prioritytest:     formato del fichero elf32-i386


Desensamblado de la sección .text:

00000000 <printf>:

#define N  1000

void
printf(int fd, char *s, ...)
{
   0:	55                   	push   %ebp
   1:	89 e5                	mov    %esp,%ebp
   3:	83 ec 08             	sub    $0x8,%esp
  write(fd, s, strlen(s));
   6:	83 ec 0c             	sub    $0xc,%esp
   9:	ff 75 0c             	pushl  0xc(%ebp)
   c:	e8 40 01 00 00       	call   151 <strlen>
  11:	83 c4 10             	add    $0x10,%esp
  14:	83 ec 04             	sub    $0x4,%esp
  17:	50                   	push   %eax
  18:	ff 75 0c             	pushl  0xc(%ebp)
  1b:	ff 75 08             	pushl  0x8(%ebp)
  1e:	e8 10 03 00 00       	call   333 <write>
  23:	83 c4 10             	add    $0x10,%esp
}
  26:	90                   	nop
  27:	c9                   	leave  
  28:	c3                   	ret    

00000029 <prioritytest>:

void
prioritytest(void)
{
  29:	55                   	push   %ebp
  2a:	89 e5                	mov    %esp,%ebp
  2c:	83 ec 18             	sub    $0x18,%esp
  int i;
  int pid;
  printf(1, "prioritytest\n");
  2f:	83 ec 08             	sub    $0x8,%esp
  32:	68 e3 03 00 00       	push   $0x3e3
  37:	6a 01                	push   $0x1
  39:	e8 c2 ff ff ff       	call   0 <printf>
  3e:	83 c4 10             	add    $0x10,%esp
    fork();
  41:	e8 c5 02 00 00       	call   30b <fork>
    for (i=0;i<2;i++){
  46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  4d:	eb 12                	jmp    61 <prioritytest+0x38>
      pid=fork();
  4f:	e8 b7 02 00 00       	call   30b <fork>
  54:	89 45 f0             	mov    %eax,-0x10(%ebp)

      if(pid==0){
  57:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  5b:	74 0c                	je     69 <prioritytest+0x40>
{
  int i;
  int pid;
  printf(1, "prioritytest\n");
    fork();
    for (i=0;i<2;i++){
  5d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  61:	83 7d f4 01          	cmpl   $0x1,-0xc(%ebp)
  65:	7e e8                	jle    4f <prioritytest+0x26>
  67:	eb 01                	jmp    6a <prioritytest+0x41>
      pid=fork();

      if(pid==0){
        break;
  69:	90                   	nop
      }
    }

    if(pid != 0){
  6a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  6e:	74 0f                	je     7f <prioritytest+0x56>
      for(;;){
        setpriority(0);
  70:	83 ec 0c             	sub    $0xc,%esp
  73:	6a 00                	push   $0x0
  75:	e8 41 03 00 00       	call   3bb <setpriority>
  7a:	83 c4 10             	add    $0x10,%esp
      }
  7d:	eb f1                	jmp    70 <prioritytest+0x47>
    }
    if(pid == 0){
  7f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  83:	75 19                	jne    9e <prioritytest+0x75>
        //setpriority(3);
        for(;;){
          if(i %2==0){
  85:	8b 45 f4             	mov    -0xc(%ebp),%eax
  88:	83 e0 01             	and    $0x1,%eax
  8b:	85 c0                	test   %eax,%eax
  8d:	75 f6                	jne    85 <prioritytest+0x5c>
            setpriority(2);
  8f:	83 ec 0c             	sub    $0xc,%esp
  92:	6a 02                	push   $0x2
  94:	e8 22 03 00 00       	call   3bb <setpriority>
  99:	83 c4 10             	add    $0x10,%esp
          }
        }
  9c:	eb e7                	jmp    85 <prioritytest+0x5c>
      }
    }
  9e:	90                   	nop
  9f:	c9                   	leave  
  a0:	c3                   	ret    

000000a1 <main>:



int
main(void)
{
  a1:	8d 4c 24 04          	lea    0x4(%esp),%ecx
  a5:	83 e4 f0             	and    $0xfffffff0,%esp
  a8:	ff 71 fc             	pushl  -0x4(%ecx)
  ab:	55                   	push   %ebp
  ac:	89 e5                	mov    %esp,%ebp
  ae:	51                   	push   %ecx
  af:	83 ec 04             	sub    $0x4,%esp
  prioritytest();
  b2:	e8 72 ff ff ff       	call   29 <prioritytest>
  exit();
  b7:	e8 57 02 00 00       	call   313 <exit>

000000bc <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  bc:	55                   	push   %ebp
  bd:	89 e5                	mov    %esp,%ebp
  bf:	57                   	push   %edi
  c0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  c4:	8b 55 10             	mov    0x10(%ebp),%edx
  c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ca:	89 cb                	mov    %ecx,%ebx
  cc:	89 df                	mov    %ebx,%edi
  ce:	89 d1                	mov    %edx,%ecx
  d0:	fc                   	cld    
  d1:	f3 aa                	rep stos %al,%es:(%edi)
  d3:	89 ca                	mov    %ecx,%edx
  d5:	89 fb                	mov    %edi,%ebx
  d7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  da:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  dd:	90                   	nop
  de:	5b                   	pop    %ebx
  df:	5f                   	pop    %edi
  e0:	5d                   	pop    %ebp
  e1:	c3                   	ret    

000000e2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  e8:	8b 45 08             	mov    0x8(%ebp),%eax
  eb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ee:	90                   	nop
  ef:	8b 45 08             	mov    0x8(%ebp),%eax
  f2:	8d 50 01             	lea    0x1(%eax),%edx
  f5:	89 55 08             	mov    %edx,0x8(%ebp)
  f8:	8b 55 0c             	mov    0xc(%ebp),%edx
  fb:	8d 4a 01             	lea    0x1(%edx),%ecx
  fe:	89 4d 0c             	mov    %ecx,0xc(%ebp)
 101:	0f b6 12             	movzbl (%edx),%edx
 104:	88 10                	mov    %dl,(%eax)
 106:	0f b6 00             	movzbl (%eax),%eax
 109:	84 c0                	test   %al,%al
 10b:	75 e2                	jne    ef <strcpy+0xd>
    ;
  return os;
 10d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 110:	c9                   	leave  
 111:	c3                   	ret    

00000112 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 112:	55                   	push   %ebp
 113:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
 115:	eb 08                	jmp    11f <strcmp+0xd>
    p++, q++;
 117:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 11b:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
 11f:	8b 45 08             	mov    0x8(%ebp),%eax
 122:	0f b6 00             	movzbl (%eax),%eax
 125:	84 c0                	test   %al,%al
 127:	74 10                	je     139 <strcmp+0x27>
 129:	8b 45 08             	mov    0x8(%ebp),%eax
 12c:	0f b6 10             	movzbl (%eax),%edx
 12f:	8b 45 0c             	mov    0xc(%ebp),%eax
 132:	0f b6 00             	movzbl (%eax),%eax
 135:	38 c2                	cmp    %al,%dl
 137:	74 de                	je     117 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 139:	8b 45 08             	mov    0x8(%ebp),%eax
 13c:	0f b6 00             	movzbl (%eax),%eax
 13f:	0f b6 d0             	movzbl %al,%edx
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	0f b6 00             	movzbl (%eax),%eax
 148:	0f b6 c0             	movzbl %al,%eax
 14b:	29 c2                	sub    %eax,%edx
 14d:	89 d0                	mov    %edx,%eax
}
 14f:	5d                   	pop    %ebp
 150:	c3                   	ret    

00000151 <strlen>:

uint
strlen(char *s)
{
 151:	55                   	push   %ebp
 152:	89 e5                	mov    %esp,%ebp
 154:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 157:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 15e:	eb 04                	jmp    164 <strlen+0x13>
 160:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 164:	8b 55 fc             	mov    -0x4(%ebp),%edx
 167:	8b 45 08             	mov    0x8(%ebp),%eax
 16a:	01 d0                	add    %edx,%eax
 16c:	0f b6 00             	movzbl (%eax),%eax
 16f:	84 c0                	test   %al,%al
 171:	75 ed                	jne    160 <strlen+0xf>
    ;
  return n;
 173:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 176:	c9                   	leave  
 177:	c3                   	ret    

00000178 <memset>:

void*
memset(void *dst, int c, uint n)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 17b:	8b 45 10             	mov    0x10(%ebp),%eax
 17e:	50                   	push   %eax
 17f:	ff 75 0c             	pushl  0xc(%ebp)
 182:	ff 75 08             	pushl  0x8(%ebp)
 185:	e8 32 ff ff ff       	call   bc <stosb>
 18a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 18d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 190:	c9                   	leave  
 191:	c3                   	ret    

00000192 <strchr>:

char*
strchr(const char *s, char c)
{
 192:	55                   	push   %ebp
 193:	89 e5                	mov    %esp,%ebp
 195:	83 ec 04             	sub    $0x4,%esp
 198:	8b 45 0c             	mov    0xc(%ebp),%eax
 19b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 19e:	eb 14                	jmp    1b4 <strchr+0x22>
    if(*s == c)
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	0f b6 00             	movzbl (%eax),%eax
 1a6:	3a 45 fc             	cmp    -0x4(%ebp),%al
 1a9:	75 05                	jne    1b0 <strchr+0x1e>
      return (char*)s;
 1ab:	8b 45 08             	mov    0x8(%ebp),%eax
 1ae:	eb 13                	jmp    1c3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 1b0:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 1b4:	8b 45 08             	mov    0x8(%ebp),%eax
 1b7:	0f b6 00             	movzbl (%eax),%eax
 1ba:	84 c0                	test   %al,%al
 1bc:	75 e2                	jne    1a0 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 1be:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1c3:	c9                   	leave  
 1c4:	c3                   	ret    

000001c5 <gets>:

char*
gets(char *buf, int max)
{
 1c5:	55                   	push   %ebp
 1c6:	89 e5                	mov    %esp,%ebp
 1c8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1cb:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1d2:	eb 42                	jmp    216 <gets+0x51>
    cc = read(0, &c, 1);
 1d4:	83 ec 04             	sub    $0x4,%esp
 1d7:	6a 01                	push   $0x1
 1d9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1dc:	50                   	push   %eax
 1dd:	6a 00                	push   $0x0
 1df:	e8 47 01 00 00       	call   32b <read>
 1e4:	83 c4 10             	add    $0x10,%esp
 1e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ea:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ee:	7e 33                	jle    223 <gets+0x5e>
      break;
    buf[i++] = c;
 1f0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f3:	8d 50 01             	lea    0x1(%eax),%edx
 1f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1f9:	89 c2                	mov    %eax,%edx
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	01 c2                	add    %eax,%edx
 200:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 204:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 206:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 20a:	3c 0a                	cmp    $0xa,%al
 20c:	74 16                	je     224 <gets+0x5f>
 20e:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 212:	3c 0d                	cmp    $0xd,%al
 214:	74 0e                	je     224 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 216:	8b 45 f4             	mov    -0xc(%ebp),%eax
 219:	83 c0 01             	add    $0x1,%eax
 21c:	3b 45 0c             	cmp    0xc(%ebp),%eax
 21f:	7c b3                	jl     1d4 <gets+0xf>
 221:	eb 01                	jmp    224 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 223:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 224:	8b 55 f4             	mov    -0xc(%ebp),%edx
 227:	8b 45 08             	mov    0x8(%ebp),%eax
 22a:	01 d0                	add    %edx,%eax
 22c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 22f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 232:	c9                   	leave  
 233:	c3                   	ret    

00000234 <stat>:

int
stat(char *n, struct stat *st)
{
 234:	55                   	push   %ebp
 235:	89 e5                	mov    %esp,%ebp
 237:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 23a:	83 ec 08             	sub    $0x8,%esp
 23d:	6a 00                	push   $0x0
 23f:	ff 75 08             	pushl  0x8(%ebp)
 242:	e8 0c 01 00 00       	call   353 <open>
 247:	83 c4 10             	add    $0x10,%esp
 24a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 24d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 251:	79 07                	jns    25a <stat+0x26>
    return -1;
 253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 258:	eb 25                	jmp    27f <stat+0x4b>
  r = fstat(fd, st);
 25a:	83 ec 08             	sub    $0x8,%esp
 25d:	ff 75 0c             	pushl  0xc(%ebp)
 260:	ff 75 f4             	pushl  -0xc(%ebp)
 263:	e8 03 01 00 00       	call   36b <fstat>
 268:	83 c4 10             	add    $0x10,%esp
 26b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 26e:	83 ec 0c             	sub    $0xc,%esp
 271:	ff 75 f4             	pushl  -0xc(%ebp)
 274:	e8 c2 00 00 00       	call   33b <close>
 279:	83 c4 10             	add    $0x10,%esp
  return r;
 27c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 27f:	c9                   	leave  
 280:	c3                   	ret    

00000281 <atoi>:

int
atoi(const char *s)
{
 281:	55                   	push   %ebp
 282:	89 e5                	mov    %esp,%ebp
 284:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 287:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 28e:	eb 25                	jmp    2b5 <atoi+0x34>
    n = n*10 + *s++ - '0';
 290:	8b 55 fc             	mov    -0x4(%ebp),%edx
 293:	89 d0                	mov    %edx,%eax
 295:	c1 e0 02             	shl    $0x2,%eax
 298:	01 d0                	add    %edx,%eax
 29a:	01 c0                	add    %eax,%eax
 29c:	89 c1                	mov    %eax,%ecx
 29e:	8b 45 08             	mov    0x8(%ebp),%eax
 2a1:	8d 50 01             	lea    0x1(%eax),%edx
 2a4:	89 55 08             	mov    %edx,0x8(%ebp)
 2a7:	0f b6 00             	movzbl (%eax),%eax
 2aa:	0f be c0             	movsbl %al,%eax
 2ad:	01 c8                	add    %ecx,%eax
 2af:	83 e8 30             	sub    $0x30,%eax
 2b2:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2b5:	8b 45 08             	mov    0x8(%ebp),%eax
 2b8:	0f b6 00             	movzbl (%eax),%eax
 2bb:	3c 2f                	cmp    $0x2f,%al
 2bd:	7e 0a                	jle    2c9 <atoi+0x48>
 2bf:	8b 45 08             	mov    0x8(%ebp),%eax
 2c2:	0f b6 00             	movzbl (%eax),%eax
 2c5:	3c 39                	cmp    $0x39,%al
 2c7:	7e c7                	jle    290 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2c9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2cc:	c9                   	leave  
 2cd:	c3                   	ret    

000002ce <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ce:	55                   	push   %ebp
 2cf:	89 e5                	mov    %esp,%ebp
 2d1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2d4:	8b 45 08             	mov    0x8(%ebp),%eax
 2d7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2da:	8b 45 0c             	mov    0xc(%ebp),%eax
 2dd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2e0:	eb 17                	jmp    2f9 <memmove+0x2b>
    *dst++ = *src++;
 2e2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2e5:	8d 50 01             	lea    0x1(%eax),%edx
 2e8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2eb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ee:	8d 4a 01             	lea    0x1(%edx),%ecx
 2f1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2f4:	0f b6 12             	movzbl (%edx),%edx
 2f7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2f9:	8b 45 10             	mov    0x10(%ebp),%eax
 2fc:	8d 50 ff             	lea    -0x1(%eax),%edx
 2ff:	89 55 10             	mov    %edx,0x10(%ebp)
 302:	85 c0                	test   %eax,%eax
 304:	7f dc                	jg     2e2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 306:	8b 45 08             	mov    0x8(%ebp),%eax
}
 309:	c9                   	leave  
 30a:	c3                   	ret    

0000030b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 30b:	b8 01 00 00 00       	mov    $0x1,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <exit>:
SYSCALL(exit)
 313:	b8 02 00 00 00       	mov    $0x2,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <wait>:
SYSCALL(wait)
 31b:	b8 03 00 00 00       	mov    $0x3,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <pipe>:
SYSCALL(pipe)
 323:	b8 04 00 00 00       	mov    $0x4,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <read>:
SYSCALL(read)
 32b:	b8 05 00 00 00       	mov    $0x5,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <write>:
SYSCALL(write)
 333:	b8 10 00 00 00       	mov    $0x10,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <close>:
SYSCALL(close)
 33b:	b8 15 00 00 00       	mov    $0x15,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <kill>:
SYSCALL(kill)
 343:	b8 06 00 00 00       	mov    $0x6,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <exec>:
SYSCALL(exec)
 34b:	b8 07 00 00 00       	mov    $0x7,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <open>:
SYSCALL(open)
 353:	b8 0f 00 00 00       	mov    $0xf,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <mknod>:
SYSCALL(mknod)
 35b:	b8 11 00 00 00       	mov    $0x11,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <unlink>:
SYSCALL(unlink)
 363:	b8 12 00 00 00       	mov    $0x12,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <fstat>:
SYSCALL(fstat)
 36b:	b8 08 00 00 00       	mov    $0x8,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <link>:
SYSCALL(link)
 373:	b8 13 00 00 00       	mov    $0x13,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <mkdir>:
SYSCALL(mkdir)
 37b:	b8 14 00 00 00       	mov    $0x14,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <chdir>:
SYSCALL(chdir)
 383:	b8 09 00 00 00       	mov    $0x9,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <dup>:
SYSCALL(dup)
 38b:	b8 0a 00 00 00       	mov    $0xa,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <getpid>:
SYSCALL(getpid)
 393:	b8 0b 00 00 00       	mov    $0xb,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <sbrk>:
SYSCALL(sbrk)
 39b:	b8 0c 00 00 00       	mov    $0xc,%eax
 3a0:	cd 40                	int    $0x40
 3a2:	c3                   	ret    

000003a3 <sleep>:
SYSCALL(sleep)
 3a3:	b8 0d 00 00 00       	mov    $0xd,%eax
 3a8:	cd 40                	int    $0x40
 3aa:	c3                   	ret    

000003ab <uptime>:
SYSCALL(uptime)
 3ab:	b8 0e 00 00 00       	mov    $0xe,%eax
 3b0:	cd 40                	int    $0x40
 3b2:	c3                   	ret    

000003b3 <procstat>:
SYSCALL(procstat)
 3b3:	b8 16 00 00 00       	mov    $0x16,%eax
 3b8:	cd 40                	int    $0x40
 3ba:	c3                   	ret    

000003bb <setpriority>:
SYSCALL(setpriority)
 3bb:	b8 17 00 00 00       	mov    $0x17,%eax
 3c0:	cd 40                	int    $0x40
 3c2:	c3                   	ret    

000003c3 <semget>:
SYSCALL(semget)
 3c3:	b8 18 00 00 00       	mov    $0x18,%eax
 3c8:	cd 40                	int    $0x40
 3ca:	c3                   	ret    

000003cb <semfree>:
SYSCALL(semfree)
 3cb:	b8 19 00 00 00       	mov    $0x19,%eax
 3d0:	cd 40                	int    $0x40
 3d2:	c3                   	ret    

000003d3 <semdown>:
SYSCALL(semdown)
 3d3:	b8 1a 00 00 00       	mov    $0x1a,%eax
 3d8:	cd 40                	int    $0x40
 3da:	c3                   	ret    

000003db <semup>:
SYSCALL(semup)
 3db:	b8 1b 00 00 00       	mov    $0x1b,%eax
 3e0:	cd 40                	int    $0x40
 3e2:	c3                   	ret    
