
kernel:     formato del fichero elf32-i386


Desensamblado de la sección .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 b0 10 00       	mov    $0x10b000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 70 d6 10 80       	mov    $0x8010d670,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f6 37 10 80       	mov    $0x801037f6,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 4c 8e 10 80       	push   $0x80108e4c
80100042:	68 80 d6 10 80       	push   $0x8010d680
80100047:	e8 29 57 00 00       	call   80105775 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 90 15 11 80 84 	movl   $0x80111584,0x80111590
80100056:	15 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 94 15 11 80 84 	movl   $0x80111584,0x80111594
80100060:	15 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 b4 d6 10 80 	movl   $0x8010d6b4,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 94 15 11 80       	mov    0x80111594,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 94 15 11 80       	mov    %eax,0x80111594

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 84 15 11 80       	mov    $0x80111584,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for sector on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint sector)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 80 d6 10 80       	push   $0x8010d680
801000c1:	e8 d1 56 00 00       	call   80105797 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 94 15 11 80       	mov    0x80111594,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->sector == sector){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 80 d6 10 80       	push   $0x8010d680
8010010c:	e8 ed 56 00 00       	call   801057fe <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 80 d6 10 80       	push   $0x8010d680
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 18 4d 00 00       	call   80104e44 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the sector already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 90 15 11 80       	mov    0x80111590,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->sector = sector;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 80 d6 10 80       	push   $0x8010d680
80100188:	e8 71 56 00 00       	call   801057fe <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 84 15 11 80 	cmpl   $0x80111584,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 53 8e 10 80       	push   $0x80108e53
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated disk sector.
struct buf*
bread(uint dev, uint sector)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, sector);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID))
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 85 26 00 00       	call   8010286c <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 64 8e 10 80       	push   $0x80108e64
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 44 26 00 00       	call   8010286c <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 6b 8e 10 80       	push   $0x80108e6b
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 80 d6 10 80       	push   $0x8010d680
80100255:	e8 3d 55 00 00       	call   80105797 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 94 15 11 80    	mov    0x80111594,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 84 15 11 80 	movl   $0x80111584,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 94 15 11 80       	mov    0x80111594,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 94 15 11 80       	mov    %eax,0x80111594

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 9b 4c 00 00       	call   80104f59 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 80 d6 10 80       	push   $0x8010d680
801002c9:	e8 30 55 00 00       	call   801057fe <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 a0 10 80 	movzbl -0x7fef5ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 14 c6 10 80       	mov    0x8010c614,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 e0 c5 10 80       	push   $0x8010c5e0
801003e2:	e8 b0 53 00 00       	call   80105797 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 72 8e 10 80       	push   $0x80108e72
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec 7b 8e 10 80 	movl   $0x80108e7b,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 e0 c5 10 80       	push   $0x8010c5e0
8010055b:	e8 9e 52 00 00       	call   801057fe <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 14 c6 10 80 00 	movl   $0x0,0x8010c614
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 82 8e 10 80       	push   $0x80108e82
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 91 8e 10 80       	push   $0x80108e91
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 89 52 00 00       	call   80105850 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 93 8e 10 80       	push   $0x80108e93
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 c0 c5 10 80 01 	movl   $0x1,0x8010c5c0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 a0 10 80    	mov    0x8010a000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 d9 53 00 00       	call   80105ab9 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 a0 10 80       	mov    0x8010a000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 f0 52 00 00       	call   801059fa <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 a0 10 80       	mov    0x8010a000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 c0 c5 10 80       	mov    0x8010c5c0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 33 6d 00 00       	call   801074d2 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 26 6d 00 00       	call   801074d2 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 19 6d 00 00       	call   801074d2 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 09 6d 00 00       	call   801074d2 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 a0 17 11 80       	push   $0x801117a0
801007eb:	e8 a7 4f 00 00       	call   80105797 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 f8 47 00 00       	call   8010501b <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
8010084b:	a1 58 18 11 80       	mov    0x80111858,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
80100879:	a1 58 18 11 80       	mov    0x80111858,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 5c 18 11 80       	mov    0x8011185c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 5c 18 11 80       	mov    %eax,0x8011185c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 5c 18 11 80    	mov    0x8011185c,%edx
801008b8:	a1 54 18 11 80       	mov    0x80111854,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 5c 18 11 80       	mov    0x8011185c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 5c 18 11 80    	mov    %edx,0x8011185c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 d4 17 11 80    	mov    %dl,-0x7feee82c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100912:	8b 15 54 18 11 80    	mov    0x80111854,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 5c 18 11 80       	mov    0x8011185c,%eax
80100924:	a3 58 18 11 80       	mov    %eax,0x80111858
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 54 18 11 80       	push   $0x80111854
80100931:	e8 23 46 00 00       	call   80104f59 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 a0 17 11 80       	push   $0x801117a0
80100954:	e8 a5 4e 00 00       	call   801057fe <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 f3 10 00 00       	call   80101a63 <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 a0 17 11 80       	push   $0x801117a0
80100981:	e8 11 4e 00 00       	call   80105797 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 a0 17 11 80       	push   $0x801117a0
801009a3:	e8 56 4e 00 00       	call   801057fe <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 55 0f 00 00       	call   8010190b <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 a0 17 11 80       	push   $0x801117a0
801009cb:	68 54 18 11 80       	push   $0x80111854
801009d0:	e8 6f 44 00 00       	call   80104e44 <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 54 18 11 80    	mov    0x80111854,%edx
801009de:	a1 58 18 11 80       	mov    0x80111858,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 54 18 11 80       	mov    0x80111854,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 54 18 11 80    	mov    %edx,0x80111854
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 d4 17 11 80 	movzbl -0x7feee82c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 54 18 11 80       	mov    0x80111854,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 54 18 11 80       	mov    %eax,0x80111854
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 a0 17 11 80       	push   $0x801117a0
80100a4e:	e8 ab 4d 00 00       	call   801057fe <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 aa 0e 00 00       	call   8010190b <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 e2 0f 00 00       	call   80101a63 <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 e0 c5 10 80       	push   $0x8010c5e0
80100a8c:	e8 06 4d 00 00       	call   80105797 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 e0 c5 10 80       	push   $0x8010c5e0
80100ace:	e8 2b 4d 00 00       	call   801057fe <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 2a 0e 00 00       	call   8010190b <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 97 8e 10 80       	push   $0x80108e97
80100af7:	68 e0 c5 10 80       	push   $0x8010c5e0
80100afc:	e8 74 4c 00 00       	call   80105775 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 9f 8e 10 80       	push   $0x80108e9f
80100b0c:	68 a0 17 11 80       	push   $0x801117a0
80100b11:	e8 5f 4c 00 00       	call   80105775 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 0c 22 11 80 70 	movl   $0x80100a70,0x8011220c
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 08 22 11 80 5f 	movl   $0x8010095f,0x80112208
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 14 c6 10 80 01 	movl   $0x1,0x8010c614
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 5b 33 00 00       	call   80103e9c <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 e9 1e 00 00       	call   80102a39 <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 50 29 00 00       	call   801034b4 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 54 19 00 00       	call   801024c3 <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 c0 29 00 00       	call   80103540 <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 ce 03 00 00       	jmp    80100f58 <exec+0x402>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 76 0d 00 00       	call   8010190b <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 c1 12 00 00       	call   80101e73 <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 49 03 00 00    	jbe    80100f07 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 3b 03 00 00    	jne    80100f0a <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 53 7a 00 00       	call   80108627 <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 2c 03 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 61 12 00 00       	call   80101e73 <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 f2 02 00 00    	jne    80100f10 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 d6 02 00 00    	jb     80100f13 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 74 7d 00 00       	call   801089ce <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 ac 02 00 00    	je     80100f16 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c70:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 6a 7c 00 00       	call   801088f7 <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 81 02 00 00    	js     80100f19 <exec+0x3c3>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 ff 0e 00 00       	call   80101bc5 <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 72 28 00 00       	call   80103540 <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	05 00 20 00 00       	add    $0x2000,%eax
80100ced:	83 ec 04             	sub    $0x4,%esp
80100cf0:	50                   	push   %eax
80100cf1:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf7:	e8 d2 7c 00 00       	call   801089ce <allocuvm>
80100cfc:	83 c4 10             	add    $0x10,%esp
80100cff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d06:	0f 84 10 02 00 00    	je     80100f1c <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d14:	83 ec 08             	sub    $0x8,%esp
80100d17:	50                   	push   %eax
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 d4 7e 00 00       	call   80108bf4 <clearpteu>
80100d20:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d26:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d30:	e9 96 00 00 00       	jmp    80100dcb <exec+0x275>
    if(argc >= MAXARG)
80100d35:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d39:	0f 87 e0 01 00 00    	ja     80100f1f <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 d0                	add    %edx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	83 ec 0c             	sub    $0xc,%esp
80100d53:	50                   	push   %eax
80100d54:	e8 ee 4e 00 00       	call   80105c47 <strlen>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	89 c2                	mov    %eax,%edx
80100d5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d61:	29 d0                	sub    %edx,%eax
80100d63:	83 e8 01             	sub    $0x1,%eax
80100d66:	83 e0 fc             	and    $0xfffffffc,%eax
80100d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d79:	01 d0                	add    %edx,%eax
80100d7b:	8b 00                	mov    (%eax),%eax
80100d7d:	83 ec 0c             	sub    $0xc,%esp
80100d80:	50                   	push   %eax
80100d81:	e8 c1 4e 00 00       	call   80105c47 <strlen>
80100d86:	83 c4 10             	add    $0x10,%esp
80100d89:	83 c0 01             	add    $0x1,%eax
80100d8c:	89 c1                	mov    %eax,%ecx
80100d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9b:	01 d0                	add    %edx,%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	51                   	push   %ecx
80100da0:	50                   	push   %eax
80100da1:	ff 75 dc             	pushl  -0x24(%ebp)
80100da4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da7:	e8 ff 7f 00 00       	call   80108dab <copyout>
80100dac:	83 c4 10             	add    $0x10,%esp
80100daf:	85 c0                	test   %eax,%eax
80100db1:	0f 88 6b 01 00 00    	js     80100f22 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	8d 50 03             	lea    0x3(%eax),%edx
80100dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc0:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd8:	01 d0                	add    %edx,%eax
80100dda:	8b 00                	mov    (%eax),%eax
80100ddc:	85 c0                	test   %eax,%eax
80100dde:	0f 85 51 ff ff ff    	jne    80100d35 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	83 c0 03             	add    $0x3,%eax
80100dea:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df1:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df5:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dfc:	ff ff ff 
  ustack[1] = argc;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e23:	83 c0 04             	add    $0x4,%eax
80100e26:	c1 e0 02             	shl    $0x2,%eax
80100e29:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 04             	add    $0x4,%eax
80100e32:	c1 e0 02             	shl    $0x2,%eax
80100e35:	50                   	push   %eax
80100e36:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e3c:	50                   	push   %eax
80100e3d:	ff 75 dc             	pushl  -0x24(%ebp)
80100e40:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e43:	e8 63 7f 00 00       	call   80108dab <copyout>
80100e48:	83 c4 10             	add    $0x10,%esp
80100e4b:	85 c0                	test   %eax,%eax
80100e4d:	0f 88 d2 00 00 00    	js     80100f25 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e53:	8b 45 08             	mov    0x8(%ebp),%eax
80100e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e5f:	eb 17                	jmp    80100e78 <exec+0x322>
    if(*s == '/')
80100e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e64:	0f b6 00             	movzbl (%eax),%eax
80100e67:	3c 2f                	cmp    $0x2f,%al
80100e69:	75 09                	jne    80100e74 <exec+0x31e>
      last = s+1;
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	83 c0 01             	add    $0x1,%eax
80100e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7b:	0f b6 00             	movzbl (%eax),%eax
80100e7e:	84 c0                	test   %al,%al
80100e80:	75 df                	jne    80100e61 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e88:	83 c0 6c             	add    $0x6c,%eax
80100e8b:	83 ec 04             	sub    $0x4,%esp
80100e8e:	6a 10                	push   $0x10
80100e90:	ff 75 f0             	pushl  -0x10(%ebp)
80100e93:	50                   	push   %eax
80100e94:	e8 64 4d 00 00       	call   80105bfd <safestrcpy>
80100e99:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea2:	8b 40 04             	mov    0x4(%eax),%eax
80100ea5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ebd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ebf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec5:	8b 40 18             	mov    0x18(%eax),%eax
80100ec8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ece:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	8b 40 18             	mov    0x18(%eax),%eax
80100eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100edd:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	50                   	push   %eax
80100eea:	e8 1f 78 00 00       	call   8010870e <switchuvm>
80100eef:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ef2:	83 ec 0c             	sub    $0xc,%esp
80100ef5:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef8:	e8 57 7c 00 00       	call   80108b54 <freevm>
80100efd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f00:	b8 00 00 00 00       	mov    $0x0,%eax
80100f05:	eb 51                	jmp    80100f58 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f07:	90                   	nop
80100f08:	eb 1c                	jmp    80100f26 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 19                	jmp    80100f26 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 16                	jmp    80100f26 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 13                	jmp    80100f26 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 10                	jmp    80100f26 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f16:	90                   	nop
80100f17:	eb 0d                	jmp    80100f26 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f19:	90                   	nop
80100f1a:	eb 0a                	jmp    80100f26 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f1c:	90                   	nop
80100f1d:	eb 07                	jmp    80100f26 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f1f:	90                   	nop
80100f20:	eb 04                	jmp    80100f26 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f22:	90                   	nop
80100f23:	eb 01                	jmp    80100f26 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f25:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f26:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f2a:	74 0e                	je     80100f3a <exec+0x3e4>
    freevm(pgdir);
80100f2c:	83 ec 0c             	sub    $0xc,%esp
80100f2f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f32:	e8 1d 7c 00 00       	call   80108b54 <freevm>
80100f37:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f3e:	74 13                	je     80100f53 <exec+0x3fd>
    iunlockput(ip);
80100f40:	83 ec 0c             	sub    $0xc,%esp
80100f43:	ff 75 d8             	pushl  -0x28(%ebp)
80100f46:	e8 7a 0c 00 00       	call   80101bc5 <iunlockput>
80100f4b:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f4e:	e8 ed 25 00 00       	call   80103540 <end_op>
  }
  return -1;
80100f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f58:	c9                   	leave  
80100f59:	c3                   	ret    

80100f5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f5a:	55                   	push   %ebp
80100f5b:	89 e5                	mov    %esp,%ebp
80100f5d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f60:	83 ec 08             	sub    $0x8,%esp
80100f63:	68 a5 8e 10 80       	push   $0x80108ea5
80100f68:	68 60 18 11 80       	push   $0x80111860
80100f6d:	e8 03 48 00 00       	call   80105775 <initlock>
80100f72:	83 c4 10             	add    $0x10,%esp
}
80100f75:	90                   	nop
80100f76:	c9                   	leave  
80100f77:	c3                   	ret    

80100f78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f78:	55                   	push   %ebp
80100f79:	89 e5                	mov    %esp,%ebp
80100f7b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f7e:	83 ec 0c             	sub    $0xc,%esp
80100f81:	68 60 18 11 80       	push   $0x80111860
80100f86:	e8 0c 48 00 00       	call   80105797 <acquire>
80100f8b:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f8e:	c7 45 f4 94 18 11 80 	movl   $0x80111894,-0xc(%ebp)
80100f95:	eb 2d                	jmp    80100fc4 <filealloc+0x4c>
    if(f->ref == 0){
80100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9a:	8b 40 04             	mov    0x4(%eax),%eax
80100f9d:	85 c0                	test   %eax,%eax
80100f9f:	75 1f                	jne    80100fc0 <filealloc+0x48>
      f->ref = 1;
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	68 60 18 11 80       	push   $0x80111860
80100fb3:	e8 46 48 00 00       	call   801057fe <release>
80100fb8:	83 c4 10             	add    $0x10,%esp
      return f;
80100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbe:	eb 23                	jmp    80100fe3 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc0:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fc4:	b8 f4 21 11 80       	mov    $0x801121f4,%eax
80100fc9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fcc:	72 c9                	jb     80100f97 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fce:	83 ec 0c             	sub    $0xc,%esp
80100fd1:	68 60 18 11 80       	push   $0x80111860
80100fd6:	e8 23 48 00 00       	call   801057fe <release>
80100fdb:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe3:	c9                   	leave  
80100fe4:	c3                   	ret    

80100fe5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe5:	55                   	push   %ebp
80100fe6:	89 e5                	mov    %esp,%ebp
80100fe8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100feb:	83 ec 0c             	sub    $0xc,%esp
80100fee:	68 60 18 11 80       	push   $0x80111860
80100ff3:	e8 9f 47 00 00       	call   80105797 <acquire>
80100ff8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0d                	jg     80101012 <filedup+0x2d>
    panic("filedup");
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	68 ac 8e 10 80       	push   $0x80108eac
8010100d:	e8 54 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101012:	8b 45 08             	mov    0x8(%ebp),%eax
80101015:	8b 40 04             	mov    0x4(%eax),%eax
80101018:	8d 50 01             	lea    0x1(%eax),%edx
8010101b:	8b 45 08             	mov    0x8(%ebp),%eax
8010101e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101021:	83 ec 0c             	sub    $0xc,%esp
80101024:	68 60 18 11 80       	push   $0x80111860
80101029:	e8 d0 47 00 00       	call   801057fe <release>
8010102e:	83 c4 10             	add    $0x10,%esp
  return f;
80101031:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101034:	c9                   	leave  
80101035:	c3                   	ret    

80101036 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101036:	55                   	push   %ebp
80101037:	89 e5                	mov    %esp,%ebp
80101039:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 60 18 11 80       	push   $0x80111860
80101044:	e8 4e 47 00 00       	call   80105797 <acquire>
80101049:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
8010104f:	8b 40 04             	mov    0x4(%eax),%eax
80101052:	85 c0                	test   %eax,%eax
80101054:	7f 0d                	jg     80101063 <fileclose+0x2d>
    panic("fileclose");
80101056:	83 ec 0c             	sub    $0xc,%esp
80101059:	68 b4 8e 10 80       	push   $0x80108eb4
8010105e:	e8 03 f5 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	8d 50 ff             	lea    -0x1(%eax),%edx
8010106c:	8b 45 08             	mov    0x8(%ebp),%eax
8010106f:	89 50 04             	mov    %edx,0x4(%eax)
80101072:	8b 45 08             	mov    0x8(%ebp),%eax
80101075:	8b 40 04             	mov    0x4(%eax),%eax
80101078:	85 c0                	test   %eax,%eax
8010107a:	7e 15                	jle    80101091 <fileclose+0x5b>
    release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 60 18 11 80       	push   $0x80111860
80101084:	e8 75 47 00 00       	call   801057fe <release>
80101089:	83 c4 10             	add    $0x10,%esp
8010108c:	e9 8b 00 00 00       	jmp    8010111c <fileclose+0xe6>
    return;
  }
  ff = *f;
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
80101094:	8b 10                	mov    (%eax),%edx
80101096:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101099:	8b 50 04             	mov    0x4(%eax),%edx
8010109c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010109f:	8b 50 08             	mov    0x8(%eax),%edx
801010a2:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010a5:	8b 50 0c             	mov    0xc(%eax),%edx
801010a8:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010ab:	8b 50 10             	mov    0x10(%eax),%edx
801010ae:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010b1:	8b 40 14             	mov    0x14(%eax),%eax
801010b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010c1:	8b 45 08             	mov    0x8(%ebp),%eax
801010c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 60 18 11 80       	push   $0x80111860
801010d2:	e8 27 47 00 00       	call   801057fe <release>
801010d7:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010dd:	83 f8 01             	cmp    $0x1,%eax
801010e0:	75 19                	jne    801010fb <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010e2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010e6:	0f be d0             	movsbl %al,%edx
801010e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010ec:	83 ec 08             	sub    $0x8,%esp
801010ef:	52                   	push   %edx
801010f0:	50                   	push   %eax
801010f1:	e8 0f 30 00 00       	call   80104105 <pipeclose>
801010f6:	83 c4 10             	add    $0x10,%esp
801010f9:	eb 21                	jmp    8010111c <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010fe:	83 f8 02             	cmp    $0x2,%eax
80101101:	75 19                	jne    8010111c <fileclose+0xe6>
    begin_op();
80101103:	e8 ac 23 00 00       	call   801034b4 <begin_op>
    iput(ff.ip);
80101108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	50                   	push   %eax
8010110f:	e8 c1 09 00 00       	call   80101ad5 <iput>
80101114:	83 c4 10             	add    $0x10,%esp
    end_op();
80101117:	e8 24 24 00 00       	call   80103540 <end_op>
  }
}
8010111c:	c9                   	leave  
8010111d:	c3                   	ret    

8010111e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010111e:	55                   	push   %ebp
8010111f:	89 e5                	mov    %esp,%ebp
80101121:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 00                	mov    (%eax),%eax
80101129:	83 f8 02             	cmp    $0x2,%eax
8010112c:	75 40                	jne    8010116e <filestat+0x50>
    ilock(f->ip);
8010112e:	8b 45 08             	mov    0x8(%ebp),%eax
80101131:	8b 40 10             	mov    0x10(%eax),%eax
80101134:	83 ec 0c             	sub    $0xc,%esp
80101137:	50                   	push   %eax
80101138:	e8 ce 07 00 00       	call   8010190b <ilock>
8010113d:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	83 ec 08             	sub    $0x8,%esp
80101149:	ff 75 0c             	pushl  0xc(%ebp)
8010114c:	50                   	push   %eax
8010114d:	e8 db 0c 00 00       	call   80101e2d <stati>
80101152:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101155:	8b 45 08             	mov    0x8(%ebp),%eax
80101158:	8b 40 10             	mov    0x10(%eax),%eax
8010115b:	83 ec 0c             	sub    $0xc,%esp
8010115e:	50                   	push   %eax
8010115f:	e8 ff 08 00 00       	call   80101a63 <iunlock>
80101164:	83 c4 10             	add    $0x10,%esp
    return 0;
80101167:	b8 00 00 00 00       	mov    $0x0,%eax
8010116c:	eb 05                	jmp    80101173 <filestat+0x55>
  }
  return -1;
8010116e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101173:	c9                   	leave  
80101174:	c3                   	ret    

80101175 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101175:	55                   	push   %ebp
80101176:	89 e5                	mov    %esp,%ebp
80101178:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101182:	84 c0                	test   %al,%al
80101184:	75 0a                	jne    80101190 <fileread+0x1b>
    return -1;
80101186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010118b:	e9 9b 00 00 00       	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_PIPE)
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	8b 00                	mov    (%eax),%eax
80101195:	83 f8 01             	cmp    $0x1,%eax
80101198:	75 1a                	jne    801011b4 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010119a:	8b 45 08             	mov    0x8(%ebp),%eax
8010119d:	8b 40 0c             	mov    0xc(%eax),%eax
801011a0:	83 ec 04             	sub    $0x4,%esp
801011a3:	ff 75 10             	pushl  0x10(%ebp)
801011a6:	ff 75 0c             	pushl  0xc(%ebp)
801011a9:	50                   	push   %eax
801011aa:	e8 fe 30 00 00       	call   801042ad <piperead>
801011af:	83 c4 10             	add    $0x10,%esp
801011b2:	eb 77                	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_INODE){
801011b4:	8b 45 08             	mov    0x8(%ebp),%eax
801011b7:	8b 00                	mov    (%eax),%eax
801011b9:	83 f8 02             	cmp    $0x2,%eax
801011bc:	75 60                	jne    8010121e <fileread+0xa9>
    ilock(f->ip);
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	8b 40 10             	mov    0x10(%eax),%eax
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	50                   	push   %eax
801011c8:	e8 3e 07 00 00       	call   8010190b <ilock>
801011cd:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 50 14             	mov    0x14(%eax),%edx
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	51                   	push   %ecx
801011e0:	52                   	push   %edx
801011e1:	ff 75 0c             	pushl  0xc(%ebp)
801011e4:	50                   	push   %eax
801011e5:	e8 89 0c 00 00       	call   80101e73 <readi>
801011ea:	83 c4 10             	add    $0x10,%esp
801011ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011f4:	7e 11                	jle    80101207 <fileread+0x92>
      f->off += r;
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 50 14             	mov    0x14(%eax),%edx
801011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ff:	01 c2                	add    %eax,%edx
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	8b 40 10             	mov    0x10(%eax),%eax
8010120d:	83 ec 0c             	sub    $0xc,%esp
80101210:	50                   	push   %eax
80101211:	e8 4d 08 00 00       	call   80101a63 <iunlock>
80101216:	83 c4 10             	add    $0x10,%esp
    return r;
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	eb 0d                	jmp    8010122b <fileread+0xb6>
  }
  panic("fileread");
8010121e:	83 ec 0c             	sub    $0xc,%esp
80101221:	68 be 8e 10 80       	push   $0x80108ebe
80101226:	e8 3b f3 ff ff       	call   80100566 <panic>
}
8010122b:	c9                   	leave  
8010122c:	c3                   	ret    

8010122d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010122d:	55                   	push   %ebp
8010122e:	89 e5                	mov    %esp,%ebp
80101230:	53                   	push   %ebx
80101231:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010123b:	84 c0                	test   %al,%al
8010123d:	75 0a                	jne    80101249 <filewrite+0x1c>
    return -1;
8010123f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101244:	e9 1b 01 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 00                	mov    (%eax),%eax
8010124e:	83 f8 01             	cmp    $0x1,%eax
80101251:	75 1d                	jne    80101270 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 0c             	mov    0xc(%eax),%eax
80101259:	83 ec 04             	sub    $0x4,%esp
8010125c:	ff 75 10             	pushl  0x10(%ebp)
8010125f:	ff 75 0c             	pushl  0xc(%ebp)
80101262:	50                   	push   %eax
80101263:	e8 47 2f 00 00       	call   801041af <pipewrite>
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	e9 f4 00 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_INODE){
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 00                	mov    (%eax),%eax
80101275:	83 f8 02             	cmp    $0x2,%eax
80101278:	0f 85 d9 00 00 00    	jne    80101357 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010127e:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101285:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010128c:	e9 a3 00 00 00       	jmp    80101334 <filewrite+0x107>
      int n1 = n - i;
80101291:	8b 45 10             	mov    0x10(%ebp),%eax
80101294:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101297:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010129d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012a0:	7e 06                	jle    801012a8 <filewrite+0x7b>
        n1 = max;
801012a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012a8:	e8 07 22 00 00       	call   801034b4 <begin_op>
      ilock(f->ip);
801012ad:	8b 45 08             	mov    0x8(%ebp),%eax
801012b0:	8b 40 10             	mov    0x10(%eax),%eax
801012b3:	83 ec 0c             	sub    $0xc,%esp
801012b6:	50                   	push   %eax
801012b7:	e8 4f 06 00 00       	call   8010190b <ilock>
801012bc:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012bf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ce:	01 c3                	add    %eax,%ebx
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	8b 40 10             	mov    0x10(%eax),%eax
801012d6:	51                   	push   %ecx
801012d7:	52                   	push   %edx
801012d8:	53                   	push   %ebx
801012d9:	50                   	push   %eax
801012da:	e8 eb 0c 00 00       	call   80101fca <writei>
801012df:	83 c4 10             	add    $0x10,%esp
801012e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012e9:	7e 11                	jle    801012fc <filewrite+0xcf>
        f->off += r;
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 50 14             	mov    0x14(%eax),%edx
801012f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f4:	01 c2                	add    %eax,%edx
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 10             	mov    0x10(%eax),%eax
80101302:	83 ec 0c             	sub    $0xc,%esp
80101305:	50                   	push   %eax
80101306:	e8 58 07 00 00       	call   80101a63 <iunlock>
8010130b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010130e:	e8 2d 22 00 00       	call   80103540 <end_op>

      if(r < 0)
80101313:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101317:	78 29                	js     80101342 <filewrite+0x115>
        break;
      if(r != n1)
80101319:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010131f:	74 0d                	je     8010132e <filewrite+0x101>
        panic("short filewrite");
80101321:	83 ec 0c             	sub    $0xc,%esp
80101324:	68 c7 8e 10 80       	push   $0x80108ec7
80101329:	e8 38 f2 ff ff       	call   80100566 <panic>
      i += r;
8010132e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101331:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101337:	3b 45 10             	cmp    0x10(%ebp),%eax
8010133a:	0f 8c 51 ff ff ff    	jl     80101291 <filewrite+0x64>
80101340:	eb 01                	jmp    80101343 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101342:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101346:	3b 45 10             	cmp    0x10(%ebp),%eax
80101349:	75 05                	jne    80101350 <filewrite+0x123>
8010134b:	8b 45 10             	mov    0x10(%ebp),%eax
8010134e:	eb 14                	jmp    80101364 <filewrite+0x137>
80101350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101355:	eb 0d                	jmp    80101364 <filewrite+0x137>
  }
  panic("filewrite");
80101357:	83 ec 0c             	sub    $0xc,%esp
8010135a:	68 d7 8e 10 80       	push   $0x80108ed7
8010135f:	e8 02 f2 ff ff       	call   80100566 <panic>
}
80101364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101367:	c9                   	leave  
80101368:	c3                   	ret    

80101369 <readsb>:
static void itrunc(struct inode*);

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101369:	55                   	push   %ebp
8010136a:	89 e5                	mov    %esp,%ebp
8010136c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	83 ec 08             	sub    $0x8,%esp
80101375:	6a 01                	push   $0x1
80101377:	50                   	push   %eax
80101378:	e8 39 ee ff ff       	call   801001b6 <bread>
8010137d:	83 c4 10             	add    $0x10,%esp
80101380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101386:	83 c0 18             	add    $0x18,%eax
80101389:	83 ec 04             	sub    $0x4,%esp
8010138c:	6a 10                	push   $0x10
8010138e:	50                   	push   %eax
8010138f:	ff 75 0c             	pushl  0xc(%ebp)
80101392:	e8 22 47 00 00       	call   80105ab9 <memmove>
80101397:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010139a:	83 ec 0c             	sub    $0xc,%esp
8010139d:	ff 75 f4             	pushl  -0xc(%ebp)
801013a0:	e8 89 ee ff ff       	call   8010022e <brelse>
801013a5:	83 c4 10             	add    $0x10,%esp
}
801013a8:	90                   	nop
801013a9:	c9                   	leave  
801013aa:	c3                   	ret    

801013ab <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ab:	55                   	push   %ebp
801013ac:	89 e5                	mov    %esp,%ebp
801013ae:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	83 ec 08             	sub    $0x8,%esp
801013ba:	52                   	push   %edx
801013bb:	50                   	push   %eax
801013bc:	e8 f5 ed ff ff       	call   801001b6 <bread>
801013c1:	83 c4 10             	add    $0x10,%esp
801013c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ca:	83 c0 18             	add    $0x18,%eax
801013cd:	83 ec 04             	sub    $0x4,%esp
801013d0:	68 00 02 00 00       	push   $0x200
801013d5:	6a 00                	push   $0x0
801013d7:	50                   	push   %eax
801013d8:	e8 1d 46 00 00       	call   801059fa <memset>
801013dd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013e0:	83 ec 0c             	sub    $0xc,%esp
801013e3:	ff 75 f4             	pushl  -0xc(%ebp)
801013e6:	e8 01 23 00 00       	call   801036ec <log_write>
801013eb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ee:	83 ec 0c             	sub    $0xc,%esp
801013f1:	ff 75 f4             	pushl  -0xc(%ebp)
801013f4:	e8 35 ee ff ff       	call   8010022e <brelse>
801013f9:	83 c4 10             	add    $0x10,%esp
}
801013fc:	90                   	nop
801013fd:	c9                   	leave  
801013fe:	c3                   	ret    

801013ff <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013ff:	55                   	push   %ebp
80101400:	89 e5                	mov    %esp,%ebp
80101402:	83 ec 28             	sub    $0x28,%esp
  int b, bi, m;
  struct buf *bp;
  struct superblock sb;

  bp = 0;
80101405:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  readsb(dev, &sb);
8010140c:	8b 45 08             	mov    0x8(%ebp),%eax
8010140f:	83 ec 08             	sub    $0x8,%esp
80101412:	8d 55 d8             	lea    -0x28(%ebp),%edx
80101415:	52                   	push   %edx
80101416:	50                   	push   %eax
80101417:	e8 4d ff ff ff       	call   80101369 <readsb>
8010141c:	83 c4 10             	add    $0x10,%esp
  for(b = 0; b < sb.size; b += BPB){
8010141f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101426:	e9 15 01 00 00       	jmp    80101540 <balloc+0x141>
    bp = bread(dev, BBLOCK(b, sb.ninodes));
8010142b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010142e:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101434:	85 c0                	test   %eax,%eax
80101436:	0f 48 c2             	cmovs  %edx,%eax
80101439:	c1 f8 0c             	sar    $0xc,%eax
8010143c:	89 c2                	mov    %eax,%edx
8010143e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101441:	c1 e8 03             	shr    $0x3,%eax
80101444:	01 d0                	add    %edx,%eax
80101446:	83 c0 03             	add    $0x3,%eax
80101449:	83 ec 08             	sub    $0x8,%esp
8010144c:	50                   	push   %eax
8010144d:	ff 75 08             	pushl  0x8(%ebp)
80101450:	e8 61 ed ff ff       	call   801001b6 <bread>
80101455:	83 c4 10             	add    $0x10,%esp
80101458:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010145b:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101462:	e9 a6 00 00 00       	jmp    8010150d <balloc+0x10e>
      m = 1 << (bi % 8);
80101467:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146a:	99                   	cltd   
8010146b:	c1 ea 1d             	shr    $0x1d,%edx
8010146e:	01 d0                	add    %edx,%eax
80101470:	83 e0 07             	and    $0x7,%eax
80101473:	29 d0                	sub    %edx,%eax
80101475:	ba 01 00 00 00       	mov    $0x1,%edx
8010147a:	89 c1                	mov    %eax,%ecx
8010147c:	d3 e2                	shl    %cl,%edx
8010147e:	89 d0                	mov    %edx,%eax
80101480:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101483:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101486:	8d 50 07             	lea    0x7(%eax),%edx
80101489:	85 c0                	test   %eax,%eax
8010148b:	0f 48 c2             	cmovs  %edx,%eax
8010148e:	c1 f8 03             	sar    $0x3,%eax
80101491:	89 c2                	mov    %eax,%edx
80101493:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101496:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
8010149b:	0f b6 c0             	movzbl %al,%eax
8010149e:	23 45 e8             	and    -0x18(%ebp),%eax
801014a1:	85 c0                	test   %eax,%eax
801014a3:	75 64                	jne    80101509 <balloc+0x10a>
        bp->data[bi/8] |= m;  // Mark block in use.
801014a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014a8:	8d 50 07             	lea    0x7(%eax),%edx
801014ab:	85 c0                	test   %eax,%eax
801014ad:	0f 48 c2             	cmovs  %edx,%eax
801014b0:	c1 f8 03             	sar    $0x3,%eax
801014b3:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b6:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014bb:	89 d1                	mov    %edx,%ecx
801014bd:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014c0:	09 ca                	or     %ecx,%edx
801014c2:	89 d1                	mov    %edx,%ecx
801014c4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014c7:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014cb:	83 ec 0c             	sub    $0xc,%esp
801014ce:	ff 75 ec             	pushl  -0x14(%ebp)
801014d1:	e8 16 22 00 00       	call   801036ec <log_write>
801014d6:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014d9:	83 ec 0c             	sub    $0xc,%esp
801014dc:	ff 75 ec             	pushl  -0x14(%ebp)
801014df:	e8 4a ed ff ff       	call   8010022e <brelse>
801014e4:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ed:	01 c2                	add    %eax,%edx
801014ef:	8b 45 08             	mov    0x8(%ebp),%eax
801014f2:	83 ec 08             	sub    $0x8,%esp
801014f5:	52                   	push   %edx
801014f6:	50                   	push   %eax
801014f7:	e8 af fe ff ff       	call   801013ab <bzero>
801014fc:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101505:	01 d0                	add    %edx,%eax
80101507:	eb 52                	jmp    8010155b <balloc+0x15c>

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb.ninodes));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101509:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010150d:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
80101514:	7f 15                	jg     8010152b <balloc+0x12c>
80101516:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101519:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010151c:	01 d0                	add    %edx,%eax
8010151e:	89 c2                	mov    %eax,%edx
80101520:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101523:	39 c2                	cmp    %eax,%edx
80101525:	0f 82 3c ff ff ff    	jb     80101467 <balloc+0x68>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
8010152b:	83 ec 0c             	sub    $0xc,%esp
8010152e:	ff 75 ec             	pushl  -0x14(%ebp)
80101531:	e8 f8 ec ff ff       	call   8010022e <brelse>
80101536:	83 c4 10             	add    $0x10,%esp
  struct buf *bp;
  struct superblock sb;

  bp = 0;
  readsb(dev, &sb);
  for(b = 0; b < sb.size; b += BPB){
80101539:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80101540:	8b 55 d8             	mov    -0x28(%ebp),%edx
80101543:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101546:	39 c2                	cmp    %eax,%edx
80101548:	0f 87 dd fe ff ff    	ja     8010142b <balloc+0x2c>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010154e:	83 ec 0c             	sub    $0xc,%esp
80101551:	68 e1 8e 10 80       	push   $0x80108ee1
80101556:	e8 0b f0 ff ff       	call   80100566 <panic>
}
8010155b:	c9                   	leave  
8010155c:	c3                   	ret    

8010155d <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010155d:	55                   	push   %ebp
8010155e:	89 e5                	mov    %esp,%ebp
80101560:	83 ec 28             	sub    $0x28,%esp
  struct buf *bp;
  struct superblock sb;
  int bi, m;

  readsb(dev, &sb);
80101563:	83 ec 08             	sub    $0x8,%esp
80101566:	8d 45 dc             	lea    -0x24(%ebp),%eax
80101569:	50                   	push   %eax
8010156a:	ff 75 08             	pushl  0x8(%ebp)
8010156d:	e8 f7 fd ff ff       	call   80101369 <readsb>
80101572:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb.ninodes));
80101575:	8b 45 0c             	mov    0xc(%ebp),%eax
80101578:	c1 e8 0c             	shr    $0xc,%eax
8010157b:	89 c2                	mov    %eax,%edx
8010157d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101580:	c1 e8 03             	shr    $0x3,%eax
80101583:	01 d0                	add    %edx,%eax
80101585:	8d 50 03             	lea    0x3(%eax),%edx
80101588:	8b 45 08             	mov    0x8(%ebp),%eax
8010158b:	83 ec 08             	sub    $0x8,%esp
8010158e:	52                   	push   %edx
8010158f:	50                   	push   %eax
80101590:	e8 21 ec ff ff       	call   801001b6 <bread>
80101595:	83 c4 10             	add    $0x10,%esp
80101598:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
8010159b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010159e:	25 ff 0f 00 00       	and    $0xfff,%eax
801015a3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
801015a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015a9:	99                   	cltd   
801015aa:	c1 ea 1d             	shr    $0x1d,%edx
801015ad:	01 d0                	add    %edx,%eax
801015af:	83 e0 07             	and    $0x7,%eax
801015b2:	29 d0                	sub    %edx,%eax
801015b4:	ba 01 00 00 00       	mov    $0x1,%edx
801015b9:	89 c1                	mov    %eax,%ecx
801015bb:	d3 e2                	shl    %cl,%edx
801015bd:	89 d0                	mov    %edx,%eax
801015bf:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015c5:	8d 50 07             	lea    0x7(%eax),%edx
801015c8:	85 c0                	test   %eax,%eax
801015ca:	0f 48 c2             	cmovs  %edx,%eax
801015cd:	c1 f8 03             	sar    $0x3,%eax
801015d0:	89 c2                	mov    %eax,%edx
801015d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015d5:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015da:	0f b6 c0             	movzbl %al,%eax
801015dd:	23 45 ec             	and    -0x14(%ebp),%eax
801015e0:	85 c0                	test   %eax,%eax
801015e2:	75 0d                	jne    801015f1 <bfree+0x94>
    panic("freeing free block");
801015e4:	83 ec 0c             	sub    $0xc,%esp
801015e7:	68 f7 8e 10 80       	push   $0x80108ef7
801015ec:	e8 75 ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015f4:	8d 50 07             	lea    0x7(%eax),%edx
801015f7:	85 c0                	test   %eax,%eax
801015f9:	0f 48 c2             	cmovs  %edx,%eax
801015fc:	c1 f8 03             	sar    $0x3,%eax
801015ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101602:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
80101607:	89 d1                	mov    %edx,%ecx
80101609:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010160c:	f7 d2                	not    %edx
8010160e:	21 ca                	and    %ecx,%edx
80101610:	89 d1                	mov    %edx,%ecx
80101612:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101615:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101619:	83 ec 0c             	sub    $0xc,%esp
8010161c:	ff 75 f4             	pushl  -0xc(%ebp)
8010161f:	e8 c8 20 00 00       	call   801036ec <log_write>
80101624:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101627:	83 ec 0c             	sub    $0xc,%esp
8010162a:	ff 75 f4             	pushl  -0xc(%ebp)
8010162d:	e8 fc eb ff ff       	call   8010022e <brelse>
80101632:	83 c4 10             	add    $0x10,%esp
}
80101635:	90                   	nop
80101636:	c9                   	leave  
80101637:	c3                   	ret    

80101638 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(void)
{
80101638:	55                   	push   %ebp
80101639:	89 e5                	mov    %esp,%ebp
8010163b:	83 ec 08             	sub    $0x8,%esp
  initlock(&icache.lock, "icache");
8010163e:	83 ec 08             	sub    $0x8,%esp
80101641:	68 0a 8f 10 80       	push   $0x80108f0a
80101646:	68 60 22 11 80       	push   $0x80112260
8010164b:	e8 25 41 00 00       	call   80105775 <initlock>
80101650:	83 c4 10             	add    $0x10,%esp
}
80101653:	90                   	nop
80101654:	c9                   	leave  
80101655:	c3                   	ret    

80101656 <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
80101656:	55                   	push   %ebp
80101657:	89 e5                	mov    %esp,%ebp
80101659:	83 ec 38             	sub    $0x38,%esp
8010165c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010165f:	66 89 45 d4          	mov    %ax,-0x2c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);
80101663:	8b 45 08             	mov    0x8(%ebp),%eax
80101666:	83 ec 08             	sub    $0x8,%esp
80101669:	8d 55 dc             	lea    -0x24(%ebp),%edx
8010166c:	52                   	push   %edx
8010166d:	50                   	push   %eax
8010166e:	e8 f6 fc ff ff       	call   80101369 <readsb>
80101673:	83 c4 10             	add    $0x10,%esp

  for(inum = 1; inum < sb.ninodes; inum++){
80101676:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
8010167d:	e9 98 00 00 00       	jmp    8010171a <ialloc+0xc4>
    bp = bread(dev, IBLOCK(inum));
80101682:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101685:	c1 e8 03             	shr    $0x3,%eax
80101688:	83 c0 02             	add    $0x2,%eax
8010168b:	83 ec 08             	sub    $0x8,%esp
8010168e:	50                   	push   %eax
8010168f:	ff 75 08             	pushl  0x8(%ebp)
80101692:	e8 1f eb ff ff       	call   801001b6 <bread>
80101697:	83 c4 10             	add    $0x10,%esp
8010169a:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
8010169d:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016a0:	8d 50 18             	lea    0x18(%eax),%edx
801016a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016a6:	83 e0 07             	and    $0x7,%eax
801016a9:	c1 e0 06             	shl    $0x6,%eax
801016ac:	01 d0                	add    %edx,%eax
801016ae:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016b4:	0f b7 00             	movzwl (%eax),%eax
801016b7:	66 85 c0             	test   %ax,%ax
801016ba:	75 4c                	jne    80101708 <ialloc+0xb2>
      memset(dip, 0, sizeof(*dip));
801016bc:	83 ec 04             	sub    $0x4,%esp
801016bf:	6a 40                	push   $0x40
801016c1:	6a 00                	push   $0x0
801016c3:	ff 75 ec             	pushl  -0x14(%ebp)
801016c6:	e8 2f 43 00 00       	call   801059fa <memset>
801016cb:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
801016ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016d1:	0f b7 55 d4          	movzwl -0x2c(%ebp),%edx
801016d5:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
801016d8:	83 ec 0c             	sub    $0xc,%esp
801016db:	ff 75 f0             	pushl  -0x10(%ebp)
801016de:	e8 09 20 00 00       	call   801036ec <log_write>
801016e3:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
801016e6:	83 ec 0c             	sub    $0xc,%esp
801016e9:	ff 75 f0             	pushl  -0x10(%ebp)
801016ec:	e8 3d eb ff ff       	call   8010022e <brelse>
801016f1:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
801016f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016f7:	83 ec 08             	sub    $0x8,%esp
801016fa:	50                   	push   %eax
801016fb:	ff 75 08             	pushl  0x8(%ebp)
801016fe:	e8 ef 00 00 00       	call   801017f2 <iget>
80101703:	83 c4 10             	add    $0x10,%esp
80101706:	eb 2d                	jmp    80101735 <ialloc+0xdf>
    }
    brelse(bp);
80101708:	83 ec 0c             	sub    $0xc,%esp
8010170b:	ff 75 f0             	pushl  -0x10(%ebp)
8010170e:	e8 1b eb ff ff       	call   8010022e <brelse>
80101713:	83 c4 10             	add    $0x10,%esp
  struct dinode *dip;
  struct superblock sb;

  readsb(dev, &sb);

  for(inum = 1; inum < sb.ninodes; inum++){
80101716:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010171a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010171d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101720:	39 c2                	cmp    %eax,%edx
80101722:	0f 87 5a ff ff ff    	ja     80101682 <ialloc+0x2c>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101728:	83 ec 0c             	sub    $0xc,%esp
8010172b:	68 11 8f 10 80       	push   $0x80108f11
80101730:	e8 31 ee ff ff       	call   80100566 <panic>
}
80101735:	c9                   	leave  
80101736:	c3                   	ret    

80101737 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101737:	55                   	push   %ebp
80101738:	89 e5                	mov    %esp,%ebp
8010173a:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum));
8010173d:	8b 45 08             	mov    0x8(%ebp),%eax
80101740:	8b 40 04             	mov    0x4(%eax),%eax
80101743:	c1 e8 03             	shr    $0x3,%eax
80101746:	8d 50 02             	lea    0x2(%eax),%edx
80101749:	8b 45 08             	mov    0x8(%ebp),%eax
8010174c:	8b 00                	mov    (%eax),%eax
8010174e:	83 ec 08             	sub    $0x8,%esp
80101751:	52                   	push   %edx
80101752:	50                   	push   %eax
80101753:	e8 5e ea ff ff       	call   801001b6 <bread>
80101758:	83 c4 10             	add    $0x10,%esp
8010175b:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010175e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101761:	8d 50 18             	lea    0x18(%eax),%edx
80101764:	8b 45 08             	mov    0x8(%ebp),%eax
80101767:	8b 40 04             	mov    0x4(%eax),%eax
8010176a:	83 e0 07             	and    $0x7,%eax
8010176d:	c1 e0 06             	shl    $0x6,%eax
80101770:	01 d0                	add    %edx,%eax
80101772:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
80101775:	8b 45 08             	mov    0x8(%ebp),%eax
80101778:	0f b7 50 10          	movzwl 0x10(%eax),%edx
8010177c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010177f:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101782:	8b 45 08             	mov    0x8(%ebp),%eax
80101785:	0f b7 50 12          	movzwl 0x12(%eax),%edx
80101789:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010178c:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
80101790:	8b 45 08             	mov    0x8(%ebp),%eax
80101793:	0f b7 50 14          	movzwl 0x14(%eax),%edx
80101797:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010179a:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
8010179e:	8b 45 08             	mov    0x8(%ebp),%eax
801017a1:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017a5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017a8:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017ac:	8b 45 08             	mov    0x8(%ebp),%eax
801017af:	8b 50 18             	mov    0x18(%eax),%edx
801017b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017b5:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017b8:	8b 45 08             	mov    0x8(%ebp),%eax
801017bb:	8d 50 1c             	lea    0x1c(%eax),%edx
801017be:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c1:	83 c0 0c             	add    $0xc,%eax
801017c4:	83 ec 04             	sub    $0x4,%esp
801017c7:	6a 34                	push   $0x34
801017c9:	52                   	push   %edx
801017ca:	50                   	push   %eax
801017cb:	e8 e9 42 00 00       	call   80105ab9 <memmove>
801017d0:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801017d3:	83 ec 0c             	sub    $0xc,%esp
801017d6:	ff 75 f4             	pushl  -0xc(%ebp)
801017d9:	e8 0e 1f 00 00       	call   801036ec <log_write>
801017de:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801017e1:	83 ec 0c             	sub    $0xc,%esp
801017e4:	ff 75 f4             	pushl  -0xc(%ebp)
801017e7:	e8 42 ea ff ff       	call   8010022e <brelse>
801017ec:	83 c4 10             	add    $0x10,%esp
}
801017ef:	90                   	nop
801017f0:	c9                   	leave  
801017f1:	c3                   	ret    

801017f2 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
801017f2:	55                   	push   %ebp
801017f3:	89 e5                	mov    %esp,%ebp
801017f5:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
801017f8:	83 ec 0c             	sub    $0xc,%esp
801017fb:	68 60 22 11 80       	push   $0x80112260
80101800:	e8 92 3f 00 00       	call   80105797 <acquire>
80101805:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
80101808:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010180f:	c7 45 f4 94 22 11 80 	movl   $0x80112294,-0xc(%ebp)
80101816:	eb 5d                	jmp    80101875 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101818:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010181b:	8b 40 08             	mov    0x8(%eax),%eax
8010181e:	85 c0                	test   %eax,%eax
80101820:	7e 39                	jle    8010185b <iget+0x69>
80101822:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101825:	8b 00                	mov    (%eax),%eax
80101827:	3b 45 08             	cmp    0x8(%ebp),%eax
8010182a:	75 2f                	jne    8010185b <iget+0x69>
8010182c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010182f:	8b 40 04             	mov    0x4(%eax),%eax
80101832:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101835:	75 24                	jne    8010185b <iget+0x69>
      ip->ref++;
80101837:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010183a:	8b 40 08             	mov    0x8(%eax),%eax
8010183d:	8d 50 01             	lea    0x1(%eax),%edx
80101840:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101843:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
80101846:	83 ec 0c             	sub    $0xc,%esp
80101849:	68 60 22 11 80       	push   $0x80112260
8010184e:	e8 ab 3f 00 00       	call   801057fe <release>
80101853:	83 c4 10             	add    $0x10,%esp
      return ip;
80101856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101859:	eb 74                	jmp    801018cf <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010185b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010185f:	75 10                	jne    80101871 <iget+0x7f>
80101861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101864:	8b 40 08             	mov    0x8(%eax),%eax
80101867:	85 c0                	test   %eax,%eax
80101869:	75 06                	jne    80101871 <iget+0x7f>
      empty = ip;
8010186b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010186e:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101871:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
80101875:	81 7d f4 34 32 11 80 	cmpl   $0x80113234,-0xc(%ebp)
8010187c:	72 9a                	jb     80101818 <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
8010187e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80101882:	75 0d                	jne    80101891 <iget+0x9f>
    panic("iget: no inodes");
80101884:	83 ec 0c             	sub    $0xc,%esp
80101887:	68 23 8f 10 80       	push   $0x80108f23
8010188c:	e8 d5 ec ff ff       	call   80100566 <panic>

  ip = empty;
80101891:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101894:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
80101897:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189a:	8b 55 08             	mov    0x8(%ebp),%edx
8010189d:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
8010189f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801018a5:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ab:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b5:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
801018bc:	83 ec 0c             	sub    $0xc,%esp
801018bf:	68 60 22 11 80       	push   $0x80112260
801018c4:	e8 35 3f 00 00       	call   801057fe <release>
801018c9:	83 c4 10             	add    $0x10,%esp

  return ip;
801018cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801018cf:	c9                   	leave  
801018d0:	c3                   	ret    

801018d1 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
801018d1:	55                   	push   %ebp
801018d2:	89 e5                	mov    %esp,%ebp
801018d4:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
801018d7:	83 ec 0c             	sub    $0xc,%esp
801018da:	68 60 22 11 80       	push   $0x80112260
801018df:	e8 b3 3e 00 00       	call   80105797 <acquire>
801018e4:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
801018e7:	8b 45 08             	mov    0x8(%ebp),%eax
801018ea:	8b 40 08             	mov    0x8(%eax),%eax
801018ed:	8d 50 01             	lea    0x1(%eax),%edx
801018f0:	8b 45 08             	mov    0x8(%ebp),%eax
801018f3:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
801018f6:	83 ec 0c             	sub    $0xc,%esp
801018f9:	68 60 22 11 80       	push   $0x80112260
801018fe:	e8 fb 3e 00 00       	call   801057fe <release>
80101903:	83 c4 10             	add    $0x10,%esp
  return ip;
80101906:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101909:	c9                   	leave  
8010190a:	c3                   	ret    

8010190b <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010190b:	55                   	push   %ebp
8010190c:	89 e5                	mov    %esp,%ebp
8010190e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101911:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101915:	74 0a                	je     80101921 <ilock+0x16>
80101917:	8b 45 08             	mov    0x8(%ebp),%eax
8010191a:	8b 40 08             	mov    0x8(%eax),%eax
8010191d:	85 c0                	test   %eax,%eax
8010191f:	7f 0d                	jg     8010192e <ilock+0x23>
    panic("ilock");
80101921:	83 ec 0c             	sub    $0xc,%esp
80101924:	68 33 8f 10 80       	push   $0x80108f33
80101929:	e8 38 ec ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
8010192e:	83 ec 0c             	sub    $0xc,%esp
80101931:	68 60 22 11 80       	push   $0x80112260
80101936:	e8 5c 3e 00 00       	call   80105797 <acquire>
8010193b:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
8010193e:	eb 13                	jmp    80101953 <ilock+0x48>
    sleep(ip, &icache.lock);
80101940:	83 ec 08             	sub    $0x8,%esp
80101943:	68 60 22 11 80       	push   $0x80112260
80101948:	ff 75 08             	pushl  0x8(%ebp)
8010194b:	e8 f4 34 00 00       	call   80104e44 <sleep>
80101950:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101953:	8b 45 08             	mov    0x8(%ebp),%eax
80101956:	8b 40 0c             	mov    0xc(%eax),%eax
80101959:	83 e0 01             	and    $0x1,%eax
8010195c:	85 c0                	test   %eax,%eax
8010195e:	75 e0                	jne    80101940 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
80101960:	8b 45 08             	mov    0x8(%ebp),%eax
80101963:	8b 40 0c             	mov    0xc(%eax),%eax
80101966:	83 c8 01             	or     $0x1,%eax
80101969:	89 c2                	mov    %eax,%edx
8010196b:	8b 45 08             	mov    0x8(%ebp),%eax
8010196e:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
80101971:	83 ec 0c             	sub    $0xc,%esp
80101974:	68 60 22 11 80       	push   $0x80112260
80101979:	e8 80 3e 00 00       	call   801057fe <release>
8010197e:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
80101981:	8b 45 08             	mov    0x8(%ebp),%eax
80101984:	8b 40 0c             	mov    0xc(%eax),%eax
80101987:	83 e0 02             	and    $0x2,%eax
8010198a:	85 c0                	test   %eax,%eax
8010198c:	0f 85 ce 00 00 00    	jne    80101a60 <ilock+0x155>
    bp = bread(ip->dev, IBLOCK(ip->inum));
80101992:	8b 45 08             	mov    0x8(%ebp),%eax
80101995:	8b 40 04             	mov    0x4(%eax),%eax
80101998:	c1 e8 03             	shr    $0x3,%eax
8010199b:	8d 50 02             	lea    0x2(%eax),%edx
8010199e:	8b 45 08             	mov    0x8(%ebp),%eax
801019a1:	8b 00                	mov    (%eax),%eax
801019a3:	83 ec 08             	sub    $0x8,%esp
801019a6:	52                   	push   %edx
801019a7:	50                   	push   %eax
801019a8:	e8 09 e8 ff ff       	call   801001b6 <bread>
801019ad:	83 c4 10             	add    $0x10,%esp
801019b0:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801019b6:	8d 50 18             	lea    0x18(%eax),%edx
801019b9:	8b 45 08             	mov    0x8(%ebp),%eax
801019bc:	8b 40 04             	mov    0x4(%eax),%eax
801019bf:	83 e0 07             	and    $0x7,%eax
801019c2:	c1 e0 06             	shl    $0x6,%eax
801019c5:	01 d0                	add    %edx,%eax
801019c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
801019ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019cd:	0f b7 10             	movzwl (%eax),%edx
801019d0:	8b 45 08             	mov    0x8(%ebp),%eax
801019d3:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
801019d7:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019da:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801019de:	8b 45 08             	mov    0x8(%ebp),%eax
801019e1:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
801019e5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019e8:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801019ec:	8b 45 08             	mov    0x8(%ebp),%eax
801019ef:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
801019f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801019f6:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801019fa:	8b 45 08             	mov    0x8(%ebp),%eax
801019fd:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a01:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a04:	8b 50 08             	mov    0x8(%eax),%edx
80101a07:	8b 45 08             	mov    0x8(%ebp),%eax
80101a0a:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a10:	8d 50 0c             	lea    0xc(%eax),%edx
80101a13:	8b 45 08             	mov    0x8(%ebp),%eax
80101a16:	83 c0 1c             	add    $0x1c,%eax
80101a19:	83 ec 04             	sub    $0x4,%esp
80101a1c:	6a 34                	push   $0x34
80101a1e:	52                   	push   %edx
80101a1f:	50                   	push   %eax
80101a20:	e8 94 40 00 00       	call   80105ab9 <memmove>
80101a25:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a28:	83 ec 0c             	sub    $0xc,%esp
80101a2b:	ff 75 f4             	pushl  -0xc(%ebp)
80101a2e:	e8 fb e7 ff ff       	call   8010022e <brelse>
80101a33:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a36:	8b 45 08             	mov    0x8(%ebp),%eax
80101a39:	8b 40 0c             	mov    0xc(%eax),%eax
80101a3c:	83 c8 02             	or     $0x2,%eax
80101a3f:	89 c2                	mov    %eax,%edx
80101a41:	8b 45 08             	mov    0x8(%ebp),%eax
80101a44:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a47:	8b 45 08             	mov    0x8(%ebp),%eax
80101a4a:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a4e:	66 85 c0             	test   %ax,%ax
80101a51:	75 0d                	jne    80101a60 <ilock+0x155>
      panic("ilock: no type");
80101a53:	83 ec 0c             	sub    $0xc,%esp
80101a56:	68 39 8f 10 80       	push   $0x80108f39
80101a5b:	e8 06 eb ff ff       	call   80100566 <panic>
  }
}
80101a60:	90                   	nop
80101a61:	c9                   	leave  
80101a62:	c3                   	ret    

80101a63 <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101a63:	55                   	push   %ebp
80101a64:	89 e5                	mov    %esp,%ebp
80101a66:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101a69:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101a6d:	74 17                	je     80101a86 <iunlock+0x23>
80101a6f:	8b 45 08             	mov    0x8(%ebp),%eax
80101a72:	8b 40 0c             	mov    0xc(%eax),%eax
80101a75:	83 e0 01             	and    $0x1,%eax
80101a78:	85 c0                	test   %eax,%eax
80101a7a:	74 0a                	je     80101a86 <iunlock+0x23>
80101a7c:	8b 45 08             	mov    0x8(%ebp),%eax
80101a7f:	8b 40 08             	mov    0x8(%eax),%eax
80101a82:	85 c0                	test   %eax,%eax
80101a84:	7f 0d                	jg     80101a93 <iunlock+0x30>
    panic("iunlock");
80101a86:	83 ec 0c             	sub    $0xc,%esp
80101a89:	68 48 8f 10 80       	push   $0x80108f48
80101a8e:	e8 d3 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101a93:	83 ec 0c             	sub    $0xc,%esp
80101a96:	68 60 22 11 80       	push   $0x80112260
80101a9b:	e8 f7 3c 00 00       	call   80105797 <acquire>
80101aa0:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101aa3:	8b 45 08             	mov    0x8(%ebp),%eax
80101aa6:	8b 40 0c             	mov    0xc(%eax),%eax
80101aa9:	83 e0 fe             	and    $0xfffffffe,%eax
80101aac:	89 c2                	mov    %eax,%edx
80101aae:	8b 45 08             	mov    0x8(%ebp),%eax
80101ab1:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101ab4:	83 ec 0c             	sub    $0xc,%esp
80101ab7:	ff 75 08             	pushl  0x8(%ebp)
80101aba:	e8 9a 34 00 00       	call   80104f59 <wakeup>
80101abf:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101ac2:	83 ec 0c             	sub    $0xc,%esp
80101ac5:	68 60 22 11 80       	push   $0x80112260
80101aca:	e8 2f 3d 00 00       	call   801057fe <release>
80101acf:	83 c4 10             	add    $0x10,%esp
}
80101ad2:	90                   	nop
80101ad3:	c9                   	leave  
80101ad4:	c3                   	ret    

80101ad5 <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101ad5:	55                   	push   %ebp
80101ad6:	89 e5                	mov    %esp,%ebp
80101ad8:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101adb:	83 ec 0c             	sub    $0xc,%esp
80101ade:	68 60 22 11 80       	push   $0x80112260
80101ae3:	e8 af 3c 00 00       	call   80105797 <acquire>
80101ae8:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101aeb:	8b 45 08             	mov    0x8(%ebp),%eax
80101aee:	8b 40 08             	mov    0x8(%eax),%eax
80101af1:	83 f8 01             	cmp    $0x1,%eax
80101af4:	0f 85 a9 00 00 00    	jne    80101ba3 <iput+0xce>
80101afa:	8b 45 08             	mov    0x8(%ebp),%eax
80101afd:	8b 40 0c             	mov    0xc(%eax),%eax
80101b00:	83 e0 02             	and    $0x2,%eax
80101b03:	85 c0                	test   %eax,%eax
80101b05:	0f 84 98 00 00 00    	je     80101ba3 <iput+0xce>
80101b0b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b0e:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b12:	66 85 c0             	test   %ax,%ax
80101b15:	0f 85 88 00 00 00    	jne    80101ba3 <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b1b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b1e:	8b 40 0c             	mov    0xc(%eax),%eax
80101b21:	83 e0 01             	and    $0x1,%eax
80101b24:	85 c0                	test   %eax,%eax
80101b26:	74 0d                	je     80101b35 <iput+0x60>
      panic("iput busy");
80101b28:	83 ec 0c             	sub    $0xc,%esp
80101b2b:	68 50 8f 10 80       	push   $0x80108f50
80101b30:	e8 31 ea ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 40 0c             	mov    0xc(%eax),%eax
80101b3b:	83 c8 01             	or     $0x1,%eax
80101b3e:	89 c2                	mov    %eax,%edx
80101b40:	8b 45 08             	mov    0x8(%ebp),%eax
80101b43:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b46:	83 ec 0c             	sub    $0xc,%esp
80101b49:	68 60 22 11 80       	push   $0x80112260
80101b4e:	e8 ab 3c 00 00       	call   801057fe <release>
80101b53:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101b56:	83 ec 0c             	sub    $0xc,%esp
80101b59:	ff 75 08             	pushl  0x8(%ebp)
80101b5c:	e8 a8 01 00 00       	call   80101d09 <itrunc>
80101b61:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101b64:	8b 45 08             	mov    0x8(%ebp),%eax
80101b67:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101b6d:	83 ec 0c             	sub    $0xc,%esp
80101b70:	ff 75 08             	pushl  0x8(%ebp)
80101b73:	e8 bf fb ff ff       	call   80101737 <iupdate>
80101b78:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101b7b:	83 ec 0c             	sub    $0xc,%esp
80101b7e:	68 60 22 11 80       	push   $0x80112260
80101b83:	e8 0f 3c 00 00       	call   80105797 <acquire>
80101b88:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101b8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8e:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101b95:	83 ec 0c             	sub    $0xc,%esp
80101b98:	ff 75 08             	pushl  0x8(%ebp)
80101b9b:	e8 b9 33 00 00       	call   80104f59 <wakeup>
80101ba0:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101ba3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ba6:	8b 40 08             	mov    0x8(%eax),%eax
80101ba9:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bac:	8b 45 08             	mov    0x8(%ebp),%eax
80101baf:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bb2:	83 ec 0c             	sub    $0xc,%esp
80101bb5:	68 60 22 11 80       	push   $0x80112260
80101bba:	e8 3f 3c 00 00       	call   801057fe <release>
80101bbf:	83 c4 10             	add    $0x10,%esp
}
80101bc2:	90                   	nop
80101bc3:	c9                   	leave  
80101bc4:	c3                   	ret    

80101bc5 <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101bc5:	55                   	push   %ebp
80101bc6:	89 e5                	mov    %esp,%ebp
80101bc8:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101bcb:	83 ec 0c             	sub    $0xc,%esp
80101bce:	ff 75 08             	pushl  0x8(%ebp)
80101bd1:	e8 8d fe ff ff       	call   80101a63 <iunlock>
80101bd6:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101bd9:	83 ec 0c             	sub    $0xc,%esp
80101bdc:	ff 75 08             	pushl  0x8(%ebp)
80101bdf:	e8 f1 fe ff ff       	call   80101ad5 <iput>
80101be4:	83 c4 10             	add    $0x10,%esp
}
80101be7:	90                   	nop
80101be8:	c9                   	leave  
80101be9:	c3                   	ret    

80101bea <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101bea:	55                   	push   %ebp
80101beb:	89 e5                	mov    %esp,%ebp
80101bed:	53                   	push   %ebx
80101bee:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101bf1:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101bf5:	77 42                	ja     80101c39 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101bf7:	8b 45 08             	mov    0x8(%ebp),%eax
80101bfa:	8b 55 0c             	mov    0xc(%ebp),%edx
80101bfd:	83 c2 04             	add    $0x4,%edx
80101c00:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c04:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c07:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c0b:	75 24                	jne    80101c31 <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c0d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c10:	8b 00                	mov    (%eax),%eax
80101c12:	83 ec 0c             	sub    $0xc,%esp
80101c15:	50                   	push   %eax
80101c16:	e8 e4 f7 ff ff       	call   801013ff <balloc>
80101c1b:	83 c4 10             	add    $0x10,%esp
80101c1e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c21:	8b 45 08             	mov    0x8(%ebp),%eax
80101c24:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c27:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c2d:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c31:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c34:	e9 cb 00 00 00       	jmp    80101d04 <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c39:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c3d:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c41:	0f 87 b0 00 00 00    	ja     80101cf7 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c47:	8b 45 08             	mov    0x8(%ebp),%eax
80101c4a:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c4d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c50:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c54:	75 1d                	jne    80101c73 <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101c56:	8b 45 08             	mov    0x8(%ebp),%eax
80101c59:	8b 00                	mov    (%eax),%eax
80101c5b:	83 ec 0c             	sub    $0xc,%esp
80101c5e:	50                   	push   %eax
80101c5f:	e8 9b f7 ff ff       	call   801013ff <balloc>
80101c64:	83 c4 10             	add    $0x10,%esp
80101c67:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6a:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c70:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101c73:	8b 45 08             	mov    0x8(%ebp),%eax
80101c76:	8b 00                	mov    (%eax),%eax
80101c78:	83 ec 08             	sub    $0x8,%esp
80101c7b:	ff 75 f4             	pushl  -0xc(%ebp)
80101c7e:	50                   	push   %eax
80101c7f:	e8 32 e5 ff ff       	call   801001b6 <bread>
80101c84:	83 c4 10             	add    $0x10,%esp
80101c87:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101c8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101c8d:	83 c0 18             	add    $0x18,%eax
80101c90:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101c93:	8b 45 0c             	mov    0xc(%ebp),%eax
80101c96:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101c9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ca0:	01 d0                	add    %edx,%eax
80101ca2:	8b 00                	mov    (%eax),%eax
80101ca4:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101ca7:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cab:	75 37                	jne    80101ce4 <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cad:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cb0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101cb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cba:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 00                	mov    (%eax),%eax
80101cc2:	83 ec 0c             	sub    $0xc,%esp
80101cc5:	50                   	push   %eax
80101cc6:	e8 34 f7 ff ff       	call   801013ff <balloc>
80101ccb:	83 c4 10             	add    $0x10,%esp
80101cce:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cd4:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	ff 75 f0             	pushl  -0x10(%ebp)
80101cdc:	e8 0b 1a 00 00       	call   801036ec <log_write>
80101ce1:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101ce4:	83 ec 0c             	sub    $0xc,%esp
80101ce7:	ff 75 f0             	pushl  -0x10(%ebp)
80101cea:	e8 3f e5 ff ff       	call   8010022e <brelse>
80101cef:	83 c4 10             	add    $0x10,%esp
    return addr;
80101cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101cf5:	eb 0d                	jmp    80101d04 <bmap+0x11a>
  }

  panic("bmap: out of range");
80101cf7:	83 ec 0c             	sub    $0xc,%esp
80101cfa:	68 5a 8f 10 80       	push   $0x80108f5a
80101cff:	e8 62 e8 ff ff       	call   80100566 <panic>
}
80101d04:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d07:	c9                   	leave  
80101d08:	c3                   	ret    

80101d09 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d09:	55                   	push   %ebp
80101d0a:	89 e5                	mov    %esp,%ebp
80101d0c:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d0f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d16:	eb 45                	jmp    80101d5d <itrunc+0x54>
    if(ip->addrs[i]){
80101d18:	8b 45 08             	mov    0x8(%ebp),%eax
80101d1b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d1e:	83 c2 04             	add    $0x4,%edx
80101d21:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d25:	85 c0                	test   %eax,%eax
80101d27:	74 30                	je     80101d59 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d29:	8b 45 08             	mov    0x8(%ebp),%eax
80101d2c:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d2f:	83 c2 04             	add    $0x4,%edx
80101d32:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d36:	8b 55 08             	mov    0x8(%ebp),%edx
80101d39:	8b 12                	mov    (%edx),%edx
80101d3b:	83 ec 08             	sub    $0x8,%esp
80101d3e:	50                   	push   %eax
80101d3f:	52                   	push   %edx
80101d40:	e8 18 f8 ff ff       	call   8010155d <bfree>
80101d45:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d48:	8b 45 08             	mov    0x8(%ebp),%eax
80101d4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d4e:	83 c2 04             	add    $0x4,%edx
80101d51:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101d58:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d59:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101d5d:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101d61:	7e b5                	jle    80101d18 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101d63:	8b 45 08             	mov    0x8(%ebp),%eax
80101d66:	8b 40 4c             	mov    0x4c(%eax),%eax
80101d69:	85 c0                	test   %eax,%eax
80101d6b:	0f 84 a1 00 00 00    	je     80101e12 <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101d71:	8b 45 08             	mov    0x8(%ebp),%eax
80101d74:	8b 50 4c             	mov    0x4c(%eax),%edx
80101d77:	8b 45 08             	mov    0x8(%ebp),%eax
80101d7a:	8b 00                	mov    (%eax),%eax
80101d7c:	83 ec 08             	sub    $0x8,%esp
80101d7f:	52                   	push   %edx
80101d80:	50                   	push   %eax
80101d81:	e8 30 e4 ff ff       	call   801001b6 <bread>
80101d86:	83 c4 10             	add    $0x10,%esp
80101d89:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101d8c:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d8f:	83 c0 18             	add    $0x18,%eax
80101d92:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101d95:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101d9c:	eb 3c                	jmp    80101dda <itrunc+0xd1>
      if(a[j])
80101d9e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101da1:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101da8:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dab:	01 d0                	add    %edx,%eax
80101dad:	8b 00                	mov    (%eax),%eax
80101daf:	85 c0                	test   %eax,%eax
80101db1:	74 23                	je     80101dd6 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101db3:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101db6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101dbd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101dc0:	01 d0                	add    %edx,%eax
80101dc2:	8b 00                	mov    (%eax),%eax
80101dc4:	8b 55 08             	mov    0x8(%ebp),%edx
80101dc7:	8b 12                	mov    (%edx),%edx
80101dc9:	83 ec 08             	sub    $0x8,%esp
80101dcc:	50                   	push   %eax
80101dcd:	52                   	push   %edx
80101dce:	e8 8a f7 ff ff       	call   8010155d <bfree>
80101dd3:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101dd6:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101dda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101ddd:	83 f8 7f             	cmp    $0x7f,%eax
80101de0:	76 bc                	jbe    80101d9e <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101de2:	83 ec 0c             	sub    $0xc,%esp
80101de5:	ff 75 ec             	pushl  -0x14(%ebp)
80101de8:	e8 41 e4 ff ff       	call   8010022e <brelse>
80101ded:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101df0:	8b 45 08             	mov    0x8(%ebp),%eax
80101df3:	8b 40 4c             	mov    0x4c(%eax),%eax
80101df6:	8b 55 08             	mov    0x8(%ebp),%edx
80101df9:	8b 12                	mov    (%edx),%edx
80101dfb:	83 ec 08             	sub    $0x8,%esp
80101dfe:	50                   	push   %eax
80101dff:	52                   	push   %edx
80101e00:	e8 58 f7 ff ff       	call   8010155d <bfree>
80101e05:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e08:	8b 45 08             	mov    0x8(%ebp),%eax
80101e0b:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e12:	8b 45 08             	mov    0x8(%ebp),%eax
80101e15:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e1c:	83 ec 0c             	sub    $0xc,%esp
80101e1f:	ff 75 08             	pushl  0x8(%ebp)
80101e22:	e8 10 f9 ff ff       	call   80101737 <iupdate>
80101e27:	83 c4 10             	add    $0x10,%esp
}
80101e2a:	90                   	nop
80101e2b:	c9                   	leave  
80101e2c:	c3                   	ret    

80101e2d <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e2d:	55                   	push   %ebp
80101e2e:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e30:	8b 45 08             	mov    0x8(%ebp),%eax
80101e33:	8b 00                	mov    (%eax),%eax
80101e35:	89 c2                	mov    %eax,%edx
80101e37:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e3a:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e3d:	8b 45 08             	mov    0x8(%ebp),%eax
80101e40:	8b 50 04             	mov    0x4(%eax),%edx
80101e43:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e46:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e49:	8b 45 08             	mov    0x8(%ebp),%eax
80101e4c:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e50:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e53:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101e56:	8b 45 08             	mov    0x8(%ebp),%eax
80101e59:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101e5d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e60:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101e64:	8b 45 08             	mov    0x8(%ebp),%eax
80101e67:	8b 50 18             	mov    0x18(%eax),%edx
80101e6a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e6d:	89 50 10             	mov    %edx,0x10(%eax)
}
80101e70:	90                   	nop
80101e71:	5d                   	pop    %ebp
80101e72:	c3                   	ret    

80101e73 <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101e73:	55                   	push   %ebp
80101e74:	89 e5                	mov    %esp,%ebp
80101e76:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101e79:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7c:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101e80:	66 83 f8 03          	cmp    $0x3,%ax
80101e84:	75 5c                	jne    80101ee2 <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101e86:	8b 45 08             	mov    0x8(%ebp),%eax
80101e89:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e8d:	66 85 c0             	test   %ax,%ax
80101e90:	78 20                	js     80101eb2 <readi+0x3f>
80101e92:	8b 45 08             	mov    0x8(%ebp),%eax
80101e95:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101e99:	66 83 f8 09          	cmp    $0x9,%ax
80101e9d:	7f 13                	jg     80101eb2 <readi+0x3f>
80101e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea2:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ea6:	98                   	cwtl   
80101ea7:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101eae:	85 c0                	test   %eax,%eax
80101eb0:	75 0a                	jne    80101ebc <readi+0x49>
      return -1;
80101eb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eb7:	e9 0c 01 00 00       	jmp    80101fc8 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101ebc:	8b 45 08             	mov    0x8(%ebp),%eax
80101ebf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ec3:	98                   	cwtl   
80101ec4:	8b 04 c5 00 22 11 80 	mov    -0x7feede00(,%eax,8),%eax
80101ecb:	8b 55 14             	mov    0x14(%ebp),%edx
80101ece:	83 ec 04             	sub    $0x4,%esp
80101ed1:	52                   	push   %edx
80101ed2:	ff 75 0c             	pushl  0xc(%ebp)
80101ed5:	ff 75 08             	pushl  0x8(%ebp)
80101ed8:	ff d0                	call   *%eax
80101eda:	83 c4 10             	add    $0x10,%esp
80101edd:	e9 e6 00 00 00       	jmp    80101fc8 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101ee2:	8b 45 08             	mov    0x8(%ebp),%eax
80101ee5:	8b 40 18             	mov    0x18(%eax),%eax
80101ee8:	3b 45 10             	cmp    0x10(%ebp),%eax
80101eeb:	72 0d                	jb     80101efa <readi+0x87>
80101eed:	8b 55 10             	mov    0x10(%ebp),%edx
80101ef0:	8b 45 14             	mov    0x14(%ebp),%eax
80101ef3:	01 d0                	add    %edx,%eax
80101ef5:	3b 45 10             	cmp    0x10(%ebp),%eax
80101ef8:	73 0a                	jae    80101f04 <readi+0x91>
    return -1;
80101efa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101eff:	e9 c4 00 00 00       	jmp    80101fc8 <readi+0x155>
  if(off + n > ip->size)
80101f04:	8b 55 10             	mov    0x10(%ebp),%edx
80101f07:	8b 45 14             	mov    0x14(%ebp),%eax
80101f0a:	01 c2                	add    %eax,%edx
80101f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f0f:	8b 40 18             	mov    0x18(%eax),%eax
80101f12:	39 c2                	cmp    %eax,%edx
80101f14:	76 0c                	jbe    80101f22 <readi+0xaf>
    n = ip->size - off;
80101f16:	8b 45 08             	mov    0x8(%ebp),%eax
80101f19:	8b 40 18             	mov    0x18(%eax),%eax
80101f1c:	2b 45 10             	sub    0x10(%ebp),%eax
80101f1f:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f22:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f29:	e9 8b 00 00 00       	jmp    80101fb9 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f2e:	8b 45 10             	mov    0x10(%ebp),%eax
80101f31:	c1 e8 09             	shr    $0x9,%eax
80101f34:	83 ec 08             	sub    $0x8,%esp
80101f37:	50                   	push   %eax
80101f38:	ff 75 08             	pushl  0x8(%ebp)
80101f3b:	e8 aa fc ff ff       	call   80101bea <bmap>
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	89 c2                	mov    %eax,%edx
80101f45:	8b 45 08             	mov    0x8(%ebp),%eax
80101f48:	8b 00                	mov    (%eax),%eax
80101f4a:	83 ec 08             	sub    $0x8,%esp
80101f4d:	52                   	push   %edx
80101f4e:	50                   	push   %eax
80101f4f:	e8 62 e2 ff ff       	call   801001b6 <bread>
80101f54:	83 c4 10             	add    $0x10,%esp
80101f57:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101f5a:	8b 45 10             	mov    0x10(%ebp),%eax
80101f5d:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f62:	ba 00 02 00 00       	mov    $0x200,%edx
80101f67:	29 c2                	sub    %eax,%edx
80101f69:	8b 45 14             	mov    0x14(%ebp),%eax
80101f6c:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101f6f:	39 c2                	cmp    %eax,%edx
80101f71:	0f 46 c2             	cmovbe %edx,%eax
80101f74:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101f77:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101f7a:	8d 50 18             	lea    0x18(%eax),%edx
80101f7d:	8b 45 10             	mov    0x10(%ebp),%eax
80101f80:	25 ff 01 00 00       	and    $0x1ff,%eax
80101f85:	01 d0                	add    %edx,%eax
80101f87:	83 ec 04             	sub    $0x4,%esp
80101f8a:	ff 75 ec             	pushl  -0x14(%ebp)
80101f8d:	50                   	push   %eax
80101f8e:	ff 75 0c             	pushl  0xc(%ebp)
80101f91:	e8 23 3b 00 00       	call   80105ab9 <memmove>
80101f96:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101f99:	83 ec 0c             	sub    $0xc,%esp
80101f9c:	ff 75 f0             	pushl  -0x10(%ebp)
80101f9f:	e8 8a e2 ff ff       	call   8010022e <brelse>
80101fa4:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101fa7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101faa:	01 45 f4             	add    %eax,-0xc(%ebp)
80101fad:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb0:	01 45 10             	add    %eax,0x10(%ebp)
80101fb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101fb6:	01 45 0c             	add    %eax,0xc(%ebp)
80101fb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101fbc:	3b 45 14             	cmp    0x14(%ebp),%eax
80101fbf:	0f 82 69 ff ff ff    	jb     80101f2e <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
80101fc5:	8b 45 14             	mov    0x14(%ebp),%eax
}
80101fc8:	c9                   	leave  
80101fc9:	c3                   	ret    

80101fca <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101fca:	55                   	push   %ebp
80101fcb:	89 e5                	mov    %esp,%ebp
80101fcd:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101fd0:	8b 45 08             	mov    0x8(%ebp),%eax
80101fd3:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101fd7:	66 83 f8 03          	cmp    $0x3,%ax
80101fdb:	75 5c                	jne    80102039 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101fdd:	8b 45 08             	mov    0x8(%ebp),%eax
80101fe0:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101fe4:	66 85 c0             	test   %ax,%ax
80101fe7:	78 20                	js     80102009 <writei+0x3f>
80101fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80101fec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ff0:	66 83 f8 09          	cmp    $0x9,%ax
80101ff4:	7f 13                	jg     80102009 <writei+0x3f>
80101ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ff9:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ffd:	98                   	cwtl   
80101ffe:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102005:	85 c0                	test   %eax,%eax
80102007:	75 0a                	jne    80102013 <writei+0x49>
      return -1;
80102009:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010200e:	e9 3d 01 00 00       	jmp    80102150 <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
80102013:	8b 45 08             	mov    0x8(%ebp),%eax
80102016:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010201a:	98                   	cwtl   
8010201b:	8b 04 c5 04 22 11 80 	mov    -0x7feeddfc(,%eax,8),%eax
80102022:	8b 55 14             	mov    0x14(%ebp),%edx
80102025:	83 ec 04             	sub    $0x4,%esp
80102028:	52                   	push   %edx
80102029:	ff 75 0c             	pushl  0xc(%ebp)
8010202c:	ff 75 08             	pushl  0x8(%ebp)
8010202f:	ff d0                	call   *%eax
80102031:	83 c4 10             	add    $0x10,%esp
80102034:	e9 17 01 00 00       	jmp    80102150 <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102039:	8b 45 08             	mov    0x8(%ebp),%eax
8010203c:	8b 40 18             	mov    0x18(%eax),%eax
8010203f:	3b 45 10             	cmp    0x10(%ebp),%eax
80102042:	72 0d                	jb     80102051 <writei+0x87>
80102044:	8b 55 10             	mov    0x10(%ebp),%edx
80102047:	8b 45 14             	mov    0x14(%ebp),%eax
8010204a:	01 d0                	add    %edx,%eax
8010204c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010204f:	73 0a                	jae    8010205b <writei+0x91>
    return -1;
80102051:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102056:	e9 f5 00 00 00       	jmp    80102150 <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
8010205b:	8b 55 10             	mov    0x10(%ebp),%edx
8010205e:	8b 45 14             	mov    0x14(%ebp),%eax
80102061:	01 d0                	add    %edx,%eax
80102063:	3d 00 18 01 00       	cmp    $0x11800,%eax
80102068:	76 0a                	jbe    80102074 <writei+0xaa>
    return -1;
8010206a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010206f:	e9 dc 00 00 00       	jmp    80102150 <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102074:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010207b:	e9 99 00 00 00       	jmp    80102119 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80102080:	8b 45 10             	mov    0x10(%ebp),%eax
80102083:	c1 e8 09             	shr    $0x9,%eax
80102086:	83 ec 08             	sub    $0x8,%esp
80102089:	50                   	push   %eax
8010208a:	ff 75 08             	pushl  0x8(%ebp)
8010208d:	e8 58 fb ff ff       	call   80101bea <bmap>
80102092:	83 c4 10             	add    $0x10,%esp
80102095:	89 c2                	mov    %eax,%edx
80102097:	8b 45 08             	mov    0x8(%ebp),%eax
8010209a:	8b 00                	mov    (%eax),%eax
8010209c:	83 ec 08             	sub    $0x8,%esp
8010209f:	52                   	push   %edx
801020a0:	50                   	push   %eax
801020a1:	e8 10 e1 ff ff       	call   801001b6 <bread>
801020a6:	83 c4 10             	add    $0x10,%esp
801020a9:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020ac:	8b 45 10             	mov    0x10(%ebp),%eax
801020af:	25 ff 01 00 00       	and    $0x1ff,%eax
801020b4:	ba 00 02 00 00       	mov    $0x200,%edx
801020b9:	29 c2                	sub    %eax,%edx
801020bb:	8b 45 14             	mov    0x14(%ebp),%eax
801020be:	2b 45 f4             	sub    -0xc(%ebp),%eax
801020c1:	39 c2                	cmp    %eax,%edx
801020c3:	0f 46 c2             	cmovbe %edx,%eax
801020c6:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
801020c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801020cc:	8d 50 18             	lea    0x18(%eax),%edx
801020cf:	8b 45 10             	mov    0x10(%ebp),%eax
801020d2:	25 ff 01 00 00       	and    $0x1ff,%eax
801020d7:	01 d0                	add    %edx,%eax
801020d9:	83 ec 04             	sub    $0x4,%esp
801020dc:	ff 75 ec             	pushl  -0x14(%ebp)
801020df:	ff 75 0c             	pushl  0xc(%ebp)
801020e2:	50                   	push   %eax
801020e3:	e8 d1 39 00 00       	call   80105ab9 <memmove>
801020e8:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
801020eb:	83 ec 0c             	sub    $0xc,%esp
801020ee:	ff 75 f0             	pushl  -0x10(%ebp)
801020f1:	e8 f6 15 00 00       	call   801036ec <log_write>
801020f6:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
801020f9:	83 ec 0c             	sub    $0xc,%esp
801020fc:	ff 75 f0             	pushl  -0x10(%ebp)
801020ff:	e8 2a e1 ff ff       	call   8010022e <brelse>
80102104:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102107:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010210a:	01 45 f4             	add    %eax,-0xc(%ebp)
8010210d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102110:	01 45 10             	add    %eax,0x10(%ebp)
80102113:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102116:	01 45 0c             	add    %eax,0xc(%ebp)
80102119:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010211c:	3b 45 14             	cmp    0x14(%ebp),%eax
8010211f:	0f 82 5b ff ff ff    	jb     80102080 <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
80102125:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102129:	74 22                	je     8010214d <writei+0x183>
8010212b:	8b 45 08             	mov    0x8(%ebp),%eax
8010212e:	8b 40 18             	mov    0x18(%eax),%eax
80102131:	3b 45 10             	cmp    0x10(%ebp),%eax
80102134:	73 17                	jae    8010214d <writei+0x183>
    ip->size = off;
80102136:	8b 45 08             	mov    0x8(%ebp),%eax
80102139:	8b 55 10             	mov    0x10(%ebp),%edx
8010213c:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
8010213f:	83 ec 0c             	sub    $0xc,%esp
80102142:	ff 75 08             	pushl  0x8(%ebp)
80102145:	e8 ed f5 ff ff       	call   80101737 <iupdate>
8010214a:	83 c4 10             	add    $0x10,%esp
  }
  return n;
8010214d:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102150:	c9                   	leave  
80102151:	c3                   	ret    

80102152 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80102152:	55                   	push   %ebp
80102153:	89 e5                	mov    %esp,%ebp
80102155:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
80102158:	83 ec 04             	sub    $0x4,%esp
8010215b:	6a 0e                	push   $0xe
8010215d:	ff 75 0c             	pushl  0xc(%ebp)
80102160:	ff 75 08             	pushl  0x8(%ebp)
80102163:	e8 e7 39 00 00       	call   80105b4f <strncmp>
80102168:	83 c4 10             	add    $0x10,%esp
}
8010216b:	c9                   	leave  
8010216c:	c3                   	ret    

8010216d <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
8010216d:	55                   	push   %ebp
8010216e:	89 e5                	mov    %esp,%ebp
80102170:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80102173:	8b 45 08             	mov    0x8(%ebp),%eax
80102176:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010217a:	66 83 f8 01          	cmp    $0x1,%ax
8010217e:	74 0d                	je     8010218d <dirlookup+0x20>
    panic("dirlookup not DIR");
80102180:	83 ec 0c             	sub    $0xc,%esp
80102183:	68 6d 8f 10 80       	push   $0x80108f6d
80102188:	e8 d9 e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
8010218d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102194:	eb 7b                	jmp    80102211 <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102196:	6a 10                	push   $0x10
80102198:	ff 75 f4             	pushl  -0xc(%ebp)
8010219b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010219e:	50                   	push   %eax
8010219f:	ff 75 08             	pushl  0x8(%ebp)
801021a2:	e8 cc fc ff ff       	call   80101e73 <readi>
801021a7:	83 c4 10             	add    $0x10,%esp
801021aa:	83 f8 10             	cmp    $0x10,%eax
801021ad:	74 0d                	je     801021bc <dirlookup+0x4f>
      panic("dirlink read");
801021af:	83 ec 0c             	sub    $0xc,%esp
801021b2:	68 7f 8f 10 80       	push   $0x80108f7f
801021b7:	e8 aa e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801021bc:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021c0:	66 85 c0             	test   %ax,%ax
801021c3:	74 47                	je     8010220c <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
801021c5:	83 ec 08             	sub    $0x8,%esp
801021c8:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021cb:	83 c0 02             	add    $0x2,%eax
801021ce:	50                   	push   %eax
801021cf:	ff 75 0c             	pushl  0xc(%ebp)
801021d2:	e8 7b ff ff ff       	call   80102152 <namecmp>
801021d7:	83 c4 10             	add    $0x10,%esp
801021da:	85 c0                	test   %eax,%eax
801021dc:	75 2f                	jne    8010220d <dirlookup+0xa0>
      // entry matches path element
      if(poff)
801021de:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801021e2:	74 08                	je     801021ec <dirlookup+0x7f>
        *poff = off;
801021e4:	8b 45 10             	mov    0x10(%ebp),%eax
801021e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
801021ea:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
801021ec:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801021f0:	0f b7 c0             	movzwl %ax,%eax
801021f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
801021f6:	8b 45 08             	mov    0x8(%ebp),%eax
801021f9:	8b 00                	mov    (%eax),%eax
801021fb:	83 ec 08             	sub    $0x8,%esp
801021fe:	ff 75 f0             	pushl  -0x10(%ebp)
80102201:	50                   	push   %eax
80102202:	e8 eb f5 ff ff       	call   801017f2 <iget>
80102207:	83 c4 10             	add    $0x10,%esp
8010220a:	eb 19                	jmp    80102225 <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
8010220c:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
8010220d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80102211:	8b 45 08             	mov    0x8(%ebp),%eax
80102214:	8b 40 18             	mov    0x18(%eax),%eax
80102217:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010221a:	0f 87 76 ff ff ff    	ja     80102196 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
80102220:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102225:	c9                   	leave  
80102226:	c3                   	ret    

80102227 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102227:	55                   	push   %ebp
80102228:	89 e5                	mov    %esp,%ebp
8010222a:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
8010222d:	83 ec 04             	sub    $0x4,%esp
80102230:	6a 00                	push   $0x0
80102232:	ff 75 0c             	pushl  0xc(%ebp)
80102235:	ff 75 08             	pushl  0x8(%ebp)
80102238:	e8 30 ff ff ff       	call   8010216d <dirlookup>
8010223d:	83 c4 10             	add    $0x10,%esp
80102240:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102243:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102247:	74 18                	je     80102261 <dirlink+0x3a>
    iput(ip);
80102249:	83 ec 0c             	sub    $0xc,%esp
8010224c:	ff 75 f0             	pushl  -0x10(%ebp)
8010224f:	e8 81 f8 ff ff       	call   80101ad5 <iput>
80102254:	83 c4 10             	add    $0x10,%esp
    return -1;
80102257:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010225c:	e9 9c 00 00 00       	jmp    801022fd <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
80102261:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102268:	eb 39                	jmp    801022a3 <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010226a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010226d:	6a 10                	push   $0x10
8010226f:	50                   	push   %eax
80102270:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102273:	50                   	push   %eax
80102274:	ff 75 08             	pushl  0x8(%ebp)
80102277:	e8 f7 fb ff ff       	call   80101e73 <readi>
8010227c:	83 c4 10             	add    $0x10,%esp
8010227f:	83 f8 10             	cmp    $0x10,%eax
80102282:	74 0d                	je     80102291 <dirlink+0x6a>
      panic("dirlink read");
80102284:	83 ec 0c             	sub    $0xc,%esp
80102287:	68 7f 8f 10 80       	push   $0x80108f7f
8010228c:	e8 d5 e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102291:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
80102295:	66 85 c0             	test   %ax,%ax
80102298:	74 18                	je     801022b2 <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
8010229a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010229d:	83 c0 10             	add    $0x10,%eax
801022a0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022a3:	8b 45 08             	mov    0x8(%ebp),%eax
801022a6:	8b 50 18             	mov    0x18(%eax),%edx
801022a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022ac:	39 c2                	cmp    %eax,%edx
801022ae:	77 ba                	ja     8010226a <dirlink+0x43>
801022b0:	eb 01                	jmp    801022b3 <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022b2:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022b3:	83 ec 04             	sub    $0x4,%esp
801022b6:	6a 0e                	push   $0xe
801022b8:	ff 75 0c             	pushl  0xc(%ebp)
801022bb:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022be:	83 c0 02             	add    $0x2,%eax
801022c1:	50                   	push   %eax
801022c2:	e8 de 38 00 00       	call   80105ba5 <strncpy>
801022c7:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
801022ca:	8b 45 10             	mov    0x10(%ebp),%eax
801022cd:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022d4:	6a 10                	push   $0x10
801022d6:	50                   	push   %eax
801022d7:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022da:	50                   	push   %eax
801022db:	ff 75 08             	pushl  0x8(%ebp)
801022de:	e8 e7 fc ff ff       	call   80101fca <writei>
801022e3:	83 c4 10             	add    $0x10,%esp
801022e6:	83 f8 10             	cmp    $0x10,%eax
801022e9:	74 0d                	je     801022f8 <dirlink+0xd1>
    panic("dirlink");
801022eb:	83 ec 0c             	sub    $0xc,%esp
801022ee:	68 8c 8f 10 80       	push   $0x80108f8c
801022f3:	e8 6e e2 ff ff       	call   80100566 <panic>
  
  return 0;
801022f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
801022fd:	c9                   	leave  
801022fe:	c3                   	ret    

801022ff <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
801022ff:	55                   	push   %ebp
80102300:	89 e5                	mov    %esp,%ebp
80102302:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
80102305:	eb 04                	jmp    8010230b <skipelem+0xc>
    path++;
80102307:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
8010230b:	8b 45 08             	mov    0x8(%ebp),%eax
8010230e:	0f b6 00             	movzbl (%eax),%eax
80102311:	3c 2f                	cmp    $0x2f,%al
80102313:	74 f2                	je     80102307 <skipelem+0x8>
    path++;
  if(*path == 0)
80102315:	8b 45 08             	mov    0x8(%ebp),%eax
80102318:	0f b6 00             	movzbl (%eax),%eax
8010231b:	84 c0                	test   %al,%al
8010231d:	75 07                	jne    80102326 <skipelem+0x27>
    return 0;
8010231f:	b8 00 00 00 00       	mov    $0x0,%eax
80102324:	eb 7b                	jmp    801023a1 <skipelem+0xa2>
  s = path;
80102326:	8b 45 08             	mov    0x8(%ebp),%eax
80102329:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
8010232c:	eb 04                	jmp    80102332 <skipelem+0x33>
    path++;
8010232e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
80102332:	8b 45 08             	mov    0x8(%ebp),%eax
80102335:	0f b6 00             	movzbl (%eax),%eax
80102338:	3c 2f                	cmp    $0x2f,%al
8010233a:	74 0a                	je     80102346 <skipelem+0x47>
8010233c:	8b 45 08             	mov    0x8(%ebp),%eax
8010233f:	0f b6 00             	movzbl (%eax),%eax
80102342:	84 c0                	test   %al,%al
80102344:	75 e8                	jne    8010232e <skipelem+0x2f>
    path++;
  len = path - s;
80102346:	8b 55 08             	mov    0x8(%ebp),%edx
80102349:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010234c:	29 c2                	sub    %eax,%edx
8010234e:	89 d0                	mov    %edx,%eax
80102350:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
80102353:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
80102357:	7e 15                	jle    8010236e <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
80102359:	83 ec 04             	sub    $0x4,%esp
8010235c:	6a 0e                	push   $0xe
8010235e:	ff 75 f4             	pushl  -0xc(%ebp)
80102361:	ff 75 0c             	pushl  0xc(%ebp)
80102364:	e8 50 37 00 00       	call   80105ab9 <memmove>
80102369:	83 c4 10             	add    $0x10,%esp
8010236c:	eb 26                	jmp    80102394 <skipelem+0x95>
  else {
    memmove(name, s, len);
8010236e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102371:	83 ec 04             	sub    $0x4,%esp
80102374:	50                   	push   %eax
80102375:	ff 75 f4             	pushl  -0xc(%ebp)
80102378:	ff 75 0c             	pushl  0xc(%ebp)
8010237b:	e8 39 37 00 00       	call   80105ab9 <memmove>
80102380:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
80102383:	8b 55 f0             	mov    -0x10(%ebp),%edx
80102386:	8b 45 0c             	mov    0xc(%ebp),%eax
80102389:	01 d0                	add    %edx,%eax
8010238b:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
8010238e:	eb 04                	jmp    80102394 <skipelem+0x95>
    path++;
80102390:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
80102394:	8b 45 08             	mov    0x8(%ebp),%eax
80102397:	0f b6 00             	movzbl (%eax),%eax
8010239a:	3c 2f                	cmp    $0x2f,%al
8010239c:	74 f2                	je     80102390 <skipelem+0x91>
    path++;
  return path;
8010239e:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023a1:	c9                   	leave  
801023a2:	c3                   	ret    

801023a3 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023a3:	55                   	push   %ebp
801023a4:	89 e5                	mov    %esp,%ebp
801023a6:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023a9:	8b 45 08             	mov    0x8(%ebp),%eax
801023ac:	0f b6 00             	movzbl (%eax),%eax
801023af:	3c 2f                	cmp    $0x2f,%al
801023b1:	75 17                	jne    801023ca <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023b3:	83 ec 08             	sub    $0x8,%esp
801023b6:	6a 01                	push   $0x1
801023b8:	6a 01                	push   $0x1
801023ba:	e8 33 f4 ff ff       	call   801017f2 <iget>
801023bf:	83 c4 10             	add    $0x10,%esp
801023c2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801023c5:	e9 bb 00 00 00       	jmp    80102485 <namex+0xe2>
  else
    ip = idup(proc->cwd);
801023ca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801023d0:	8b 40 68             	mov    0x68(%eax),%eax
801023d3:	83 ec 0c             	sub    $0xc,%esp
801023d6:	50                   	push   %eax
801023d7:	e8 f5 f4 ff ff       	call   801018d1 <idup>
801023dc:	83 c4 10             	add    $0x10,%esp
801023df:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
801023e2:	e9 9e 00 00 00       	jmp    80102485 <namex+0xe2>
    ilock(ip);
801023e7:	83 ec 0c             	sub    $0xc,%esp
801023ea:	ff 75 f4             	pushl  -0xc(%ebp)
801023ed:	e8 19 f5 ff ff       	call   8010190b <ilock>
801023f2:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
801023f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801023f8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801023fc:	66 83 f8 01          	cmp    $0x1,%ax
80102400:	74 18                	je     8010241a <namex+0x77>
      iunlockput(ip);
80102402:	83 ec 0c             	sub    $0xc,%esp
80102405:	ff 75 f4             	pushl  -0xc(%ebp)
80102408:	e8 b8 f7 ff ff       	call   80101bc5 <iunlockput>
8010240d:	83 c4 10             	add    $0x10,%esp
      return 0;
80102410:	b8 00 00 00 00       	mov    $0x0,%eax
80102415:	e9 a7 00 00 00       	jmp    801024c1 <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
8010241a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010241e:	74 20                	je     80102440 <namex+0x9d>
80102420:	8b 45 08             	mov    0x8(%ebp),%eax
80102423:	0f b6 00             	movzbl (%eax),%eax
80102426:	84 c0                	test   %al,%al
80102428:	75 16                	jne    80102440 <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
8010242a:	83 ec 0c             	sub    $0xc,%esp
8010242d:	ff 75 f4             	pushl  -0xc(%ebp)
80102430:	e8 2e f6 ff ff       	call   80101a63 <iunlock>
80102435:	83 c4 10             	add    $0x10,%esp
      return ip;
80102438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010243b:	e9 81 00 00 00       	jmp    801024c1 <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80102440:	83 ec 04             	sub    $0x4,%esp
80102443:	6a 00                	push   $0x0
80102445:	ff 75 10             	pushl  0x10(%ebp)
80102448:	ff 75 f4             	pushl  -0xc(%ebp)
8010244b:	e8 1d fd ff ff       	call   8010216d <dirlookup>
80102450:	83 c4 10             	add    $0x10,%esp
80102453:	89 45 f0             	mov    %eax,-0x10(%ebp)
80102456:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010245a:	75 15                	jne    80102471 <namex+0xce>
      iunlockput(ip);
8010245c:	83 ec 0c             	sub    $0xc,%esp
8010245f:	ff 75 f4             	pushl  -0xc(%ebp)
80102462:	e8 5e f7 ff ff       	call   80101bc5 <iunlockput>
80102467:	83 c4 10             	add    $0x10,%esp
      return 0;
8010246a:	b8 00 00 00 00       	mov    $0x0,%eax
8010246f:	eb 50                	jmp    801024c1 <namex+0x11e>
    }
    iunlockput(ip);
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	ff 75 f4             	pushl  -0xc(%ebp)
80102477:	e8 49 f7 ff ff       	call   80101bc5 <iunlockput>
8010247c:	83 c4 10             	add    $0x10,%esp
    ip = next;
8010247f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102482:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
80102485:	83 ec 08             	sub    $0x8,%esp
80102488:	ff 75 10             	pushl  0x10(%ebp)
8010248b:	ff 75 08             	pushl  0x8(%ebp)
8010248e:	e8 6c fe ff ff       	call   801022ff <skipelem>
80102493:	83 c4 10             	add    $0x10,%esp
80102496:	89 45 08             	mov    %eax,0x8(%ebp)
80102499:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010249d:	0f 85 44 ff ff ff    	jne    801023e7 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024a3:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024a7:	74 15                	je     801024be <namex+0x11b>
    iput(ip);
801024a9:	83 ec 0c             	sub    $0xc,%esp
801024ac:	ff 75 f4             	pushl  -0xc(%ebp)
801024af:	e8 21 f6 ff ff       	call   80101ad5 <iput>
801024b4:	83 c4 10             	add    $0x10,%esp
    return 0;
801024b7:	b8 00 00 00 00       	mov    $0x0,%eax
801024bc:	eb 03                	jmp    801024c1 <namex+0x11e>
  }
  return ip;
801024be:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801024c1:	c9                   	leave  
801024c2:	c3                   	ret    

801024c3 <namei>:

struct inode*
namei(char *path)
{
801024c3:	55                   	push   %ebp
801024c4:	89 e5                	mov    %esp,%ebp
801024c6:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
801024c9:	83 ec 04             	sub    $0x4,%esp
801024cc:	8d 45 ea             	lea    -0x16(%ebp),%eax
801024cf:	50                   	push   %eax
801024d0:	6a 00                	push   $0x0
801024d2:	ff 75 08             	pushl  0x8(%ebp)
801024d5:	e8 c9 fe ff ff       	call   801023a3 <namex>
801024da:	83 c4 10             	add    $0x10,%esp
}
801024dd:	c9                   	leave  
801024de:	c3                   	ret    

801024df <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801024df:	55                   	push   %ebp
801024e0:	89 e5                	mov    %esp,%ebp
801024e2:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
801024e5:	83 ec 04             	sub    $0x4,%esp
801024e8:	ff 75 0c             	pushl  0xc(%ebp)
801024eb:	6a 01                	push   $0x1
801024ed:	ff 75 08             	pushl  0x8(%ebp)
801024f0:	e8 ae fe ff ff       	call   801023a3 <namex>
801024f5:	83 c4 10             	add    $0x10,%esp
}
801024f8:	c9                   	leave  
801024f9:	c3                   	ret    

801024fa <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801024fa:	55                   	push   %ebp
801024fb:	89 e5                	mov    %esp,%ebp
801024fd:	83 ec 14             	sub    $0x14,%esp
80102500:	8b 45 08             	mov    0x8(%ebp),%eax
80102503:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102507:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
8010250b:	89 c2                	mov    %eax,%edx
8010250d:	ec                   	in     (%dx),%al
8010250e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102511:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102515:	c9                   	leave  
80102516:	c3                   	ret    

80102517 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102517:	55                   	push   %ebp
80102518:	89 e5                	mov    %esp,%ebp
8010251a:	57                   	push   %edi
8010251b:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
8010251c:	8b 55 08             	mov    0x8(%ebp),%edx
8010251f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102522:	8b 45 10             	mov    0x10(%ebp),%eax
80102525:	89 cb                	mov    %ecx,%ebx
80102527:	89 df                	mov    %ebx,%edi
80102529:	89 c1                	mov    %eax,%ecx
8010252b:	fc                   	cld    
8010252c:	f3 6d                	rep insl (%dx),%es:(%edi)
8010252e:	89 c8                	mov    %ecx,%eax
80102530:	89 fb                	mov    %edi,%ebx
80102532:	89 5d 0c             	mov    %ebx,0xc(%ebp)
80102535:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102538:	90                   	nop
80102539:	5b                   	pop    %ebx
8010253a:	5f                   	pop    %edi
8010253b:	5d                   	pop    %ebp
8010253c:	c3                   	ret    

8010253d <outb>:

static inline void
outb(ushort port, uchar data)
{
8010253d:	55                   	push   %ebp
8010253e:	89 e5                	mov    %esp,%ebp
80102540:	83 ec 08             	sub    $0x8,%esp
80102543:	8b 55 08             	mov    0x8(%ebp),%edx
80102546:	8b 45 0c             	mov    0xc(%ebp),%eax
80102549:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
8010254d:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102550:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102554:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102558:	ee                   	out    %al,(%dx)
}
80102559:	90                   	nop
8010255a:	c9                   	leave  
8010255b:	c3                   	ret    

8010255c <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
8010255c:	55                   	push   %ebp
8010255d:	89 e5                	mov    %esp,%ebp
8010255f:	56                   	push   %esi
80102560:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
80102561:	8b 55 08             	mov    0x8(%ebp),%edx
80102564:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102567:	8b 45 10             	mov    0x10(%ebp),%eax
8010256a:	89 cb                	mov    %ecx,%ebx
8010256c:	89 de                	mov    %ebx,%esi
8010256e:	89 c1                	mov    %eax,%ecx
80102570:	fc                   	cld    
80102571:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80102573:	89 c8                	mov    %ecx,%eax
80102575:	89 f3                	mov    %esi,%ebx
80102577:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010257a:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
8010257d:	90                   	nop
8010257e:	5b                   	pop    %ebx
8010257f:	5e                   	pop    %esi
80102580:	5d                   	pop    %ebp
80102581:	c3                   	ret    

80102582 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80102582:	55                   	push   %ebp
80102583:	89 e5                	mov    %esp,%ebp
80102585:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
80102588:	90                   	nop
80102589:	68 f7 01 00 00       	push   $0x1f7
8010258e:	e8 67 ff ff ff       	call   801024fa <inb>
80102593:	83 c4 04             	add    $0x4,%esp
80102596:	0f b6 c0             	movzbl %al,%eax
80102599:	89 45 fc             	mov    %eax,-0x4(%ebp)
8010259c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010259f:	25 c0 00 00 00       	and    $0xc0,%eax
801025a4:	83 f8 40             	cmp    $0x40,%eax
801025a7:	75 e0                	jne    80102589 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025a9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025ad:	74 11                	je     801025c0 <idewait+0x3e>
801025af:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025b2:	83 e0 21             	and    $0x21,%eax
801025b5:	85 c0                	test   %eax,%eax
801025b7:	74 07                	je     801025c0 <idewait+0x3e>
    return -1;
801025b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801025be:	eb 05                	jmp    801025c5 <idewait+0x43>
  return 0;
801025c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801025c5:	c9                   	leave  
801025c6:	c3                   	ret    

801025c7 <ideinit>:

void
ideinit(void)
{
801025c7:	55                   	push   %ebp
801025c8:	89 e5                	mov    %esp,%ebp
801025ca:	83 ec 18             	sub    $0x18,%esp
  int i;

  initlock(&idelock, "ide");
801025cd:	83 ec 08             	sub    $0x8,%esp
801025d0:	68 94 8f 10 80       	push   $0x80108f94
801025d5:	68 20 c6 10 80       	push   $0x8010c620
801025da:	e8 96 31 00 00       	call   80105775 <initlock>
801025df:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
801025e2:	83 ec 0c             	sub    $0xc,%esp
801025e5:	6a 0e                	push   $0xe
801025e7:	e8 b0 18 00 00       	call   80103e9c <picenable>
801025ec:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
801025ef:	a1 60 39 11 80       	mov    0x80113960,%eax
801025f4:	83 e8 01             	sub    $0x1,%eax
801025f7:	83 ec 08             	sub    $0x8,%esp
801025fa:	50                   	push   %eax
801025fb:	6a 0e                	push   $0xe
801025fd:	e8 37 04 00 00       	call   80102a39 <ioapicenable>
80102602:	83 c4 10             	add    $0x10,%esp
  idewait(0);
80102605:	83 ec 0c             	sub    $0xc,%esp
80102608:	6a 00                	push   $0x0
8010260a:	e8 73 ff ff ff       	call   80102582 <idewait>
8010260f:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
80102612:	83 ec 08             	sub    $0x8,%esp
80102615:	68 f0 00 00 00       	push   $0xf0
8010261a:	68 f6 01 00 00       	push   $0x1f6
8010261f:	e8 19 ff ff ff       	call   8010253d <outb>
80102624:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102627:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010262e:	eb 24                	jmp    80102654 <ideinit+0x8d>
    if(inb(0x1f7) != 0){
80102630:	83 ec 0c             	sub    $0xc,%esp
80102633:	68 f7 01 00 00       	push   $0x1f7
80102638:	e8 bd fe ff ff       	call   801024fa <inb>
8010263d:	83 c4 10             	add    $0x10,%esp
80102640:	84 c0                	test   %al,%al
80102642:	74 0c                	je     80102650 <ideinit+0x89>
      havedisk1 = 1;
80102644:	c7 05 58 c6 10 80 01 	movl   $0x1,0x8010c658
8010264b:	00 00 00 
      break;
8010264e:	eb 0d                	jmp    8010265d <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
80102650:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102654:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
8010265b:	7e d3                	jle    80102630 <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
8010265d:	83 ec 08             	sub    $0x8,%esp
80102660:	68 e0 00 00 00       	push   $0xe0
80102665:	68 f6 01 00 00       	push   $0x1f6
8010266a:	e8 ce fe ff ff       	call   8010253d <outb>
8010266f:	83 c4 10             	add    $0x10,%esp
}
80102672:	90                   	nop
80102673:	c9                   	leave  
80102674:	c3                   	ret    

80102675 <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102675:	55                   	push   %ebp
80102676:	89 e5                	mov    %esp,%ebp
80102678:	83 ec 08             	sub    $0x8,%esp
  if(b == 0)
8010267b:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010267f:	75 0d                	jne    8010268e <idestart+0x19>
    panic("idestart");
80102681:	83 ec 0c             	sub    $0xc,%esp
80102684:	68 98 8f 10 80       	push   $0x80108f98
80102689:	e8 d8 de ff ff       	call   80100566 <panic>

  idewait(0);
8010268e:	83 ec 0c             	sub    $0xc,%esp
80102691:	6a 00                	push   $0x0
80102693:	e8 ea fe ff ff       	call   80102582 <idewait>
80102698:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
8010269b:	83 ec 08             	sub    $0x8,%esp
8010269e:	6a 00                	push   $0x0
801026a0:	68 f6 03 00 00       	push   $0x3f6
801026a5:	e8 93 fe ff ff       	call   8010253d <outb>
801026aa:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, 1);  // number of sectors
801026ad:	83 ec 08             	sub    $0x8,%esp
801026b0:	6a 01                	push   $0x1
801026b2:	68 f2 01 00 00       	push   $0x1f2
801026b7:	e8 81 fe ff ff       	call   8010253d <outb>
801026bc:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, b->sector & 0xff);
801026bf:	8b 45 08             	mov    0x8(%ebp),%eax
801026c2:	8b 40 08             	mov    0x8(%eax),%eax
801026c5:	0f b6 c0             	movzbl %al,%eax
801026c8:	83 ec 08             	sub    $0x8,%esp
801026cb:	50                   	push   %eax
801026cc:	68 f3 01 00 00       	push   $0x1f3
801026d1:	e8 67 fe ff ff       	call   8010253d <outb>
801026d6:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (b->sector >> 8) & 0xff);
801026d9:	8b 45 08             	mov    0x8(%ebp),%eax
801026dc:	8b 40 08             	mov    0x8(%eax),%eax
801026df:	c1 e8 08             	shr    $0x8,%eax
801026e2:	0f b6 c0             	movzbl %al,%eax
801026e5:	83 ec 08             	sub    $0x8,%esp
801026e8:	50                   	push   %eax
801026e9:	68 f4 01 00 00       	push   $0x1f4
801026ee:	e8 4a fe ff ff       	call   8010253d <outb>
801026f3:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (b->sector >> 16) & 0xff);
801026f6:	8b 45 08             	mov    0x8(%ebp),%eax
801026f9:	8b 40 08             	mov    0x8(%eax),%eax
801026fc:	c1 e8 10             	shr    $0x10,%eax
801026ff:	0f b6 c0             	movzbl %al,%eax
80102702:	83 ec 08             	sub    $0x8,%esp
80102705:	50                   	push   %eax
80102706:	68 f5 01 00 00       	push   $0x1f5
8010270b:	e8 2d fe ff ff       	call   8010253d <outb>
80102710:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
80102713:	8b 45 08             	mov    0x8(%ebp),%eax
80102716:	8b 40 04             	mov    0x4(%eax),%eax
80102719:	83 e0 01             	and    $0x1,%eax
8010271c:	c1 e0 04             	shl    $0x4,%eax
8010271f:	89 c2                	mov    %eax,%edx
80102721:	8b 45 08             	mov    0x8(%ebp),%eax
80102724:	8b 40 08             	mov    0x8(%eax),%eax
80102727:	c1 e8 18             	shr    $0x18,%eax
8010272a:	83 e0 0f             	and    $0xf,%eax
8010272d:	09 d0                	or     %edx,%eax
8010272f:	83 c8 e0             	or     $0xffffffe0,%eax
80102732:	0f b6 c0             	movzbl %al,%eax
80102735:	83 ec 08             	sub    $0x8,%esp
80102738:	50                   	push   %eax
80102739:	68 f6 01 00 00       	push   $0x1f6
8010273e:	e8 fa fd ff ff       	call   8010253d <outb>
80102743:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
80102746:	8b 45 08             	mov    0x8(%ebp),%eax
80102749:	8b 00                	mov    (%eax),%eax
8010274b:	83 e0 04             	and    $0x4,%eax
8010274e:	85 c0                	test   %eax,%eax
80102750:	74 30                	je     80102782 <idestart+0x10d>
    outb(0x1f7, IDE_CMD_WRITE);
80102752:	83 ec 08             	sub    $0x8,%esp
80102755:	6a 30                	push   $0x30
80102757:	68 f7 01 00 00       	push   $0x1f7
8010275c:	e8 dc fd ff ff       	call   8010253d <outb>
80102761:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, 512/4);
80102764:	8b 45 08             	mov    0x8(%ebp),%eax
80102767:	83 c0 18             	add    $0x18,%eax
8010276a:	83 ec 04             	sub    $0x4,%esp
8010276d:	68 80 00 00 00       	push   $0x80
80102772:	50                   	push   %eax
80102773:	68 f0 01 00 00       	push   $0x1f0
80102778:	e8 df fd ff ff       	call   8010255c <outsl>
8010277d:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102780:	eb 12                	jmp    80102794 <idestart+0x11f>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((b->sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, 512/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102782:	83 ec 08             	sub    $0x8,%esp
80102785:	6a 20                	push   $0x20
80102787:	68 f7 01 00 00       	push   $0x1f7
8010278c:	e8 ac fd ff ff       	call   8010253d <outb>
80102791:	83 c4 10             	add    $0x10,%esp
  }
}
80102794:	90                   	nop
80102795:	c9                   	leave  
80102796:	c3                   	ret    

80102797 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102797:	55                   	push   %ebp
80102798:	89 e5                	mov    %esp,%ebp
8010279a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
8010279d:	83 ec 0c             	sub    $0xc,%esp
801027a0:	68 20 c6 10 80       	push   $0x8010c620
801027a5:	e8 ed 2f 00 00       	call   80105797 <acquire>
801027aa:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
801027ad:	a1 54 c6 10 80       	mov    0x8010c654,%eax
801027b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027b5:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801027b9:	75 15                	jne    801027d0 <ideintr+0x39>
    release(&idelock);
801027bb:	83 ec 0c             	sub    $0xc,%esp
801027be:	68 20 c6 10 80       	push   $0x8010c620
801027c3:	e8 36 30 00 00       	call   801057fe <release>
801027c8:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
801027cb:	e9 9a 00 00 00       	jmp    8010286a <ideintr+0xd3>
  }
  idequeue = b->qnext;
801027d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027d3:	8b 40 14             	mov    0x14(%eax),%eax
801027d6:	a3 54 c6 10 80       	mov    %eax,0x8010c654

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
801027db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027de:	8b 00                	mov    (%eax),%eax
801027e0:	83 e0 04             	and    $0x4,%eax
801027e3:	85 c0                	test   %eax,%eax
801027e5:	75 2d                	jne    80102814 <ideintr+0x7d>
801027e7:	83 ec 0c             	sub    $0xc,%esp
801027ea:	6a 01                	push   $0x1
801027ec:	e8 91 fd ff ff       	call   80102582 <idewait>
801027f1:	83 c4 10             	add    $0x10,%esp
801027f4:	85 c0                	test   %eax,%eax
801027f6:	78 1c                	js     80102814 <ideintr+0x7d>
    insl(0x1f0, b->data, 512/4);
801027f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801027fb:	83 c0 18             	add    $0x18,%eax
801027fe:	83 ec 04             	sub    $0x4,%esp
80102801:	68 80 00 00 00       	push   $0x80
80102806:	50                   	push   %eax
80102807:	68 f0 01 00 00       	push   $0x1f0
8010280c:	e8 06 fd ff ff       	call   80102517 <insl>
80102811:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80102814:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102817:	8b 00                	mov    (%eax),%eax
80102819:	83 c8 02             	or     $0x2,%eax
8010281c:	89 c2                	mov    %eax,%edx
8010281e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102821:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
80102823:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102826:	8b 00                	mov    (%eax),%eax
80102828:	83 e0 fb             	and    $0xfffffffb,%eax
8010282b:	89 c2                	mov    %eax,%edx
8010282d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102830:	89 10                	mov    %edx,(%eax)
  wakeup(b);
80102832:	83 ec 0c             	sub    $0xc,%esp
80102835:	ff 75 f4             	pushl  -0xc(%ebp)
80102838:	e8 1c 27 00 00       	call   80104f59 <wakeup>
8010283d:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
80102840:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102845:	85 c0                	test   %eax,%eax
80102847:	74 11                	je     8010285a <ideintr+0xc3>
    idestart(idequeue);
80102849:	a1 54 c6 10 80       	mov    0x8010c654,%eax
8010284e:	83 ec 0c             	sub    $0xc,%esp
80102851:	50                   	push   %eax
80102852:	e8 1e fe ff ff       	call   80102675 <idestart>
80102857:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
8010285a:	83 ec 0c             	sub    $0xc,%esp
8010285d:	68 20 c6 10 80       	push   $0x8010c620
80102862:	e8 97 2f 00 00       	call   801057fe <release>
80102867:	83 c4 10             	add    $0x10,%esp
}
8010286a:	c9                   	leave  
8010286b:	c3                   	ret    

8010286c <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
8010286c:	55                   	push   %ebp
8010286d:	89 e5                	mov    %esp,%ebp
8010286f:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
80102872:	8b 45 08             	mov    0x8(%ebp),%eax
80102875:	8b 00                	mov    (%eax),%eax
80102877:	83 e0 01             	and    $0x1,%eax
8010287a:	85 c0                	test   %eax,%eax
8010287c:	75 0d                	jne    8010288b <iderw+0x1f>
    panic("iderw: buf not busy");
8010287e:	83 ec 0c             	sub    $0xc,%esp
80102881:	68 a1 8f 10 80       	push   $0x80108fa1
80102886:	e8 db dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010288b:	8b 45 08             	mov    0x8(%ebp),%eax
8010288e:	8b 00                	mov    (%eax),%eax
80102890:	83 e0 06             	and    $0x6,%eax
80102893:	83 f8 02             	cmp    $0x2,%eax
80102896:	75 0d                	jne    801028a5 <iderw+0x39>
    panic("iderw: nothing to do");
80102898:	83 ec 0c             	sub    $0xc,%esp
8010289b:	68 b5 8f 10 80       	push   $0x80108fb5
801028a0:	e8 c1 dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
801028a5:	8b 45 08             	mov    0x8(%ebp),%eax
801028a8:	8b 40 04             	mov    0x4(%eax),%eax
801028ab:	85 c0                	test   %eax,%eax
801028ad:	74 16                	je     801028c5 <iderw+0x59>
801028af:	a1 58 c6 10 80       	mov    0x8010c658,%eax
801028b4:	85 c0                	test   %eax,%eax
801028b6:	75 0d                	jne    801028c5 <iderw+0x59>
    panic("iderw: ide disk 1 not present");
801028b8:	83 ec 0c             	sub    $0xc,%esp
801028bb:	68 ca 8f 10 80       	push   $0x80108fca
801028c0:	e8 a1 dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
801028c5:	83 ec 0c             	sub    $0xc,%esp
801028c8:	68 20 c6 10 80       	push   $0x8010c620
801028cd:	e8 c5 2e 00 00       	call   80105797 <acquire>
801028d2:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
801028d5:	8b 45 08             	mov    0x8(%ebp),%eax
801028d8:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801028df:	c7 45 f4 54 c6 10 80 	movl   $0x8010c654,-0xc(%ebp)
801028e6:	eb 0b                	jmp    801028f3 <iderw+0x87>
801028e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028eb:	8b 00                	mov    (%eax),%eax
801028ed:	83 c0 14             	add    $0x14,%eax
801028f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
801028f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028f6:	8b 00                	mov    (%eax),%eax
801028f8:	85 c0                	test   %eax,%eax
801028fa:	75 ec                	jne    801028e8 <iderw+0x7c>
    ;
  *pp = b;
801028fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ff:	8b 55 08             	mov    0x8(%ebp),%edx
80102902:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
80102904:	a1 54 c6 10 80       	mov    0x8010c654,%eax
80102909:	3b 45 08             	cmp    0x8(%ebp),%eax
8010290c:	75 23                	jne    80102931 <iderw+0xc5>
    idestart(b);
8010290e:	83 ec 0c             	sub    $0xc,%esp
80102911:	ff 75 08             	pushl  0x8(%ebp)
80102914:	e8 5c fd ff ff       	call   80102675 <idestart>
80102919:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010291c:	eb 13                	jmp    80102931 <iderw+0xc5>
    sleep(b, &idelock);
8010291e:	83 ec 08             	sub    $0x8,%esp
80102921:	68 20 c6 10 80       	push   $0x8010c620
80102926:	ff 75 08             	pushl  0x8(%ebp)
80102929:	e8 16 25 00 00       	call   80104e44 <sleep>
8010292e:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102931:	8b 45 08             	mov    0x8(%ebp),%eax
80102934:	8b 00                	mov    (%eax),%eax
80102936:	83 e0 06             	and    $0x6,%eax
80102939:	83 f8 02             	cmp    $0x2,%eax
8010293c:	75 e0                	jne    8010291e <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 20 c6 10 80       	push   $0x8010c620
80102946:	e8 b3 2e 00 00       	call   801057fe <release>
8010294b:	83 c4 10             	add    $0x10,%esp
}
8010294e:	90                   	nop
8010294f:	c9                   	leave  
80102950:	c3                   	ret    

80102951 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80102951:	55                   	push   %ebp
80102952:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80102954:	a1 34 32 11 80       	mov    0x80113234,%eax
80102959:	8b 55 08             	mov    0x8(%ebp),%edx
8010295c:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
8010295e:	a1 34 32 11 80       	mov    0x80113234,%eax
80102963:	8b 40 10             	mov    0x10(%eax),%eax
}
80102966:	5d                   	pop    %ebp
80102967:	c3                   	ret    

80102968 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80102968:	55                   	push   %ebp
80102969:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
8010296b:	a1 34 32 11 80       	mov    0x80113234,%eax
80102970:	8b 55 08             	mov    0x8(%ebp),%edx
80102973:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
80102975:	a1 34 32 11 80       	mov    0x80113234,%eax
8010297a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010297d:	89 50 10             	mov    %edx,0x10(%eax)
}
80102980:	90                   	nop
80102981:	5d                   	pop    %ebp
80102982:	c3                   	ret    

80102983 <ioapicinit>:

void
ioapicinit(void)
{
80102983:	55                   	push   %ebp
80102984:	89 e5                	mov    %esp,%ebp
80102986:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102989:	a1 64 33 11 80       	mov    0x80113364,%eax
8010298e:	85 c0                	test   %eax,%eax
80102990:	0f 84 a0 00 00 00    	je     80102a36 <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102996:	c7 05 34 32 11 80 00 	movl   $0xfec00000,0x80113234
8010299d:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801029a0:	6a 01                	push   $0x1
801029a2:	e8 aa ff ff ff       	call   80102951 <ioapicread>
801029a7:	83 c4 04             	add    $0x4,%esp
801029aa:	c1 e8 10             	shr    $0x10,%eax
801029ad:	25 ff 00 00 00       	and    $0xff,%eax
801029b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
801029b5:	6a 00                	push   $0x0
801029b7:	e8 95 ff ff ff       	call   80102951 <ioapicread>
801029bc:	83 c4 04             	add    $0x4,%esp
801029bf:	c1 e8 18             	shr    $0x18,%eax
801029c2:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
801029c5:	0f b6 05 60 33 11 80 	movzbl 0x80113360,%eax
801029cc:	0f b6 c0             	movzbl %al,%eax
801029cf:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801029d2:	74 10                	je     801029e4 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801029d4:	83 ec 0c             	sub    $0xc,%esp
801029d7:	68 e8 8f 10 80       	push   $0x80108fe8
801029dc:	e8 e5 d9 ff ff       	call   801003c6 <cprintf>
801029e1:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
801029e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801029eb:	eb 3f                	jmp    80102a2c <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801029ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029f0:	83 c0 20             	add    $0x20,%eax
801029f3:	0d 00 00 01 00       	or     $0x10000,%eax
801029f8:	89 c2                	mov    %eax,%edx
801029fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801029fd:	83 c0 08             	add    $0x8,%eax
80102a00:	01 c0                	add    %eax,%eax
80102a02:	83 ec 08             	sub    $0x8,%esp
80102a05:	52                   	push   %edx
80102a06:	50                   	push   %eax
80102a07:	e8 5c ff ff ff       	call   80102968 <ioapicwrite>
80102a0c:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a0f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a12:	83 c0 08             	add    $0x8,%eax
80102a15:	01 c0                	add    %eax,%eax
80102a17:	83 c0 01             	add    $0x1,%eax
80102a1a:	83 ec 08             	sub    $0x8,%esp
80102a1d:	6a 00                	push   $0x0
80102a1f:	50                   	push   %eax
80102a20:	e8 43 ff ff ff       	call   80102968 <ioapicwrite>
80102a25:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a28:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102a2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a2f:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102a32:	7e b9                	jle    801029ed <ioapicinit+0x6a>
80102a34:	eb 01                	jmp    80102a37 <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102a36:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102a37:	c9                   	leave  
80102a38:	c3                   	ret    

80102a39 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102a39:	55                   	push   %ebp
80102a3a:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102a3c:	a1 64 33 11 80       	mov    0x80113364,%eax
80102a41:	85 c0                	test   %eax,%eax
80102a43:	74 39                	je     80102a7e <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102a45:	8b 45 08             	mov    0x8(%ebp),%eax
80102a48:	83 c0 20             	add    $0x20,%eax
80102a4b:	89 c2                	mov    %eax,%edx
80102a4d:	8b 45 08             	mov    0x8(%ebp),%eax
80102a50:	83 c0 08             	add    $0x8,%eax
80102a53:	01 c0                	add    %eax,%eax
80102a55:	52                   	push   %edx
80102a56:	50                   	push   %eax
80102a57:	e8 0c ff ff ff       	call   80102968 <ioapicwrite>
80102a5c:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102a5f:	8b 45 0c             	mov    0xc(%ebp),%eax
80102a62:	c1 e0 18             	shl    $0x18,%eax
80102a65:	89 c2                	mov    %eax,%edx
80102a67:	8b 45 08             	mov    0x8(%ebp),%eax
80102a6a:	83 c0 08             	add    $0x8,%eax
80102a6d:	01 c0                	add    %eax,%eax
80102a6f:	83 c0 01             	add    $0x1,%eax
80102a72:	52                   	push   %edx
80102a73:	50                   	push   %eax
80102a74:	e8 ef fe ff ff       	call   80102968 <ioapicwrite>
80102a79:	83 c4 08             	add    $0x8,%esp
80102a7c:	eb 01                	jmp    80102a7f <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102a7e:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102a7f:	c9                   	leave  
80102a80:	c3                   	ret    

80102a81 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102a81:	55                   	push   %ebp
80102a82:	89 e5                	mov    %esp,%ebp
80102a84:	8b 45 08             	mov    0x8(%ebp),%eax
80102a87:	05 00 00 00 80       	add    $0x80000000,%eax
80102a8c:	5d                   	pop    %ebp
80102a8d:	c3                   	ret    

80102a8e <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102a8e:	55                   	push   %ebp
80102a8f:	89 e5                	mov    %esp,%ebp
80102a91:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102a94:	83 ec 08             	sub    $0x8,%esp
80102a97:	68 1a 90 10 80       	push   $0x8010901a
80102a9c:	68 40 32 11 80       	push   $0x80113240
80102aa1:	e8 cf 2c 00 00       	call   80105775 <initlock>
80102aa6:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102aa9:	c7 05 74 32 11 80 00 	movl   $0x0,0x80113274
80102ab0:	00 00 00 
  freerange(vstart, vend);
80102ab3:	83 ec 08             	sub    $0x8,%esp
80102ab6:	ff 75 0c             	pushl  0xc(%ebp)
80102ab9:	ff 75 08             	pushl  0x8(%ebp)
80102abc:	e8 2a 00 00 00       	call   80102aeb <freerange>
80102ac1:	83 c4 10             	add    $0x10,%esp
}
80102ac4:	90                   	nop
80102ac5:	c9                   	leave  
80102ac6:	c3                   	ret    

80102ac7 <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102ac7:	55                   	push   %ebp
80102ac8:	89 e5                	mov    %esp,%ebp
80102aca:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102acd:	83 ec 08             	sub    $0x8,%esp
80102ad0:	ff 75 0c             	pushl  0xc(%ebp)
80102ad3:	ff 75 08             	pushl  0x8(%ebp)
80102ad6:	e8 10 00 00 00       	call   80102aeb <freerange>
80102adb:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102ade:	c7 05 74 32 11 80 01 	movl   $0x1,0x80113274
80102ae5:	00 00 00 
}
80102ae8:	90                   	nop
80102ae9:	c9                   	leave  
80102aea:	c3                   	ret    

80102aeb <freerange>:

void
freerange(void *vstart, void *vend)
{
80102aeb:	55                   	push   %ebp
80102aec:	89 e5                	mov    %esp,%ebp
80102aee:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102af1:	8b 45 08             	mov    0x8(%ebp),%eax
80102af4:	05 ff 0f 00 00       	add    $0xfff,%eax
80102af9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102afe:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b01:	eb 15                	jmp    80102b18 <freerange+0x2d>
    kfree(p);
80102b03:	83 ec 0c             	sub    $0xc,%esp
80102b06:	ff 75 f4             	pushl  -0xc(%ebp)
80102b09:	e8 1a 00 00 00       	call   80102b28 <kfree>
80102b0e:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b11:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b1b:	05 00 10 00 00       	add    $0x1000,%eax
80102b20:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102b23:	76 de                	jbe    80102b03 <freerange+0x18>
    kfree(p);
}
80102b25:	90                   	nop
80102b26:	c9                   	leave  
80102b27:	c3                   	ret    

80102b28 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102b28:	55                   	push   %ebp
80102b29:	89 e5                	mov    %esp,%ebp
80102b2b:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102b2e:	8b 45 08             	mov    0x8(%ebp),%eax
80102b31:	25 ff 0f 00 00       	and    $0xfff,%eax
80102b36:	85 c0                	test   %eax,%eax
80102b38:	75 1b                	jne    80102b55 <kfree+0x2d>
80102b3a:	81 7d 08 bc 6b 11 80 	cmpl   $0x80116bbc,0x8(%ebp)
80102b41:	72 12                	jb     80102b55 <kfree+0x2d>
80102b43:	ff 75 08             	pushl  0x8(%ebp)
80102b46:	e8 36 ff ff ff       	call   80102a81 <v2p>
80102b4b:	83 c4 04             	add    $0x4,%esp
80102b4e:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102b53:	76 0d                	jbe    80102b62 <kfree+0x3a>
    panic("kfree");
80102b55:	83 ec 0c             	sub    $0xc,%esp
80102b58:	68 1f 90 10 80       	push   $0x8010901f
80102b5d:	e8 04 da ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102b62:	83 ec 04             	sub    $0x4,%esp
80102b65:	68 00 10 00 00       	push   $0x1000
80102b6a:	6a 01                	push   $0x1
80102b6c:	ff 75 08             	pushl  0x8(%ebp)
80102b6f:	e8 86 2e 00 00       	call   801059fa <memset>
80102b74:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102b77:	a1 74 32 11 80       	mov    0x80113274,%eax
80102b7c:	85 c0                	test   %eax,%eax
80102b7e:	74 10                	je     80102b90 <kfree+0x68>
    acquire(&kmem.lock);
80102b80:	83 ec 0c             	sub    $0xc,%esp
80102b83:	68 40 32 11 80       	push   $0x80113240
80102b88:	e8 0a 2c 00 00       	call   80105797 <acquire>
80102b8d:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102b90:	8b 45 08             	mov    0x8(%ebp),%eax
80102b93:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102b96:	8b 15 78 32 11 80    	mov    0x80113278,%edx
80102b9c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102b9f:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102ba1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba4:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102ba9:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bae:	85 c0                	test   %eax,%eax
80102bb0:	74 10                	je     80102bc2 <kfree+0x9a>
    release(&kmem.lock);
80102bb2:	83 ec 0c             	sub    $0xc,%esp
80102bb5:	68 40 32 11 80       	push   $0x80113240
80102bba:	e8 3f 2c 00 00       	call   801057fe <release>
80102bbf:	83 c4 10             	add    $0x10,%esp
}
80102bc2:	90                   	nop
80102bc3:	c9                   	leave  
80102bc4:	c3                   	ret    

80102bc5 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102bc5:	55                   	push   %ebp
80102bc6:	89 e5                	mov    %esp,%ebp
80102bc8:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102bcb:	a1 74 32 11 80       	mov    0x80113274,%eax
80102bd0:	85 c0                	test   %eax,%eax
80102bd2:	74 10                	je     80102be4 <kalloc+0x1f>
    acquire(&kmem.lock);
80102bd4:	83 ec 0c             	sub    $0xc,%esp
80102bd7:	68 40 32 11 80       	push   $0x80113240
80102bdc:	e8 b6 2b 00 00       	call   80105797 <acquire>
80102be1:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102be4:	a1 78 32 11 80       	mov    0x80113278,%eax
80102be9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102bec:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102bf0:	74 0a                	je     80102bfc <kalloc+0x37>
    kmem.freelist = r->next;
80102bf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102bf5:	8b 00                	mov    (%eax),%eax
80102bf7:	a3 78 32 11 80       	mov    %eax,0x80113278
  if(kmem.use_lock)
80102bfc:	a1 74 32 11 80       	mov    0x80113274,%eax
80102c01:	85 c0                	test   %eax,%eax
80102c03:	74 10                	je     80102c15 <kalloc+0x50>
    release(&kmem.lock);
80102c05:	83 ec 0c             	sub    $0xc,%esp
80102c08:	68 40 32 11 80       	push   $0x80113240
80102c0d:	e8 ec 2b 00 00       	call   801057fe <release>
80102c12:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c15:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c18:	c9                   	leave  
80102c19:	c3                   	ret    

80102c1a <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102c1a:	55                   	push   %ebp
80102c1b:	89 e5                	mov    %esp,%ebp
80102c1d:	83 ec 14             	sub    $0x14,%esp
80102c20:	8b 45 08             	mov    0x8(%ebp),%eax
80102c23:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c27:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102c2b:	89 c2                	mov    %eax,%edx
80102c2d:	ec                   	in     (%dx),%al
80102c2e:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102c31:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102c35:	c9                   	leave  
80102c36:	c3                   	ret    

80102c37 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102c37:	55                   	push   %ebp
80102c38:	89 e5                	mov    %esp,%ebp
80102c3a:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102c3d:	6a 64                	push   $0x64
80102c3f:	e8 d6 ff ff ff       	call   80102c1a <inb>
80102c44:	83 c4 04             	add    $0x4,%esp
80102c47:	0f b6 c0             	movzbl %al,%eax
80102c4a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102c4d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c50:	83 e0 01             	and    $0x1,%eax
80102c53:	85 c0                	test   %eax,%eax
80102c55:	75 0a                	jne    80102c61 <kbdgetc+0x2a>
    return -1;
80102c57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102c5c:	e9 23 01 00 00       	jmp    80102d84 <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102c61:	6a 60                	push   $0x60
80102c63:	e8 b2 ff ff ff       	call   80102c1a <inb>
80102c68:	83 c4 04             	add    $0x4,%esp
80102c6b:	0f b6 c0             	movzbl %al,%eax
80102c6e:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102c71:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102c78:	75 17                	jne    80102c91 <kbdgetc+0x5a>
    shift |= E0ESC;
80102c7a:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102c7f:	83 c8 40             	or     $0x40,%eax
80102c82:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102c87:	b8 00 00 00 00       	mov    $0x0,%eax
80102c8c:	e9 f3 00 00 00       	jmp    80102d84 <kbdgetc+0x14d>
  } else if(data & 0x80){
80102c91:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102c94:	25 80 00 00 00       	and    $0x80,%eax
80102c99:	85 c0                	test   %eax,%eax
80102c9b:	74 45                	je     80102ce2 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102c9d:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ca2:	83 e0 40             	and    $0x40,%eax
80102ca5:	85 c0                	test   %eax,%eax
80102ca7:	75 08                	jne    80102cb1 <kbdgetc+0x7a>
80102ca9:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cac:	83 e0 7f             	and    $0x7f,%eax
80102caf:	eb 03                	jmp    80102cb4 <kbdgetc+0x7d>
80102cb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cb4:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102cb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102cba:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102cbf:	0f b6 00             	movzbl (%eax),%eax
80102cc2:	83 c8 40             	or     $0x40,%eax
80102cc5:	0f b6 c0             	movzbl %al,%eax
80102cc8:	f7 d0                	not    %eax
80102cca:	89 c2                	mov    %eax,%edx
80102ccc:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cd1:	21 d0                	and    %edx,%eax
80102cd3:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
    return 0;
80102cd8:	b8 00 00 00 00       	mov    $0x0,%eax
80102cdd:	e9 a2 00 00 00       	jmp    80102d84 <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102ce2:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102ce7:	83 e0 40             	and    $0x40,%eax
80102cea:	85 c0                	test   %eax,%eax
80102cec:	74 14                	je     80102d02 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102cee:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102cf5:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102cfa:	83 e0 bf             	and    $0xffffffbf,%eax
80102cfd:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  }

  shift |= shiftcode[data];
80102d02:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d05:	05 20 a0 10 80       	add    $0x8010a020,%eax
80102d0a:	0f b6 00             	movzbl (%eax),%eax
80102d0d:	0f b6 d0             	movzbl %al,%edx
80102d10:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d15:	09 d0                	or     %edx,%eax
80102d17:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  shift ^= togglecode[data];
80102d1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1f:	05 20 a1 10 80       	add    $0x8010a120,%eax
80102d24:	0f b6 00             	movzbl (%eax),%eax
80102d27:	0f b6 d0             	movzbl %al,%edx
80102d2a:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d2f:	31 d0                	xor    %edx,%eax
80102d31:	a3 5c c6 10 80       	mov    %eax,0x8010c65c
  c = charcode[shift & (CTL | SHIFT)][data];
80102d36:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d3b:	83 e0 03             	and    $0x3,%eax
80102d3e:	8b 14 85 20 a5 10 80 	mov    -0x7fef5ae0(,%eax,4),%edx
80102d45:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d48:	01 d0                	add    %edx,%eax
80102d4a:	0f b6 00             	movzbl (%eax),%eax
80102d4d:	0f b6 c0             	movzbl %al,%eax
80102d50:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102d53:	a1 5c c6 10 80       	mov    0x8010c65c,%eax
80102d58:	83 e0 08             	and    $0x8,%eax
80102d5b:	85 c0                	test   %eax,%eax
80102d5d:	74 22                	je     80102d81 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102d5f:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102d63:	76 0c                	jbe    80102d71 <kbdgetc+0x13a>
80102d65:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102d69:	77 06                	ja     80102d71 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102d6b:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102d6f:	eb 10                	jmp    80102d81 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102d71:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102d75:	76 0a                	jbe    80102d81 <kbdgetc+0x14a>
80102d77:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102d7b:	77 04                	ja     80102d81 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102d7d:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102d81:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102d84:	c9                   	leave  
80102d85:	c3                   	ret    

80102d86 <kbdintr>:

void
kbdintr(void)
{
80102d86:	55                   	push   %ebp
80102d87:	89 e5                	mov    %esp,%ebp
80102d89:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102d8c:	83 ec 0c             	sub    $0xc,%esp
80102d8f:	68 37 2c 10 80       	push   $0x80102c37
80102d94:	e8 44 da ff ff       	call   801007dd <consoleintr>
80102d99:	83 c4 10             	add    $0x10,%esp
}
80102d9c:	90                   	nop
80102d9d:	c9                   	leave  
80102d9e:	c3                   	ret    

80102d9f <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102d9f:	55                   	push   %ebp
80102da0:	89 e5                	mov    %esp,%ebp
80102da2:	83 ec 14             	sub    $0x14,%esp
80102da5:	8b 45 08             	mov    0x8(%ebp),%eax
80102da8:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102dac:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102db0:	89 c2                	mov    %eax,%edx
80102db2:	ec                   	in     (%dx),%al
80102db3:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102db6:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102dba:	c9                   	leave  
80102dbb:	c3                   	ret    

80102dbc <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102dbc:	55                   	push   %ebp
80102dbd:	89 e5                	mov    %esp,%ebp
80102dbf:	83 ec 08             	sub    $0x8,%esp
80102dc2:	8b 55 08             	mov    0x8(%ebp),%edx
80102dc5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dc8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102dcc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102dcf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102dd3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102dd7:	ee                   	out    %al,(%dx)
}
80102dd8:	90                   	nop
80102dd9:	c9                   	leave  
80102dda:	c3                   	ret    

80102ddb <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102ddb:	55                   	push   %ebp
80102ddc:	89 e5                	mov    %esp,%ebp
80102dde:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102de1:	9c                   	pushf  
80102de2:	58                   	pop    %eax
80102de3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102de6:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102de9:	c9                   	leave  
80102dea:	c3                   	ret    

80102deb <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102deb:	55                   	push   %ebp
80102dec:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102dee:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102df3:	8b 55 08             	mov    0x8(%ebp),%edx
80102df6:	c1 e2 02             	shl    $0x2,%edx
80102df9:	01 c2                	add    %eax,%edx
80102dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
80102dfe:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e00:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e05:	83 c0 20             	add    $0x20,%eax
80102e08:	8b 00                	mov    (%eax),%eax
}
80102e0a:	90                   	nop
80102e0b:	5d                   	pop    %ebp
80102e0c:	c3                   	ret    

80102e0d <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e0d:	55                   	push   %ebp
80102e0e:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e10:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e15:	85 c0                	test   %eax,%eax
80102e17:	0f 84 0b 01 00 00    	je     80102f28 <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102e1d:	68 3f 01 00 00       	push   $0x13f
80102e22:	6a 3c                	push   $0x3c
80102e24:	e8 c2 ff ff ff       	call   80102deb <lapicw>
80102e29:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102e2c:	6a 0b                	push   $0xb
80102e2e:	68 f8 00 00 00       	push   $0xf8
80102e33:	e8 b3 ff ff ff       	call   80102deb <lapicw>
80102e38:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102e3b:	68 20 00 02 00       	push   $0x20020
80102e40:	68 c8 00 00 00       	push   $0xc8
80102e45:	e8 a1 ff ff ff       	call   80102deb <lapicw>
80102e4a:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102e4d:	68 80 96 98 00       	push   $0x989680
80102e52:	68 e0 00 00 00       	push   $0xe0
80102e57:	e8 8f ff ff ff       	call   80102deb <lapicw>
80102e5c:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102e5f:	68 00 00 01 00       	push   $0x10000
80102e64:	68 d4 00 00 00       	push   $0xd4
80102e69:	e8 7d ff ff ff       	call   80102deb <lapicw>
80102e6e:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102e71:	68 00 00 01 00       	push   $0x10000
80102e76:	68 d8 00 00 00       	push   $0xd8
80102e7b:	e8 6b ff ff ff       	call   80102deb <lapicw>
80102e80:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102e83:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102e88:	83 c0 30             	add    $0x30,%eax
80102e8b:	8b 00                	mov    (%eax),%eax
80102e8d:	c1 e8 10             	shr    $0x10,%eax
80102e90:	0f b6 c0             	movzbl %al,%eax
80102e93:	83 f8 03             	cmp    $0x3,%eax
80102e96:	76 12                	jbe    80102eaa <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102e98:	68 00 00 01 00       	push   $0x10000
80102e9d:	68 d0 00 00 00       	push   $0xd0
80102ea2:	e8 44 ff ff ff       	call   80102deb <lapicw>
80102ea7:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102eaa:	6a 33                	push   $0x33
80102eac:	68 dc 00 00 00       	push   $0xdc
80102eb1:	e8 35 ff ff ff       	call   80102deb <lapicw>
80102eb6:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102eb9:	6a 00                	push   $0x0
80102ebb:	68 a0 00 00 00       	push   $0xa0
80102ec0:	e8 26 ff ff ff       	call   80102deb <lapicw>
80102ec5:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102ec8:	6a 00                	push   $0x0
80102eca:	68 a0 00 00 00       	push   $0xa0
80102ecf:	e8 17 ff ff ff       	call   80102deb <lapicw>
80102ed4:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102ed7:	6a 00                	push   $0x0
80102ed9:	6a 2c                	push   $0x2c
80102edb:	e8 0b ff ff ff       	call   80102deb <lapicw>
80102ee0:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102ee3:	6a 00                	push   $0x0
80102ee5:	68 c4 00 00 00       	push   $0xc4
80102eea:	e8 fc fe ff ff       	call   80102deb <lapicw>
80102eef:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102ef2:	68 00 85 08 00       	push   $0x88500
80102ef7:	68 c0 00 00 00       	push   $0xc0
80102efc:	e8 ea fe ff ff       	call   80102deb <lapicw>
80102f01:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f04:	90                   	nop
80102f05:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f0a:	05 00 03 00 00       	add    $0x300,%eax
80102f0f:	8b 00                	mov    (%eax),%eax
80102f11:	25 00 10 00 00       	and    $0x1000,%eax
80102f16:	85 c0                	test   %eax,%eax
80102f18:	75 eb                	jne    80102f05 <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102f1a:	6a 00                	push   $0x0
80102f1c:	6a 20                	push   $0x20
80102f1e:	e8 c8 fe ff ff       	call   80102deb <lapicw>
80102f23:	83 c4 08             	add    $0x8,%esp
80102f26:	eb 01                	jmp    80102f29 <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102f28:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102f29:	c9                   	leave  
80102f2a:	c3                   	ret    

80102f2b <cpunum>:

int
cpunum(void)
{
80102f2b:	55                   	push   %ebp
80102f2c:	89 e5                	mov    %esp,%ebp
80102f2e:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102f31:	e8 a5 fe ff ff       	call   80102ddb <readeflags>
80102f36:	25 00 02 00 00       	and    $0x200,%eax
80102f3b:	85 c0                	test   %eax,%eax
80102f3d:	74 26                	je     80102f65 <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102f3f:	a1 60 c6 10 80       	mov    0x8010c660,%eax
80102f44:	8d 50 01             	lea    0x1(%eax),%edx
80102f47:	89 15 60 c6 10 80    	mov    %edx,0x8010c660
80102f4d:	85 c0                	test   %eax,%eax
80102f4f:	75 14                	jne    80102f65 <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102f51:	8b 45 04             	mov    0x4(%ebp),%eax
80102f54:	83 ec 08             	sub    $0x8,%esp
80102f57:	50                   	push   %eax
80102f58:	68 28 90 10 80       	push   $0x80109028
80102f5d:	e8 64 d4 ff ff       	call   801003c6 <cprintf>
80102f62:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102f65:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f6a:	85 c0                	test   %eax,%eax
80102f6c:	74 0f                	je     80102f7d <cpunum+0x52>
    return lapic[ID]>>24;
80102f6e:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f73:	83 c0 20             	add    $0x20,%eax
80102f76:	8b 00                	mov    (%eax),%eax
80102f78:	c1 e8 18             	shr    $0x18,%eax
80102f7b:	eb 05                	jmp    80102f82 <cpunum+0x57>
  return 0;
80102f7d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102f82:	c9                   	leave  
80102f83:	c3                   	ret    

80102f84 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102f84:	55                   	push   %ebp
80102f85:	89 e5                	mov    %esp,%ebp
  if(lapic)
80102f87:	a1 7c 32 11 80       	mov    0x8011327c,%eax
80102f8c:	85 c0                	test   %eax,%eax
80102f8e:	74 0c                	je     80102f9c <lapiceoi+0x18>
    lapicw(EOI, 0);
80102f90:	6a 00                	push   $0x0
80102f92:	6a 2c                	push   $0x2c
80102f94:	e8 52 fe ff ff       	call   80102deb <lapicw>
80102f99:	83 c4 08             	add    $0x8,%esp
}
80102f9c:	90                   	nop
80102f9d:	c9                   	leave  
80102f9e:	c3                   	ret    

80102f9f <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102f9f:	55                   	push   %ebp
80102fa0:	89 e5                	mov    %esp,%ebp
}
80102fa2:	90                   	nop
80102fa3:	5d                   	pop    %ebp
80102fa4:	c3                   	ret    

80102fa5 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102fa5:	55                   	push   %ebp
80102fa6:	89 e5                	mov    %esp,%ebp
80102fa8:	83 ec 14             	sub    $0x14,%esp
80102fab:	8b 45 08             	mov    0x8(%ebp),%eax
80102fae:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80102fb1:	6a 0f                	push   $0xf
80102fb3:	6a 70                	push   $0x70
80102fb5:	e8 02 fe ff ff       	call   80102dbc <outb>
80102fba:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80102fbd:	6a 0a                	push   $0xa
80102fbf:	6a 71                	push   $0x71
80102fc1:	e8 f6 fd ff ff       	call   80102dbc <outb>
80102fc6:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
80102fc9:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80102fd0:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fd3:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
80102fd8:	8b 45 f8             	mov    -0x8(%ebp),%eax
80102fdb:	83 c0 02             	add    $0x2,%eax
80102fde:	8b 55 0c             	mov    0xc(%ebp),%edx
80102fe1:	c1 ea 04             	shr    $0x4,%edx
80102fe4:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102fe7:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80102feb:	c1 e0 18             	shl    $0x18,%eax
80102fee:	50                   	push   %eax
80102fef:	68 c4 00 00 00       	push   $0xc4
80102ff4:	e8 f2 fd ff ff       	call   80102deb <lapicw>
80102ff9:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102ffc:	68 00 c5 00 00       	push   $0xc500
80103001:	68 c0 00 00 00       	push   $0xc0
80103006:	e8 e0 fd ff ff       	call   80102deb <lapicw>
8010300b:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010300e:	68 c8 00 00 00       	push   $0xc8
80103013:	e8 87 ff ff ff       	call   80102f9f <microdelay>
80103018:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
8010301b:	68 00 85 00 00       	push   $0x8500
80103020:	68 c0 00 00 00       	push   $0xc0
80103025:	e8 c1 fd ff ff       	call   80102deb <lapicw>
8010302a:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
8010302d:	6a 64                	push   $0x64
8010302f:	e8 6b ff ff ff       	call   80102f9f <microdelay>
80103034:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103037:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
8010303e:	eb 3d                	jmp    8010307d <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
80103040:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103044:	c1 e0 18             	shl    $0x18,%eax
80103047:	50                   	push   %eax
80103048:	68 c4 00 00 00       	push   $0xc4
8010304d:	e8 99 fd ff ff       	call   80102deb <lapicw>
80103052:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
80103055:	8b 45 0c             	mov    0xc(%ebp),%eax
80103058:	c1 e8 0c             	shr    $0xc,%eax
8010305b:	80 cc 06             	or     $0x6,%ah
8010305e:	50                   	push   %eax
8010305f:	68 c0 00 00 00       	push   $0xc0
80103064:	e8 82 fd ff ff       	call   80102deb <lapicw>
80103069:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
8010306c:	68 c8 00 00 00       	push   $0xc8
80103071:	e8 29 ff ff ff       	call   80102f9f <microdelay>
80103076:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
80103079:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010307d:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103081:	7e bd                	jle    80103040 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103083:	90                   	nop
80103084:	c9                   	leave  
80103085:	c3                   	ret    

80103086 <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
80103086:	55                   	push   %ebp
80103087:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
80103089:	8b 45 08             	mov    0x8(%ebp),%eax
8010308c:	0f b6 c0             	movzbl %al,%eax
8010308f:	50                   	push   %eax
80103090:	6a 70                	push   $0x70
80103092:	e8 25 fd ff ff       	call   80102dbc <outb>
80103097:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
8010309a:	68 c8 00 00 00       	push   $0xc8
8010309f:	e8 fb fe ff ff       	call   80102f9f <microdelay>
801030a4:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
801030a7:	6a 71                	push   $0x71
801030a9:	e8 f1 fc ff ff       	call   80102d9f <inb>
801030ae:	83 c4 04             	add    $0x4,%esp
801030b1:	0f b6 c0             	movzbl %al,%eax
}
801030b4:	c9                   	leave  
801030b5:	c3                   	ret    

801030b6 <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
801030b6:	55                   	push   %ebp
801030b7:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
801030b9:	6a 00                	push   $0x0
801030bb:	e8 c6 ff ff ff       	call   80103086 <cmos_read>
801030c0:	83 c4 04             	add    $0x4,%esp
801030c3:	89 c2                	mov    %eax,%edx
801030c5:	8b 45 08             	mov    0x8(%ebp),%eax
801030c8:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
801030ca:	6a 02                	push   $0x2
801030cc:	e8 b5 ff ff ff       	call   80103086 <cmos_read>
801030d1:	83 c4 04             	add    $0x4,%esp
801030d4:	89 c2                	mov    %eax,%edx
801030d6:	8b 45 08             	mov    0x8(%ebp),%eax
801030d9:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
801030dc:	6a 04                	push   $0x4
801030de:	e8 a3 ff ff ff       	call   80103086 <cmos_read>
801030e3:	83 c4 04             	add    $0x4,%esp
801030e6:	89 c2                	mov    %eax,%edx
801030e8:	8b 45 08             	mov    0x8(%ebp),%eax
801030eb:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
801030ee:	6a 07                	push   $0x7
801030f0:	e8 91 ff ff ff       	call   80103086 <cmos_read>
801030f5:	83 c4 04             	add    $0x4,%esp
801030f8:	89 c2                	mov    %eax,%edx
801030fa:	8b 45 08             	mov    0x8(%ebp),%eax
801030fd:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103100:	6a 08                	push   $0x8
80103102:	e8 7f ff ff ff       	call   80103086 <cmos_read>
80103107:	83 c4 04             	add    $0x4,%esp
8010310a:	89 c2                	mov    %eax,%edx
8010310c:	8b 45 08             	mov    0x8(%ebp),%eax
8010310f:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103112:	6a 09                	push   $0x9
80103114:	e8 6d ff ff ff       	call   80103086 <cmos_read>
80103119:	83 c4 04             	add    $0x4,%esp
8010311c:	89 c2                	mov    %eax,%edx
8010311e:	8b 45 08             	mov    0x8(%ebp),%eax
80103121:	89 50 14             	mov    %edx,0x14(%eax)
}
80103124:	90                   	nop
80103125:	c9                   	leave  
80103126:	c3                   	ret    

80103127 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
80103127:	55                   	push   %ebp
80103128:	89 e5                	mov    %esp,%ebp
8010312a:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
8010312d:	6a 0b                	push   $0xb
8010312f:	e8 52 ff ff ff       	call   80103086 <cmos_read>
80103134:	83 c4 04             	add    $0x4,%esp
80103137:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
8010313a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010313d:	83 e0 04             	and    $0x4,%eax
80103140:	85 c0                	test   %eax,%eax
80103142:	0f 94 c0             	sete   %al
80103145:	0f b6 c0             	movzbl %al,%eax
80103148:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
8010314b:	8d 45 d8             	lea    -0x28(%ebp),%eax
8010314e:	50                   	push   %eax
8010314f:	e8 62 ff ff ff       	call   801030b6 <fill_rtcdate>
80103154:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
80103157:	6a 0a                	push   $0xa
80103159:	e8 28 ff ff ff       	call   80103086 <cmos_read>
8010315e:	83 c4 04             	add    $0x4,%esp
80103161:	25 80 00 00 00       	and    $0x80,%eax
80103166:	85 c0                	test   %eax,%eax
80103168:	75 27                	jne    80103191 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
8010316a:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010316d:	50                   	push   %eax
8010316e:	e8 43 ff ff ff       	call   801030b6 <fill_rtcdate>
80103173:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
80103176:	83 ec 04             	sub    $0x4,%esp
80103179:	6a 18                	push   $0x18
8010317b:	8d 45 c0             	lea    -0x40(%ebp),%eax
8010317e:	50                   	push   %eax
8010317f:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103182:	50                   	push   %eax
80103183:	e8 d9 28 00 00       	call   80105a61 <memcmp>
80103188:	83 c4 10             	add    $0x10,%esp
8010318b:	85 c0                	test   %eax,%eax
8010318d:	74 05                	je     80103194 <cmostime+0x6d>
8010318f:	eb ba                	jmp    8010314b <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103191:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103192:	eb b7                	jmp    8010314b <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
80103194:	90                   	nop
  }

  // convert
  if (bcd) {
80103195:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103199:	0f 84 b4 00 00 00    	je     80103253 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010319f:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031a2:	c1 e8 04             	shr    $0x4,%eax
801031a5:	89 c2                	mov    %eax,%edx
801031a7:	89 d0                	mov    %edx,%eax
801031a9:	c1 e0 02             	shl    $0x2,%eax
801031ac:	01 d0                	add    %edx,%eax
801031ae:	01 c0                	add    %eax,%eax
801031b0:	89 c2                	mov    %eax,%edx
801031b2:	8b 45 d8             	mov    -0x28(%ebp),%eax
801031b5:	83 e0 0f             	and    $0xf,%eax
801031b8:	01 d0                	add    %edx,%eax
801031ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
801031bd:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031c0:	c1 e8 04             	shr    $0x4,%eax
801031c3:	89 c2                	mov    %eax,%edx
801031c5:	89 d0                	mov    %edx,%eax
801031c7:	c1 e0 02             	shl    $0x2,%eax
801031ca:	01 d0                	add    %edx,%eax
801031cc:	01 c0                	add    %eax,%eax
801031ce:	89 c2                	mov    %eax,%edx
801031d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801031d3:	83 e0 0f             	and    $0xf,%eax
801031d6:	01 d0                	add    %edx,%eax
801031d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
801031db:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031de:	c1 e8 04             	shr    $0x4,%eax
801031e1:	89 c2                	mov    %eax,%edx
801031e3:	89 d0                	mov    %edx,%eax
801031e5:	c1 e0 02             	shl    $0x2,%eax
801031e8:	01 d0                	add    %edx,%eax
801031ea:	01 c0                	add    %eax,%eax
801031ec:	89 c2                	mov    %eax,%edx
801031ee:	8b 45 e0             	mov    -0x20(%ebp),%eax
801031f1:	83 e0 0f             	and    $0xf,%eax
801031f4:	01 d0                	add    %edx,%eax
801031f6:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
801031f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801031fc:	c1 e8 04             	shr    $0x4,%eax
801031ff:	89 c2                	mov    %eax,%edx
80103201:	89 d0                	mov    %edx,%eax
80103203:	c1 e0 02             	shl    $0x2,%eax
80103206:	01 d0                	add    %edx,%eax
80103208:	01 c0                	add    %eax,%eax
8010320a:	89 c2                	mov    %eax,%edx
8010320c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010320f:	83 e0 0f             	and    $0xf,%eax
80103212:	01 d0                	add    %edx,%eax
80103214:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
80103217:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010321a:	c1 e8 04             	shr    $0x4,%eax
8010321d:	89 c2                	mov    %eax,%edx
8010321f:	89 d0                	mov    %edx,%eax
80103221:	c1 e0 02             	shl    $0x2,%eax
80103224:	01 d0                	add    %edx,%eax
80103226:	01 c0                	add    %eax,%eax
80103228:	89 c2                	mov    %eax,%edx
8010322a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010322d:	83 e0 0f             	and    $0xf,%eax
80103230:	01 d0                	add    %edx,%eax
80103232:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
80103235:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103238:	c1 e8 04             	shr    $0x4,%eax
8010323b:	89 c2                	mov    %eax,%edx
8010323d:	89 d0                	mov    %edx,%eax
8010323f:	c1 e0 02             	shl    $0x2,%eax
80103242:	01 d0                	add    %edx,%eax
80103244:	01 c0                	add    %eax,%eax
80103246:	89 c2                	mov    %eax,%edx
80103248:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010324b:	83 e0 0f             	and    $0xf,%eax
8010324e:	01 d0                	add    %edx,%eax
80103250:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
80103253:	8b 45 08             	mov    0x8(%ebp),%eax
80103256:	8b 55 d8             	mov    -0x28(%ebp),%edx
80103259:	89 10                	mov    %edx,(%eax)
8010325b:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010325e:	89 50 04             	mov    %edx,0x4(%eax)
80103261:	8b 55 e0             	mov    -0x20(%ebp),%edx
80103264:	89 50 08             	mov    %edx,0x8(%eax)
80103267:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010326a:	89 50 0c             	mov    %edx,0xc(%eax)
8010326d:	8b 55 e8             	mov    -0x18(%ebp),%edx
80103270:	89 50 10             	mov    %edx,0x10(%eax)
80103273:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103276:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
80103279:	8b 45 08             	mov    0x8(%ebp),%eax
8010327c:	8b 40 14             	mov    0x14(%eax),%eax
8010327f:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
80103285:	8b 45 08             	mov    0x8(%ebp),%eax
80103288:	89 50 14             	mov    %edx,0x14(%eax)
}
8010328b:	90                   	nop
8010328c:	c9                   	leave  
8010328d:	c3                   	ret    

8010328e <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(void)
{
8010328e:	55                   	push   %ebp
8010328f:	89 e5                	mov    %esp,%ebp
80103291:	83 ec 18             	sub    $0x18,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
80103294:	83 ec 08             	sub    $0x8,%esp
80103297:	68 54 90 10 80       	push   $0x80109054
8010329c:	68 80 32 11 80       	push   $0x80113280
801032a1:	e8 cf 24 00 00       	call   80105775 <initlock>
801032a6:	83 c4 10             	add    $0x10,%esp
  readsb(ROOTDEV, &sb);
801032a9:	83 ec 08             	sub    $0x8,%esp
801032ac:	8d 45 e8             	lea    -0x18(%ebp),%eax
801032af:	50                   	push   %eax
801032b0:	6a 01                	push   $0x1
801032b2:	e8 b2 e0 ff ff       	call   80101369 <readsb>
801032b7:	83 c4 10             	add    $0x10,%esp
  log.start = sb.size - sb.nlog;
801032ba:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032c0:	29 c2                	sub    %eax,%edx
801032c2:	89 d0                	mov    %edx,%eax
801032c4:	a3 b4 32 11 80       	mov    %eax,0x801132b4
  log.size = sb.nlog;
801032c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032cc:	a3 b8 32 11 80       	mov    %eax,0x801132b8
  log.dev = ROOTDEV;
801032d1:	c7 05 c4 32 11 80 01 	movl   $0x1,0x801132c4
801032d8:	00 00 00 
  recover_from_log();
801032db:	e8 b2 01 00 00       	call   80103492 <recover_from_log>
}
801032e0:	90                   	nop
801032e1:	c9                   	leave  
801032e2:	c3                   	ret    

801032e3 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
801032e3:	55                   	push   %ebp
801032e4:	89 e5                	mov    %esp,%ebp
801032e6:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801032e9:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801032f0:	e9 95 00 00 00       	jmp    8010338a <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
801032f5:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
801032fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801032fe:	01 d0                	add    %edx,%eax
80103300:	83 c0 01             	add    $0x1,%eax
80103303:	89 c2                	mov    %eax,%edx
80103305:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010330a:	83 ec 08             	sub    $0x8,%esp
8010330d:	52                   	push   %edx
8010330e:	50                   	push   %eax
8010330f:	e8 a2 ce ff ff       	call   801001b6 <bread>
80103314:	83 c4 10             	add    $0x10,%esp
80103317:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.sector[tail]); // read dst
8010331a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010331d:	83 c0 10             	add    $0x10,%eax
80103320:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103327:	89 c2                	mov    %eax,%edx
80103329:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010332e:	83 ec 08             	sub    $0x8,%esp
80103331:	52                   	push   %edx
80103332:	50                   	push   %eax
80103333:	e8 7e ce ff ff       	call   801001b6 <bread>
80103338:	83 c4 10             	add    $0x10,%esp
8010333b:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010333e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103341:	8d 50 18             	lea    0x18(%eax),%edx
80103344:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103347:	83 c0 18             	add    $0x18,%eax
8010334a:	83 ec 04             	sub    $0x4,%esp
8010334d:	68 00 02 00 00       	push   $0x200
80103352:	52                   	push   %edx
80103353:	50                   	push   %eax
80103354:	e8 60 27 00 00       	call   80105ab9 <memmove>
80103359:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
8010335c:	83 ec 0c             	sub    $0xc,%esp
8010335f:	ff 75 ec             	pushl  -0x14(%ebp)
80103362:	e8 88 ce ff ff       	call   801001ef <bwrite>
80103367:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
8010336a:	83 ec 0c             	sub    $0xc,%esp
8010336d:	ff 75 f0             	pushl  -0x10(%ebp)
80103370:	e8 b9 ce ff ff       	call   8010022e <brelse>
80103375:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
80103378:	83 ec 0c             	sub    $0xc,%esp
8010337b:	ff 75 ec             	pushl  -0x14(%ebp)
8010337e:	e8 ab ce ff ff       	call   8010022e <brelse>
80103383:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103386:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010338a:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010338f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103392:	0f 8f 5d ff ff ff    	jg     801032f5 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103398:	90                   	nop
80103399:	c9                   	leave  
8010339a:	c3                   	ret    

8010339b <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010339b:	55                   	push   %ebp
8010339c:	89 e5                	mov    %esp,%ebp
8010339e:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
801033a1:	a1 b4 32 11 80       	mov    0x801132b4,%eax
801033a6:	89 c2                	mov    %eax,%edx
801033a8:	a1 c4 32 11 80       	mov    0x801132c4,%eax
801033ad:	83 ec 08             	sub    $0x8,%esp
801033b0:	52                   	push   %edx
801033b1:	50                   	push   %eax
801033b2:	e8 ff cd ff ff       	call   801001b6 <bread>
801033b7:	83 c4 10             	add    $0x10,%esp
801033ba:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
801033bd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033c0:	83 c0 18             	add    $0x18,%eax
801033c3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
801033c6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c9:	8b 00                	mov    (%eax),%eax
801033cb:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  for (i = 0; i < log.lh.n; i++) {
801033d0:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801033d7:	eb 1b                	jmp    801033f4 <read_head+0x59>
    log.lh.sector[i] = lh->sector[i];
801033d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033df:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
801033e3:	8b 55 f4             	mov    -0xc(%ebp),%edx
801033e6:	83 c2 10             	add    $0x10,%edx
801033e9:	89 04 95 8c 32 11 80 	mov    %eax,-0x7feecd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
801033f0:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801033f4:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801033f9:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801033fc:	7f db                	jg     801033d9 <read_head+0x3e>
    log.lh.sector[i] = lh->sector[i];
  }
  brelse(buf);
801033fe:	83 ec 0c             	sub    $0xc,%esp
80103401:	ff 75 f0             	pushl  -0x10(%ebp)
80103404:	e8 25 ce ff ff       	call   8010022e <brelse>
80103409:	83 c4 10             	add    $0x10,%esp
}
8010340c:	90                   	nop
8010340d:	c9                   	leave  
8010340e:	c3                   	ret    

8010340f <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010340f:	55                   	push   %ebp
80103410:	89 e5                	mov    %esp,%ebp
80103412:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103415:	a1 b4 32 11 80       	mov    0x801132b4,%eax
8010341a:	89 c2                	mov    %eax,%edx
8010341c:	a1 c4 32 11 80       	mov    0x801132c4,%eax
80103421:	83 ec 08             	sub    $0x8,%esp
80103424:	52                   	push   %edx
80103425:	50                   	push   %eax
80103426:	e8 8b cd ff ff       	call   801001b6 <bread>
8010342b:	83 c4 10             	add    $0x10,%esp
8010342e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
80103431:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103434:	83 c0 18             	add    $0x18,%eax
80103437:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
8010343a:	8b 15 c8 32 11 80    	mov    0x801132c8,%edx
80103440:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103443:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
80103445:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010344c:	eb 1b                	jmp    80103469 <write_head+0x5a>
    hb->sector[i] = log.lh.sector[i];
8010344e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103451:	83 c0 10             	add    $0x10,%eax
80103454:	8b 0c 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%ecx
8010345b:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103461:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80103465:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103469:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010346e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103471:	7f db                	jg     8010344e <write_head+0x3f>
    hb->sector[i] = log.lh.sector[i];
  }
  bwrite(buf);
80103473:	83 ec 0c             	sub    $0xc,%esp
80103476:	ff 75 f0             	pushl  -0x10(%ebp)
80103479:	e8 71 cd ff ff       	call   801001ef <bwrite>
8010347e:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
80103481:	83 ec 0c             	sub    $0xc,%esp
80103484:	ff 75 f0             	pushl  -0x10(%ebp)
80103487:	e8 a2 cd ff ff       	call   8010022e <brelse>
8010348c:	83 c4 10             	add    $0x10,%esp
}
8010348f:	90                   	nop
80103490:	c9                   	leave  
80103491:	c3                   	ret    

80103492 <recover_from_log>:

static void
recover_from_log(void)
{
80103492:	55                   	push   %ebp
80103493:	89 e5                	mov    %esp,%ebp
80103495:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103498:	e8 fe fe ff ff       	call   8010339b <read_head>
  install_trans(); // if committed, copy from log to disk
8010349d:	e8 41 fe ff ff       	call   801032e3 <install_trans>
  log.lh.n = 0;
801034a2:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801034a9:	00 00 00 
  write_head(); // clear the log
801034ac:	e8 5e ff ff ff       	call   8010340f <write_head>
}
801034b1:	90                   	nop
801034b2:	c9                   	leave  
801034b3:	c3                   	ret    

801034b4 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
801034b4:	55                   	push   %ebp
801034b5:	89 e5                	mov    %esp,%ebp
801034b7:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
801034ba:	83 ec 0c             	sub    $0xc,%esp
801034bd:	68 80 32 11 80       	push   $0x80113280
801034c2:	e8 d0 22 00 00       	call   80105797 <acquire>
801034c7:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
801034ca:	a1 c0 32 11 80       	mov    0x801132c0,%eax
801034cf:	85 c0                	test   %eax,%eax
801034d1:	74 17                	je     801034ea <begin_op+0x36>
      sleep(&log, &log.lock);
801034d3:	83 ec 08             	sub    $0x8,%esp
801034d6:	68 80 32 11 80       	push   $0x80113280
801034db:	68 80 32 11 80       	push   $0x80113280
801034e0:	e8 5f 19 00 00       	call   80104e44 <sleep>
801034e5:	83 c4 10             	add    $0x10,%esp
801034e8:	eb e0                	jmp    801034ca <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801034ea:	8b 0d c8 32 11 80    	mov    0x801132c8,%ecx
801034f0:	a1 bc 32 11 80       	mov    0x801132bc,%eax
801034f5:	8d 50 01             	lea    0x1(%eax),%edx
801034f8:	89 d0                	mov    %edx,%eax
801034fa:	c1 e0 02             	shl    $0x2,%eax
801034fd:	01 d0                	add    %edx,%eax
801034ff:	01 c0                	add    %eax,%eax
80103501:	01 c8                	add    %ecx,%eax
80103503:	83 f8 1e             	cmp    $0x1e,%eax
80103506:	7e 17                	jle    8010351f <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103508:	83 ec 08             	sub    $0x8,%esp
8010350b:	68 80 32 11 80       	push   $0x80113280
80103510:	68 80 32 11 80       	push   $0x80113280
80103515:	e8 2a 19 00 00       	call   80104e44 <sleep>
8010351a:	83 c4 10             	add    $0x10,%esp
8010351d:	eb ab                	jmp    801034ca <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010351f:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103524:	83 c0 01             	add    $0x1,%eax
80103527:	a3 bc 32 11 80       	mov    %eax,0x801132bc
      release(&log.lock);
8010352c:	83 ec 0c             	sub    $0xc,%esp
8010352f:	68 80 32 11 80       	push   $0x80113280
80103534:	e8 c5 22 00 00       	call   801057fe <release>
80103539:	83 c4 10             	add    $0x10,%esp
      break;
8010353c:	90                   	nop
    }
  }
}
8010353d:	90                   	nop
8010353e:	c9                   	leave  
8010353f:	c3                   	ret    

80103540 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
80103546:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
8010354d:	83 ec 0c             	sub    $0xc,%esp
80103550:	68 80 32 11 80       	push   $0x80113280
80103555:	e8 3d 22 00 00       	call   80105797 <acquire>
8010355a:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
8010355d:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103562:	83 e8 01             	sub    $0x1,%eax
80103565:	a3 bc 32 11 80       	mov    %eax,0x801132bc
  if(log.committing)
8010356a:	a1 c0 32 11 80       	mov    0x801132c0,%eax
8010356f:	85 c0                	test   %eax,%eax
80103571:	74 0d                	je     80103580 <end_op+0x40>
    panic("log.committing");
80103573:	83 ec 0c             	sub    $0xc,%esp
80103576:	68 58 90 10 80       	push   $0x80109058
8010357b:	e8 e6 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
80103580:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103585:	85 c0                	test   %eax,%eax
80103587:	75 13                	jne    8010359c <end_op+0x5c>
    do_commit = 1;
80103589:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
80103590:	c7 05 c0 32 11 80 01 	movl   $0x1,0x801132c0
80103597:	00 00 00 
8010359a:	eb 10                	jmp    801035ac <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010359c:	83 ec 0c             	sub    $0xc,%esp
8010359f:	68 80 32 11 80       	push   $0x80113280
801035a4:	e8 b0 19 00 00       	call   80104f59 <wakeup>
801035a9:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
801035ac:	83 ec 0c             	sub    $0xc,%esp
801035af:	68 80 32 11 80       	push   $0x80113280
801035b4:	e8 45 22 00 00       	call   801057fe <release>
801035b9:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
801035bc:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801035c0:	74 3f                	je     80103601 <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
801035c2:	e8 f5 00 00 00       	call   801036bc <commit>
    acquire(&log.lock);
801035c7:	83 ec 0c             	sub    $0xc,%esp
801035ca:	68 80 32 11 80       	push   $0x80113280
801035cf:	e8 c3 21 00 00       	call   80105797 <acquire>
801035d4:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
801035d7:	c7 05 c0 32 11 80 00 	movl   $0x0,0x801132c0
801035de:	00 00 00 
    wakeup(&log);
801035e1:	83 ec 0c             	sub    $0xc,%esp
801035e4:	68 80 32 11 80       	push   $0x80113280
801035e9:	e8 6b 19 00 00       	call   80104f59 <wakeup>
801035ee:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 80 32 11 80       	push   $0x80113280
801035f9:	e8 00 22 00 00       	call   801057fe <release>
801035fe:	83 c4 10             	add    $0x10,%esp
  }
}
80103601:	90                   	nop
80103602:	c9                   	leave  
80103603:	c3                   	ret    

80103604 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103604:	55                   	push   %ebp
80103605:	89 e5                	mov    %esp,%ebp
80103607:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010360a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103611:	e9 95 00 00 00       	jmp    801036ab <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103616:	8b 15 b4 32 11 80    	mov    0x801132b4,%edx
8010361c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010361f:	01 d0                	add    %edx,%eax
80103621:	83 c0 01             	add    $0x1,%eax
80103624:	89 c2                	mov    %eax,%edx
80103626:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010362b:	83 ec 08             	sub    $0x8,%esp
8010362e:	52                   	push   %edx
8010362f:	50                   	push   %eax
80103630:	e8 81 cb ff ff       	call   801001b6 <bread>
80103635:	83 c4 10             	add    $0x10,%esp
80103638:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.sector[tail]); // cache block
8010363b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010363e:	83 c0 10             	add    $0x10,%eax
80103641:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103648:	89 c2                	mov    %eax,%edx
8010364a:	a1 c4 32 11 80       	mov    0x801132c4,%eax
8010364f:	83 ec 08             	sub    $0x8,%esp
80103652:	52                   	push   %edx
80103653:	50                   	push   %eax
80103654:	e8 5d cb ff ff       	call   801001b6 <bread>
80103659:	83 c4 10             	add    $0x10,%esp
8010365c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
8010365f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103662:	8d 50 18             	lea    0x18(%eax),%edx
80103665:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103668:	83 c0 18             	add    $0x18,%eax
8010366b:	83 ec 04             	sub    $0x4,%esp
8010366e:	68 00 02 00 00       	push   $0x200
80103673:	52                   	push   %edx
80103674:	50                   	push   %eax
80103675:	e8 3f 24 00 00       	call   80105ab9 <memmove>
8010367a:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
8010367d:	83 ec 0c             	sub    $0xc,%esp
80103680:	ff 75 f0             	pushl  -0x10(%ebp)
80103683:	e8 67 cb ff ff       	call   801001ef <bwrite>
80103688:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
8010368b:	83 ec 0c             	sub    $0xc,%esp
8010368e:	ff 75 ec             	pushl  -0x14(%ebp)
80103691:	e8 98 cb ff ff       	call   8010022e <brelse>
80103696:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103699:	83 ec 0c             	sub    $0xc,%esp
8010369c:	ff 75 f0             	pushl  -0x10(%ebp)
8010369f:	e8 8a cb ff ff       	call   8010022e <brelse>
801036a4:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801036a7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801036ab:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036b0:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801036b3:	0f 8f 5d ff ff ff    	jg     80103616 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
801036b9:	90                   	nop
801036ba:	c9                   	leave  
801036bb:	c3                   	ret    

801036bc <commit>:

static void
commit()
{
801036bc:	55                   	push   %ebp
801036bd:	89 e5                	mov    %esp,%ebp
801036bf:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
801036c2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036c7:	85 c0                	test   %eax,%eax
801036c9:	7e 1e                	jle    801036e9 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
801036cb:	e8 34 ff ff ff       	call   80103604 <write_log>
    write_head();    // Write header to disk -- the real commit
801036d0:	e8 3a fd ff ff       	call   8010340f <write_head>
    install_trans(); // Now install writes to home locations
801036d5:	e8 09 fc ff ff       	call   801032e3 <install_trans>
    log.lh.n = 0; 
801036da:	c7 05 c8 32 11 80 00 	movl   $0x0,0x801132c8
801036e1:	00 00 00 
    write_head();    // Erase the transaction from the log
801036e4:	e8 26 fd ff ff       	call   8010340f <write_head>
  }
}
801036e9:	90                   	nop
801036ea:	c9                   	leave  
801036eb:	c3                   	ret    

801036ec <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
801036ec:	55                   	push   %ebp
801036ed:	89 e5                	mov    %esp,%ebp
801036ef:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
801036f2:	a1 c8 32 11 80       	mov    0x801132c8,%eax
801036f7:	83 f8 1d             	cmp    $0x1d,%eax
801036fa:	7f 12                	jg     8010370e <log_write+0x22>
801036fc:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103701:	8b 15 b8 32 11 80    	mov    0x801132b8,%edx
80103707:	83 ea 01             	sub    $0x1,%edx
8010370a:	39 d0                	cmp    %edx,%eax
8010370c:	7c 0d                	jl     8010371b <log_write+0x2f>
    panic("too big a transaction");
8010370e:	83 ec 0c             	sub    $0xc,%esp
80103711:	68 67 90 10 80       	push   $0x80109067
80103716:	e8 4b ce ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
8010371b:	a1 bc 32 11 80       	mov    0x801132bc,%eax
80103720:	85 c0                	test   %eax,%eax
80103722:	7f 0d                	jg     80103731 <log_write+0x45>
    panic("log_write outside of trans");
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	68 7d 90 10 80       	push   $0x8010907d
8010372c:	e8 35 ce ff ff       	call   80100566 <panic>

  acquire(&log.lock);
80103731:	83 ec 0c             	sub    $0xc,%esp
80103734:	68 80 32 11 80       	push   $0x80113280
80103739:	e8 59 20 00 00       	call   80105797 <acquire>
8010373e:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
80103741:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103748:	eb 1d                	jmp    80103767 <log_write+0x7b>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
8010374a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010374d:	83 c0 10             	add    $0x10,%eax
80103750:	8b 04 85 8c 32 11 80 	mov    -0x7feecd74(,%eax,4),%eax
80103757:	89 c2                	mov    %eax,%edx
80103759:	8b 45 08             	mov    0x8(%ebp),%eax
8010375c:	8b 40 08             	mov    0x8(%eax),%eax
8010375f:	39 c2                	cmp    %eax,%edx
80103761:	74 10                	je     80103773 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
80103763:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103767:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010376c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010376f:	7f d9                	jg     8010374a <log_write+0x5e>
80103771:	eb 01                	jmp    80103774 <log_write+0x88>
    if (log.lh.sector[i] == b->sector)   // log absorbtion
      break;
80103773:	90                   	nop
  }
  log.lh.sector[i] = b->sector;
80103774:	8b 45 08             	mov    0x8(%ebp),%eax
80103777:	8b 40 08             	mov    0x8(%eax),%eax
8010377a:	89 c2                	mov    %eax,%edx
8010377c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010377f:	83 c0 10             	add    $0x10,%eax
80103782:	89 14 85 8c 32 11 80 	mov    %edx,-0x7feecd74(,%eax,4)
  if (i == log.lh.n)
80103789:	a1 c8 32 11 80       	mov    0x801132c8,%eax
8010378e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103791:	75 0d                	jne    801037a0 <log_write+0xb4>
    log.lh.n++;
80103793:	a1 c8 32 11 80       	mov    0x801132c8,%eax
80103798:	83 c0 01             	add    $0x1,%eax
8010379b:	a3 c8 32 11 80       	mov    %eax,0x801132c8
  b->flags |= B_DIRTY; // prevent eviction
801037a0:	8b 45 08             	mov    0x8(%ebp),%eax
801037a3:	8b 00                	mov    (%eax),%eax
801037a5:	83 c8 04             	or     $0x4,%eax
801037a8:	89 c2                	mov    %eax,%edx
801037aa:	8b 45 08             	mov    0x8(%ebp),%eax
801037ad:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
801037af:	83 ec 0c             	sub    $0xc,%esp
801037b2:	68 80 32 11 80       	push   $0x80113280
801037b7:	e8 42 20 00 00       	call   801057fe <release>
801037bc:	83 c4 10             	add    $0x10,%esp
}
801037bf:	90                   	nop
801037c0:	c9                   	leave  
801037c1:	c3                   	ret    

801037c2 <v2p>:
801037c2:	55                   	push   %ebp
801037c3:	89 e5                	mov    %esp,%ebp
801037c5:	8b 45 08             	mov    0x8(%ebp),%eax
801037c8:	05 00 00 00 80       	add    $0x80000000,%eax
801037cd:	5d                   	pop    %ebp
801037ce:	c3                   	ret    

801037cf <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801037cf:	55                   	push   %ebp
801037d0:	89 e5                	mov    %esp,%ebp
801037d2:	8b 45 08             	mov    0x8(%ebp),%eax
801037d5:	05 00 00 00 80       	add    $0x80000000,%eax
801037da:	5d                   	pop    %ebp
801037db:	c3                   	ret    

801037dc <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
801037dc:	55                   	push   %ebp
801037dd:	89 e5                	mov    %esp,%ebp
801037df:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
801037e2:	8b 55 08             	mov    0x8(%ebp),%edx
801037e5:	8b 45 0c             	mov    0xc(%ebp),%eax
801037e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
801037eb:	f0 87 02             	lock xchg %eax,(%edx)
801037ee:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
801037f1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801037f4:	c9                   	leave  
801037f5:	c3                   	ret    

801037f6 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
801037f6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
801037fa:	83 e4 f0             	and    $0xfffffff0,%esp
801037fd:	ff 71 fc             	pushl  -0x4(%ecx)
80103800:	55                   	push   %ebp
80103801:	89 e5                	mov    %esp,%ebp
80103803:	51                   	push   %ecx
80103804:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103807:	83 ec 08             	sub    $0x8,%esp
8010380a:	68 00 00 40 80       	push   $0x80400000
8010380f:	68 bc 6b 11 80       	push   $0x80116bbc
80103814:	e8 75 f2 ff ff       	call   80102a8e <kinit1>
80103819:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010381c:	e8 b8 4e 00 00       	call   801086d9 <kvmalloc>
  mpinit();        // collect info about this machine
80103821:	e8 4d 04 00 00       	call   80103c73 <mpinit>
  lapicinit();
80103826:	e8 e2 f5 ff ff       	call   80102e0d <lapicinit>
  seginit();       // set up segments
8010382b:	e8 52 48 00 00       	call   80108082 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
80103830:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103836:	0f b6 00             	movzbl (%eax),%eax
80103839:	0f b6 c0             	movzbl %al,%eax
8010383c:	83 ec 08             	sub    $0x8,%esp
8010383f:	50                   	push   %eax
80103840:	68 98 90 10 80       	push   $0x80109098
80103845:	e8 7c cb ff ff       	call   801003c6 <cprintf>
8010384a:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
8010384d:	e8 77 06 00 00       	call   80103ec9 <picinit>
  ioapicinit();    // another interrupt controller
80103852:	e8 2c f1 ff ff       	call   80102983 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
80103857:	e8 8d d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
8010385c:	e8 7d 3b 00 00       	call   801073de <uartinit>
  pinit();         // process table
80103861:	e8 60 0b 00 00       	call   801043c6 <pinit>
  tvinit();        // trap vectors
80103866:	e8 c5 36 00 00       	call   80106f30 <tvinit>
  binit();         // buffer cache
8010386b:	e8 c4 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
80103870:	e8 e5 d6 ff ff       	call   80100f5a <fileinit>
  semtableinit();  // semaphore table
80103875:	e8 18 1a 00 00       	call   80105292 <semtableinit>
  iinit();         // inode cache
8010387a:	e8 b9 dd ff ff       	call   80101638 <iinit>
  ideinit();       // disk
8010387f:	e8 43 ed ff ff       	call   801025c7 <ideinit>
  if(!ismp)
80103884:	a1 64 33 11 80       	mov    0x80113364,%eax
80103889:	85 c0                	test   %eax,%eax
8010388b:	75 05                	jne    80103892 <main+0x9c>
    timerinit();   // uniprocessor timer
8010388d:	e8 fb 35 00 00       	call   80106e8d <timerinit>
  startothers();   // start other processors
80103892:	e8 7f 00 00 00       	call   80103916 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103897:	83 ec 08             	sub    $0x8,%esp
8010389a:	68 00 00 00 8e       	push   $0x8e000000
8010389f:	68 00 00 40 80       	push   $0x80400000
801038a4:	e8 1e f2 ff ff       	call   80102ac7 <kinit2>
801038a9:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
801038ac:	e8 3f 0d 00 00       	call   801045f0 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
801038b1:	e8 1a 00 00 00       	call   801038d0 <mpmain>

801038b6 <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
801038b6:	55                   	push   %ebp
801038b7:	89 e5                	mov    %esp,%ebp
801038b9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
801038bc:	e8 30 4e 00 00       	call   801086f1 <switchkvm>
  seginit();
801038c1:	e8 bc 47 00 00       	call   80108082 <seginit>
  lapicinit();
801038c6:	e8 42 f5 ff ff       	call   80102e0d <lapicinit>
  mpmain();
801038cb:	e8 00 00 00 00       	call   801038d0 <mpmain>

801038d0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801038d0:	55                   	push   %ebp
801038d1:	89 e5                	mov    %esp,%ebp
801038d3:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
801038d6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038dc:	0f b6 00             	movzbl (%eax),%eax
801038df:	0f b6 c0             	movzbl %al,%eax
801038e2:	83 ec 08             	sub    $0x8,%esp
801038e5:	50                   	push   %eax
801038e6:	68 af 90 10 80       	push   $0x801090af
801038eb:	e8 d6 ca ff ff       	call   801003c6 <cprintf>
801038f0:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
801038f3:	e8 ae 37 00 00       	call   801070a6 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
801038f8:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038fe:	05 a8 00 00 00       	add    $0xa8,%eax
80103903:	83 ec 08             	sub    $0x8,%esp
80103906:	6a 01                	push   $0x1
80103908:	50                   	push   %eax
80103909:	e8 ce fe ff ff       	call   801037dc <xchg>
8010390e:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103911:	e8 e5 12 00 00       	call   80104bfb <scheduler>

80103916 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80103916:	55                   	push   %ebp
80103917:	89 e5                	mov    %esp,%ebp
80103919:	53                   	push   %ebx
8010391a:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
8010391d:	68 00 70 00 00       	push   $0x7000
80103922:	e8 a8 fe ff ff       	call   801037cf <p2v>
80103927:	83 c4 04             	add    $0x4,%esp
8010392a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
8010392d:	b8 8a 00 00 00       	mov    $0x8a,%eax
80103932:	83 ec 04             	sub    $0x4,%esp
80103935:	50                   	push   %eax
80103936:	68 2c c5 10 80       	push   $0x8010c52c
8010393b:	ff 75 f0             	pushl  -0x10(%ebp)
8010393e:	e8 76 21 00 00       	call   80105ab9 <memmove>
80103943:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
80103946:	c7 45 f4 80 33 11 80 	movl   $0x80113380,-0xc(%ebp)
8010394d:	e9 90 00 00 00       	jmp    801039e2 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
80103952:	e8 d4 f5 ff ff       	call   80102f2b <cpunum>
80103957:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
8010395d:	05 80 33 11 80       	add    $0x80113380,%eax
80103962:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103965:	74 73                	je     801039da <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103967:	e8 59 f2 ff ff       	call   80102bc5 <kalloc>
8010396c:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
8010396f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103972:	83 e8 04             	sub    $0x4,%eax
80103975:	8b 55 ec             	mov    -0x14(%ebp),%edx
80103978:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010397e:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
80103980:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103983:	83 e8 08             	sub    $0x8,%eax
80103986:	c7 00 b6 38 10 80    	movl   $0x801038b6,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
8010398c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010398f:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103992:	83 ec 0c             	sub    $0xc,%esp
80103995:	68 00 b0 10 80       	push   $0x8010b000
8010399a:	e8 23 fe ff ff       	call   801037c2 <v2p>
8010399f:	83 c4 10             	add    $0x10,%esp
801039a2:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
801039a4:	83 ec 0c             	sub    $0xc,%esp
801039a7:	ff 75 f0             	pushl  -0x10(%ebp)
801039aa:	e8 13 fe ff ff       	call   801037c2 <v2p>
801039af:	83 c4 10             	add    $0x10,%esp
801039b2:	89 c2                	mov    %eax,%edx
801039b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039b7:	0f b6 00             	movzbl (%eax),%eax
801039ba:	0f b6 c0             	movzbl %al,%eax
801039bd:	83 ec 08             	sub    $0x8,%esp
801039c0:	52                   	push   %edx
801039c1:	50                   	push   %eax
801039c2:	e8 de f5 ff ff       	call   80102fa5 <lapicstartap>
801039c7:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
801039ca:	90                   	nop
801039cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801039ce:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
801039d4:	85 c0                	test   %eax,%eax
801039d6:	74 f3                	je     801039cb <startothers+0xb5>
801039d8:	eb 01                	jmp    801039db <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
801039da:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
801039db:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
801039e2:	a1 60 39 11 80       	mov    0x80113960,%eax
801039e7:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039ed:	05 80 33 11 80       	add    $0x80113380,%eax
801039f2:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039f5:	0f 87 57 ff ff ff    	ja     80103952 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
801039fb:	90                   	nop
801039fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039ff:	c9                   	leave  
80103a00:	c3                   	ret    

80103a01 <p2v>:
80103a01:	55                   	push   %ebp
80103a02:	89 e5                	mov    %esp,%ebp
80103a04:	8b 45 08             	mov    0x8(%ebp),%eax
80103a07:	05 00 00 00 80       	add    $0x80000000,%eax
80103a0c:	5d                   	pop    %ebp
80103a0d:	c3                   	ret    

80103a0e <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a0e:	55                   	push   %ebp
80103a0f:	89 e5                	mov    %esp,%ebp
80103a11:	83 ec 14             	sub    $0x14,%esp
80103a14:	8b 45 08             	mov    0x8(%ebp),%eax
80103a17:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a1b:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a1f:	89 c2                	mov    %eax,%edx
80103a21:	ec                   	in     (%dx),%al
80103a22:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a25:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a29:	c9                   	leave  
80103a2a:	c3                   	ret    

80103a2b <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a2b:	55                   	push   %ebp
80103a2c:	89 e5                	mov    %esp,%ebp
80103a2e:	83 ec 08             	sub    $0x8,%esp
80103a31:	8b 55 08             	mov    0x8(%ebp),%edx
80103a34:	8b 45 0c             	mov    0xc(%ebp),%eax
80103a37:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103a3b:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103a3e:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103a42:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103a46:	ee                   	out    %al,(%dx)
}
80103a47:	90                   	nop
80103a48:	c9                   	leave  
80103a49:	c3                   	ret    

80103a4a <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103a4a:	55                   	push   %ebp
80103a4b:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103a4d:	a1 64 c6 10 80       	mov    0x8010c664,%eax
80103a52:	89 c2                	mov    %eax,%edx
80103a54:	b8 80 33 11 80       	mov    $0x80113380,%eax
80103a59:	29 c2                	sub    %eax,%edx
80103a5b:	89 d0                	mov    %edx,%eax
80103a5d:	c1 f8 02             	sar    $0x2,%eax
80103a60:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103a66:	5d                   	pop    %ebp
80103a67:	c3                   	ret    

80103a68 <sum>:

static uchar
sum(uchar *addr, int len)
{
80103a68:	55                   	push   %ebp
80103a69:	89 e5                	mov    %esp,%ebp
80103a6b:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103a6e:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103a75:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103a7c:	eb 15                	jmp    80103a93 <sum+0x2b>
    sum += addr[i];
80103a7e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103a81:	8b 45 08             	mov    0x8(%ebp),%eax
80103a84:	01 d0                	add    %edx,%eax
80103a86:	0f b6 00             	movzbl (%eax),%eax
80103a89:	0f b6 c0             	movzbl %al,%eax
80103a8c:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103a8f:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103a93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103a96:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103a99:	7c e3                	jl     80103a7e <sum+0x16>
    sum += addr[i];
  return sum;
80103a9b:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103a9e:	c9                   	leave  
80103a9f:	c3                   	ret    

80103aa0 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103aa0:	55                   	push   %ebp
80103aa1:	89 e5                	mov    %esp,%ebp
80103aa3:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103aa6:	ff 75 08             	pushl  0x8(%ebp)
80103aa9:	e8 53 ff ff ff       	call   80103a01 <p2v>
80103aae:	83 c4 04             	add    $0x4,%esp
80103ab1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103ab4:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ab7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103aba:	01 d0                	add    %edx,%eax
80103abc:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103abf:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ac2:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103ac5:	eb 36                	jmp    80103afd <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103ac7:	83 ec 04             	sub    $0x4,%esp
80103aca:	6a 04                	push   $0x4
80103acc:	68 c0 90 10 80       	push   $0x801090c0
80103ad1:	ff 75 f4             	pushl  -0xc(%ebp)
80103ad4:	e8 88 1f 00 00       	call   80105a61 <memcmp>
80103ad9:	83 c4 10             	add    $0x10,%esp
80103adc:	85 c0                	test   %eax,%eax
80103ade:	75 19                	jne    80103af9 <mpsearch1+0x59>
80103ae0:	83 ec 08             	sub    $0x8,%esp
80103ae3:	6a 10                	push   $0x10
80103ae5:	ff 75 f4             	pushl  -0xc(%ebp)
80103ae8:	e8 7b ff ff ff       	call   80103a68 <sum>
80103aed:	83 c4 10             	add    $0x10,%esp
80103af0:	84 c0                	test   %al,%al
80103af2:	75 05                	jne    80103af9 <mpsearch1+0x59>
      return (struct mp*)p;
80103af4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103af7:	eb 11                	jmp    80103b0a <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103af9:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b00:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b03:	72 c2                	jb     80103ac7 <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b05:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b0a:	c9                   	leave  
80103b0b:	c3                   	ret    

80103b0c <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b0c:	55                   	push   %ebp
80103b0d:	89 e5                	mov    %esp,%ebp
80103b0f:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b12:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b19:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b1c:	83 c0 0f             	add    $0xf,%eax
80103b1f:	0f b6 00             	movzbl (%eax),%eax
80103b22:	0f b6 c0             	movzbl %al,%eax
80103b25:	c1 e0 08             	shl    $0x8,%eax
80103b28:	89 c2                	mov    %eax,%edx
80103b2a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b2d:	83 c0 0e             	add    $0xe,%eax
80103b30:	0f b6 00             	movzbl (%eax),%eax
80103b33:	0f b6 c0             	movzbl %al,%eax
80103b36:	09 d0                	or     %edx,%eax
80103b38:	c1 e0 04             	shl    $0x4,%eax
80103b3b:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103b3e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103b42:	74 21                	je     80103b65 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103b44:	83 ec 08             	sub    $0x8,%esp
80103b47:	68 00 04 00 00       	push   $0x400
80103b4c:	ff 75 f0             	pushl  -0x10(%ebp)
80103b4f:	e8 4c ff ff ff       	call   80103aa0 <mpsearch1>
80103b54:	83 c4 10             	add    $0x10,%esp
80103b57:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103b5a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103b5e:	74 51                	je     80103bb1 <mpsearch+0xa5>
      return mp;
80103b60:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103b63:	eb 61                	jmp    80103bc6 <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103b65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b68:	83 c0 14             	add    $0x14,%eax
80103b6b:	0f b6 00             	movzbl (%eax),%eax
80103b6e:	0f b6 c0             	movzbl %al,%eax
80103b71:	c1 e0 08             	shl    $0x8,%eax
80103b74:	89 c2                	mov    %eax,%edx
80103b76:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b79:	83 c0 13             	add    $0x13,%eax
80103b7c:	0f b6 00             	movzbl (%eax),%eax
80103b7f:	0f b6 c0             	movzbl %al,%eax
80103b82:	09 d0                	or     %edx,%eax
80103b84:	c1 e0 0a             	shl    $0xa,%eax
80103b87:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103b8a:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b8d:	2d 00 04 00 00       	sub    $0x400,%eax
80103b92:	83 ec 08             	sub    $0x8,%esp
80103b95:	68 00 04 00 00       	push   $0x400
80103b9a:	50                   	push   %eax
80103b9b:	e8 00 ff ff ff       	call   80103aa0 <mpsearch1>
80103ba0:	83 c4 10             	add    $0x10,%esp
80103ba3:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ba6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103baa:	74 05                	je     80103bb1 <mpsearch+0xa5>
      return mp;
80103bac:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103baf:	eb 15                	jmp    80103bc6 <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103bb1:	83 ec 08             	sub    $0x8,%esp
80103bb4:	68 00 00 01 00       	push   $0x10000
80103bb9:	68 00 00 0f 00       	push   $0xf0000
80103bbe:	e8 dd fe ff ff       	call   80103aa0 <mpsearch1>
80103bc3:	83 c4 10             	add    $0x10,%esp
}
80103bc6:	c9                   	leave  
80103bc7:	c3                   	ret    

80103bc8 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103bc8:	55                   	push   %ebp
80103bc9:	89 e5                	mov    %esp,%ebp
80103bcb:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103bce:	e8 39 ff ff ff       	call   80103b0c <mpsearch>
80103bd3:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103bd6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103bda:	74 0a                	je     80103be6 <mpconfig+0x1e>
80103bdc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdf:	8b 40 04             	mov    0x4(%eax),%eax
80103be2:	85 c0                	test   %eax,%eax
80103be4:	75 0a                	jne    80103bf0 <mpconfig+0x28>
    return 0;
80103be6:	b8 00 00 00 00       	mov    $0x0,%eax
80103beb:	e9 81 00 00 00       	jmp    80103c71 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103bf0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bf3:	8b 40 04             	mov    0x4(%eax),%eax
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	50                   	push   %eax
80103bfa:	e8 02 fe ff ff       	call   80103a01 <p2v>
80103bff:	83 c4 10             	add    $0x10,%esp
80103c02:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c05:	83 ec 04             	sub    $0x4,%esp
80103c08:	6a 04                	push   $0x4
80103c0a:	68 c5 90 10 80       	push   $0x801090c5
80103c0f:	ff 75 f0             	pushl  -0x10(%ebp)
80103c12:	e8 4a 1e 00 00       	call   80105a61 <memcmp>
80103c17:	83 c4 10             	add    $0x10,%esp
80103c1a:	85 c0                	test   %eax,%eax
80103c1c:	74 07                	je     80103c25 <mpconfig+0x5d>
    return 0;
80103c1e:	b8 00 00 00 00       	mov    $0x0,%eax
80103c23:	eb 4c                	jmp    80103c71 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c25:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c28:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c2c:	3c 01                	cmp    $0x1,%al
80103c2e:	74 12                	je     80103c42 <mpconfig+0x7a>
80103c30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c33:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103c37:	3c 04                	cmp    $0x4,%al
80103c39:	74 07                	je     80103c42 <mpconfig+0x7a>
    return 0;
80103c3b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c40:	eb 2f                	jmp    80103c71 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103c42:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c45:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103c49:	0f b7 c0             	movzwl %ax,%eax
80103c4c:	83 ec 08             	sub    $0x8,%esp
80103c4f:	50                   	push   %eax
80103c50:	ff 75 f0             	pushl  -0x10(%ebp)
80103c53:	e8 10 fe ff ff       	call   80103a68 <sum>
80103c58:	83 c4 10             	add    $0x10,%esp
80103c5b:	84 c0                	test   %al,%al
80103c5d:	74 07                	je     80103c66 <mpconfig+0x9e>
    return 0;
80103c5f:	b8 00 00 00 00       	mov    $0x0,%eax
80103c64:	eb 0b                	jmp    80103c71 <mpconfig+0xa9>
  *pmp = mp;
80103c66:	8b 45 08             	mov    0x8(%ebp),%eax
80103c69:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103c6c:	89 10                	mov    %edx,(%eax)
  return conf;
80103c6e:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103c71:	c9                   	leave  
80103c72:	c3                   	ret    

80103c73 <mpinit>:

void
mpinit(void)
{
80103c73:	55                   	push   %ebp
80103c74:	89 e5                	mov    %esp,%ebp
80103c76:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103c79:	c7 05 64 c6 10 80 80 	movl   $0x80113380,0x8010c664
80103c80:	33 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103c83:	83 ec 0c             	sub    $0xc,%esp
80103c86:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103c89:	50                   	push   %eax
80103c8a:	e8 39 ff ff ff       	call   80103bc8 <mpconfig>
80103c8f:	83 c4 10             	add    $0x10,%esp
80103c92:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103c95:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103c99:	0f 84 96 01 00 00    	je     80103e35 <mpinit+0x1c2>
    return;
  ismp = 1;
80103c9f:	c7 05 64 33 11 80 01 	movl   $0x1,0x80113364
80103ca6:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103ca9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cac:	8b 40 24             	mov    0x24(%eax),%eax
80103caf:	a3 7c 32 11 80       	mov    %eax,0x8011327c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103cb4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb7:	83 c0 2c             	add    $0x2c,%eax
80103cba:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103cbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cc0:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cc4:	0f b7 d0             	movzwl %ax,%edx
80103cc7:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cca:	01 d0                	add    %edx,%eax
80103ccc:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103ccf:	e9 f2 00 00 00       	jmp    80103dc6 <mpinit+0x153>
    switch(*p){
80103cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cd7:	0f b6 00             	movzbl (%eax),%eax
80103cda:	0f b6 c0             	movzbl %al,%eax
80103cdd:	83 f8 04             	cmp    $0x4,%eax
80103ce0:	0f 87 bc 00 00 00    	ja     80103da2 <mpinit+0x12f>
80103ce6:	8b 04 85 08 91 10 80 	mov    -0x7fef6ef8(,%eax,4),%eax
80103ced:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103cf2:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103cf5:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103cf8:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103cfc:	0f b6 d0             	movzbl %al,%edx
80103cff:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d04:	39 c2                	cmp    %eax,%edx
80103d06:	74 2b                	je     80103d33 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d08:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d0b:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d0f:	0f b6 d0             	movzbl %al,%edx
80103d12:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d17:	83 ec 04             	sub    $0x4,%esp
80103d1a:	52                   	push   %edx
80103d1b:	50                   	push   %eax
80103d1c:	68 ca 90 10 80       	push   $0x801090ca
80103d21:	e8 a0 c6 ff ff       	call   801003c6 <cprintf>
80103d26:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d29:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103d30:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103d33:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d36:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103d3a:	0f b6 c0             	movzbl %al,%eax
80103d3d:	83 e0 02             	and    $0x2,%eax
80103d40:	85 c0                	test   %eax,%eax
80103d42:	74 15                	je     80103d59 <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103d44:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d49:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d4f:	05 80 33 11 80       	add    $0x80113380,%eax
80103d54:	a3 64 c6 10 80       	mov    %eax,0x8010c664
      cpus[ncpu].id = ncpu;
80103d59:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d5e:	8b 15 60 39 11 80    	mov    0x80113960,%edx
80103d64:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103d6a:	05 80 33 11 80       	add    $0x80113380,%eax
80103d6f:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103d71:	a1 60 39 11 80       	mov    0x80113960,%eax
80103d76:	83 c0 01             	add    $0x1,%eax
80103d79:	a3 60 39 11 80       	mov    %eax,0x80113960
      p += sizeof(struct mpproc);
80103d7e:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103d82:	eb 42                	jmp    80103dc6 <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103d84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103d8a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103d8d:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d91:	a2 60 33 11 80       	mov    %al,0x80113360
      p += sizeof(struct mpioapic);
80103d96:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103d9a:	eb 2a                	jmp    80103dc6 <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103d9c:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103da0:	eb 24                	jmp    80103dc6 <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103da2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103da5:	0f b6 00             	movzbl (%eax),%eax
80103da8:	0f b6 c0             	movzbl %al,%eax
80103dab:	83 ec 08             	sub    $0x8,%esp
80103dae:	50                   	push   %eax
80103daf:	68 e8 90 10 80       	push   $0x801090e8
80103db4:	e8 0d c6 ff ff       	call   801003c6 <cprintf>
80103db9:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103dbc:	c7 05 64 33 11 80 00 	movl   $0x0,0x80113364
80103dc3:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103dc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dc9:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103dcc:	0f 82 02 ff ff ff    	jb     80103cd4 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103dd2:	a1 64 33 11 80       	mov    0x80113364,%eax
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	75 1d                	jne    80103df8 <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103ddb:	c7 05 60 39 11 80 01 	movl   $0x1,0x80113960
80103de2:	00 00 00 
    lapic = 0;
80103de5:	c7 05 7c 32 11 80 00 	movl   $0x0,0x8011327c
80103dec:	00 00 00 
    ioapicid = 0;
80103def:	c6 05 60 33 11 80 00 	movb   $0x0,0x80113360
    return;
80103df6:	eb 3e                	jmp    80103e36 <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103df8:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103dfb:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103dff:	84 c0                	test   %al,%al
80103e01:	74 33                	je     80103e36 <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e03:	83 ec 08             	sub    $0x8,%esp
80103e06:	6a 70                	push   $0x70
80103e08:	6a 22                	push   $0x22
80103e0a:	e8 1c fc ff ff       	call   80103a2b <outb>
80103e0f:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e12:	83 ec 0c             	sub    $0xc,%esp
80103e15:	6a 23                	push   $0x23
80103e17:	e8 f2 fb ff ff       	call   80103a0e <inb>
80103e1c:	83 c4 10             	add    $0x10,%esp
80103e1f:	83 c8 01             	or     $0x1,%eax
80103e22:	0f b6 c0             	movzbl %al,%eax
80103e25:	83 ec 08             	sub    $0x8,%esp
80103e28:	50                   	push   %eax
80103e29:	6a 23                	push   $0x23
80103e2b:	e8 fb fb ff ff       	call   80103a2b <outb>
80103e30:	83 c4 10             	add    $0x10,%esp
80103e33:	eb 01                	jmp    80103e36 <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103e35:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103e36:	c9                   	leave  
80103e37:	c3                   	ret    

80103e38 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103e38:	55                   	push   %ebp
80103e39:	89 e5                	mov    %esp,%ebp
80103e3b:	83 ec 08             	sub    $0x8,%esp
80103e3e:	8b 55 08             	mov    0x8(%ebp),%edx
80103e41:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e44:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103e48:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103e4b:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103e4f:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103e53:	ee                   	out    %al,(%dx)
}
80103e54:	90                   	nop
80103e55:	c9                   	leave  
80103e56:	c3                   	ret    

80103e57 <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103e57:	55                   	push   %ebp
80103e58:	89 e5                	mov    %esp,%ebp
80103e5a:	83 ec 04             	sub    $0x4,%esp
80103e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e60:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103e64:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e68:	66 a3 00 c0 10 80    	mov    %ax,0x8010c000
  outb(IO_PIC1+1, mask);
80103e6e:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e72:	0f b6 c0             	movzbl %al,%eax
80103e75:	50                   	push   %eax
80103e76:	6a 21                	push   $0x21
80103e78:	e8 bb ff ff ff       	call   80103e38 <outb>
80103e7d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103e80:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103e84:	66 c1 e8 08          	shr    $0x8,%ax
80103e88:	0f b6 c0             	movzbl %al,%eax
80103e8b:	50                   	push   %eax
80103e8c:	68 a1 00 00 00       	push   $0xa1
80103e91:	e8 a2 ff ff ff       	call   80103e38 <outb>
80103e96:	83 c4 08             	add    $0x8,%esp
}
80103e99:	90                   	nop
80103e9a:	c9                   	leave  
80103e9b:	c3                   	ret    

80103e9c <picenable>:

void
picenable(int irq)
{
80103e9c:	55                   	push   %ebp
80103e9d:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103e9f:	8b 45 08             	mov    0x8(%ebp),%eax
80103ea2:	ba 01 00 00 00       	mov    $0x1,%edx
80103ea7:	89 c1                	mov    %eax,%ecx
80103ea9:	d3 e2                	shl    %cl,%edx
80103eab:	89 d0                	mov    %edx,%eax
80103ead:	f7 d0                	not    %eax
80103eaf:	89 c2                	mov    %eax,%edx
80103eb1:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103eb8:	21 d0                	and    %edx,%eax
80103eba:	0f b7 c0             	movzwl %ax,%eax
80103ebd:	50                   	push   %eax
80103ebe:	e8 94 ff ff ff       	call   80103e57 <picsetmask>
80103ec3:	83 c4 04             	add    $0x4,%esp
}
80103ec6:	90                   	nop
80103ec7:	c9                   	leave  
80103ec8:	c3                   	ret    

80103ec9 <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103ec9:	55                   	push   %ebp
80103eca:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103ecc:	68 ff 00 00 00       	push   $0xff
80103ed1:	6a 21                	push   $0x21
80103ed3:	e8 60 ff ff ff       	call   80103e38 <outb>
80103ed8:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103edb:	68 ff 00 00 00       	push   $0xff
80103ee0:	68 a1 00 00 00       	push   $0xa1
80103ee5:	e8 4e ff ff ff       	call   80103e38 <outb>
80103eea:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103eed:	6a 11                	push   $0x11
80103eef:	6a 20                	push   $0x20
80103ef1:	e8 42 ff ff ff       	call   80103e38 <outb>
80103ef6:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103ef9:	6a 20                	push   $0x20
80103efb:	6a 21                	push   $0x21
80103efd:	e8 36 ff ff ff       	call   80103e38 <outb>
80103f02:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f05:	6a 04                	push   $0x4
80103f07:	6a 21                	push   $0x21
80103f09:	e8 2a ff ff ff       	call   80103e38 <outb>
80103f0e:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f11:	6a 03                	push   $0x3
80103f13:	6a 21                	push   $0x21
80103f15:	e8 1e ff ff ff       	call   80103e38 <outb>
80103f1a:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f1d:	6a 11                	push   $0x11
80103f1f:	68 a0 00 00 00       	push   $0xa0
80103f24:	e8 0f ff ff ff       	call   80103e38 <outb>
80103f29:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103f2c:	6a 28                	push   $0x28
80103f2e:	68 a1 00 00 00       	push   $0xa1
80103f33:	e8 00 ff ff ff       	call   80103e38 <outb>
80103f38:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103f3b:	6a 02                	push   $0x2
80103f3d:	68 a1 00 00 00       	push   $0xa1
80103f42:	e8 f1 fe ff ff       	call   80103e38 <outb>
80103f47:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103f4a:	6a 03                	push   $0x3
80103f4c:	68 a1 00 00 00       	push   $0xa1
80103f51:	e8 e2 fe ff ff       	call   80103e38 <outb>
80103f56:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103f59:	6a 68                	push   $0x68
80103f5b:	6a 20                	push   $0x20
80103f5d:	e8 d6 fe ff ff       	call   80103e38 <outb>
80103f62:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103f65:	6a 0a                	push   $0xa
80103f67:	6a 20                	push   $0x20
80103f69:	e8 ca fe ff ff       	call   80103e38 <outb>
80103f6e:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103f71:	6a 68                	push   $0x68
80103f73:	68 a0 00 00 00       	push   $0xa0
80103f78:	e8 bb fe ff ff       	call   80103e38 <outb>
80103f7d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103f80:	6a 0a                	push   $0xa
80103f82:	68 a0 00 00 00       	push   $0xa0
80103f87:	e8 ac fe ff ff       	call   80103e38 <outb>
80103f8c:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80103f8f:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103f96:	66 83 f8 ff          	cmp    $0xffff,%ax
80103f9a:	74 13                	je     80103faf <picinit+0xe6>
    picsetmask(irqmask);
80103f9c:	0f b7 05 00 c0 10 80 	movzwl 0x8010c000,%eax
80103fa3:	0f b7 c0             	movzwl %ax,%eax
80103fa6:	50                   	push   %eax
80103fa7:	e8 ab fe ff ff       	call   80103e57 <picsetmask>
80103fac:	83 c4 04             	add    $0x4,%esp
}
80103faf:	90                   	nop
80103fb0:	c9                   	leave  
80103fb1:	c3                   	ret    

80103fb2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103fb2:	55                   	push   %ebp
80103fb3:	89 e5                	mov    %esp,%ebp
80103fb5:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
80103fb8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80103fbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fc2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
80103fc8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcb:	8b 10                	mov    (%eax),%edx
80103fcd:	8b 45 08             	mov    0x8(%ebp),%eax
80103fd0:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80103fd2:	e8 a1 cf ff ff       	call   80100f78 <filealloc>
80103fd7:	89 c2                	mov    %eax,%edx
80103fd9:	8b 45 08             	mov    0x8(%ebp),%eax
80103fdc:	89 10                	mov    %edx,(%eax)
80103fde:	8b 45 08             	mov    0x8(%ebp),%eax
80103fe1:	8b 00                	mov    (%eax),%eax
80103fe3:	85 c0                	test   %eax,%eax
80103fe5:	0f 84 cb 00 00 00    	je     801040b6 <pipealloc+0x104>
80103feb:	e8 88 cf ff ff       	call   80100f78 <filealloc>
80103ff0:	89 c2                	mov    %eax,%edx
80103ff2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ff5:	89 10                	mov    %edx,(%eax)
80103ff7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffa:	8b 00                	mov    (%eax),%eax
80103ffc:	85 c0                	test   %eax,%eax
80103ffe:	0f 84 b2 00 00 00    	je     801040b6 <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104004:	e8 bc eb ff ff       	call   80102bc5 <kalloc>
80104009:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010400c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104010:	0f 84 9f 00 00 00    	je     801040b5 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
80104016:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104019:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104020:	00 00 00 
  p->writeopen = 1;
80104023:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104026:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010402d:	00 00 00 
  p->nwrite = 0;
80104030:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104033:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010403a:	00 00 00 
  p->nread = 0;
8010403d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104040:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80104047:	00 00 00 
  initlock(&p->lock, "pipe");
8010404a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010404d:	83 ec 08             	sub    $0x8,%esp
80104050:	68 1c 91 10 80       	push   $0x8010911c
80104055:	50                   	push   %eax
80104056:	e8 1a 17 00 00       	call   80105775 <initlock>
8010405b:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
8010405e:	8b 45 08             	mov    0x8(%ebp),%eax
80104061:	8b 00                	mov    (%eax),%eax
80104063:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80104069:	8b 45 08             	mov    0x8(%ebp),%eax
8010406c:	8b 00                	mov    (%eax),%eax
8010406e:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80104072:	8b 45 08             	mov    0x8(%ebp),%eax
80104075:	8b 00                	mov    (%eax),%eax
80104077:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
8010407b:	8b 45 08             	mov    0x8(%ebp),%eax
8010407e:	8b 00                	mov    (%eax),%eax
80104080:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104083:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
80104086:	8b 45 0c             	mov    0xc(%ebp),%eax
80104089:	8b 00                	mov    (%eax),%eax
8010408b:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104091:	8b 45 0c             	mov    0xc(%ebp),%eax
80104094:	8b 00                	mov    (%eax),%eax
80104096:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010409a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010409d:	8b 00                	mov    (%eax),%eax
8010409f:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801040a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801040a6:	8b 00                	mov    (%eax),%eax
801040a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040ab:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
801040ae:	b8 00 00 00 00       	mov    $0x0,%eax
801040b3:	eb 4e                	jmp    80104103 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
801040b5:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
801040b6:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801040ba:	74 0e                	je     801040ca <pipealloc+0x118>
    kfree((char*)p);
801040bc:	83 ec 0c             	sub    $0xc,%esp
801040bf:	ff 75 f4             	pushl  -0xc(%ebp)
801040c2:	e8 61 ea ff ff       	call   80102b28 <kfree>
801040c7:	83 c4 10             	add    $0x10,%esp
  if(*f0)
801040ca:	8b 45 08             	mov    0x8(%ebp),%eax
801040cd:	8b 00                	mov    (%eax),%eax
801040cf:	85 c0                	test   %eax,%eax
801040d1:	74 11                	je     801040e4 <pipealloc+0x132>
    fileclose(*f0);
801040d3:	8b 45 08             	mov    0x8(%ebp),%eax
801040d6:	8b 00                	mov    (%eax),%eax
801040d8:	83 ec 0c             	sub    $0xc,%esp
801040db:	50                   	push   %eax
801040dc:	e8 55 cf ff ff       	call   80101036 <fileclose>
801040e1:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801040e4:	8b 45 0c             	mov    0xc(%ebp),%eax
801040e7:	8b 00                	mov    (%eax),%eax
801040e9:	85 c0                	test   %eax,%eax
801040eb:	74 11                	je     801040fe <pipealloc+0x14c>
    fileclose(*f1);
801040ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801040f0:	8b 00                	mov    (%eax),%eax
801040f2:	83 ec 0c             	sub    $0xc,%esp
801040f5:	50                   	push   %eax
801040f6:	e8 3b cf ff ff       	call   80101036 <fileclose>
801040fb:	83 c4 10             	add    $0x10,%esp
  return -1;
801040fe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104103:	c9                   	leave  
80104104:	c3                   	ret    

80104105 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104105:	55                   	push   %ebp
80104106:	89 e5                	mov    %esp,%ebp
80104108:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010410b:	8b 45 08             	mov    0x8(%ebp),%eax
8010410e:	83 ec 0c             	sub    $0xc,%esp
80104111:	50                   	push   %eax
80104112:	e8 80 16 00 00       	call   80105797 <acquire>
80104117:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010411a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
8010411e:	74 23                	je     80104143 <pipeclose+0x3e>
    p->writeopen = 0;
80104120:	8b 45 08             	mov    0x8(%ebp),%eax
80104123:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010412a:	00 00 00 
    wakeup(&p->nread);
8010412d:	8b 45 08             	mov    0x8(%ebp),%eax
80104130:	05 34 02 00 00       	add    $0x234,%eax
80104135:	83 ec 0c             	sub    $0xc,%esp
80104138:	50                   	push   %eax
80104139:	e8 1b 0e 00 00       	call   80104f59 <wakeup>
8010413e:	83 c4 10             	add    $0x10,%esp
80104141:	eb 21                	jmp    80104164 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
80104143:	8b 45 08             	mov    0x8(%ebp),%eax
80104146:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
8010414d:	00 00 00 
    wakeup(&p->nwrite);
80104150:	8b 45 08             	mov    0x8(%ebp),%eax
80104153:	05 38 02 00 00       	add    $0x238,%eax
80104158:	83 ec 0c             	sub    $0xc,%esp
8010415b:	50                   	push   %eax
8010415c:	e8 f8 0d 00 00       	call   80104f59 <wakeup>
80104161:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
80104164:	8b 45 08             	mov    0x8(%ebp),%eax
80104167:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010416d:	85 c0                	test   %eax,%eax
8010416f:	75 2c                	jne    8010419d <pipeclose+0x98>
80104171:	8b 45 08             	mov    0x8(%ebp),%eax
80104174:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
8010417a:	85 c0                	test   %eax,%eax
8010417c:	75 1f                	jne    8010419d <pipeclose+0x98>
    release(&p->lock);
8010417e:	8b 45 08             	mov    0x8(%ebp),%eax
80104181:	83 ec 0c             	sub    $0xc,%esp
80104184:	50                   	push   %eax
80104185:	e8 74 16 00 00       	call   801057fe <release>
8010418a:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
8010418d:	83 ec 0c             	sub    $0xc,%esp
80104190:	ff 75 08             	pushl  0x8(%ebp)
80104193:	e8 90 e9 ff ff       	call   80102b28 <kfree>
80104198:	83 c4 10             	add    $0x10,%esp
8010419b:	eb 0f                	jmp    801041ac <pipeclose+0xa7>
  } else
    release(&p->lock);
8010419d:	8b 45 08             	mov    0x8(%ebp),%eax
801041a0:	83 ec 0c             	sub    $0xc,%esp
801041a3:	50                   	push   %eax
801041a4:	e8 55 16 00 00       	call   801057fe <release>
801041a9:	83 c4 10             	add    $0x10,%esp
}
801041ac:	90                   	nop
801041ad:	c9                   	leave  
801041ae:	c3                   	ret    

801041af <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801041af:	55                   	push   %ebp
801041b0:	89 e5                	mov    %esp,%ebp
801041b2:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
801041b5:	8b 45 08             	mov    0x8(%ebp),%eax
801041b8:	83 ec 0c             	sub    $0xc,%esp
801041bb:	50                   	push   %eax
801041bc:	e8 d6 15 00 00       	call   80105797 <acquire>
801041c1:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
801041c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801041cb:	e9 ad 00 00 00       	jmp    8010427d <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
801041d0:	8b 45 08             	mov    0x8(%ebp),%eax
801041d3:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041d9:	85 c0                	test   %eax,%eax
801041db:	74 0d                	je     801041ea <pipewrite+0x3b>
801041dd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801041e3:	8b 40 24             	mov    0x24(%eax),%eax
801041e6:	85 c0                	test   %eax,%eax
801041e8:	74 19                	je     80104203 <pipewrite+0x54>
        release(&p->lock);
801041ea:	8b 45 08             	mov    0x8(%ebp),%eax
801041ed:	83 ec 0c             	sub    $0xc,%esp
801041f0:	50                   	push   %eax
801041f1:	e8 08 16 00 00       	call   801057fe <release>
801041f6:	83 c4 10             	add    $0x10,%esp
        return -1;
801041f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041fe:	e9 a8 00 00 00       	jmp    801042ab <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104203:	8b 45 08             	mov    0x8(%ebp),%eax
80104206:	05 34 02 00 00       	add    $0x234,%eax
8010420b:	83 ec 0c             	sub    $0xc,%esp
8010420e:	50                   	push   %eax
8010420f:	e8 45 0d 00 00       	call   80104f59 <wakeup>
80104214:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80104217:	8b 45 08             	mov    0x8(%ebp),%eax
8010421a:	8b 55 08             	mov    0x8(%ebp),%edx
8010421d:	81 c2 38 02 00 00    	add    $0x238,%edx
80104223:	83 ec 08             	sub    $0x8,%esp
80104226:	50                   	push   %eax
80104227:	52                   	push   %edx
80104228:	e8 17 0c 00 00       	call   80104e44 <sleep>
8010422d:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80104230:	8b 45 08             	mov    0x8(%ebp),%eax
80104233:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
80104239:	8b 45 08             	mov    0x8(%ebp),%eax
8010423c:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104242:	05 00 02 00 00       	add    $0x200,%eax
80104247:	39 c2                	cmp    %eax,%edx
80104249:	74 85                	je     801041d0 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
8010424b:	8b 45 08             	mov    0x8(%ebp),%eax
8010424e:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104254:	8d 48 01             	lea    0x1(%eax),%ecx
80104257:	8b 55 08             	mov    0x8(%ebp),%edx
8010425a:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
80104260:	25 ff 01 00 00       	and    $0x1ff,%eax
80104265:	89 c1                	mov    %eax,%ecx
80104267:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010426a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010426d:	01 d0                	add    %edx,%eax
8010426f:	0f b6 10             	movzbl (%eax),%edx
80104272:	8b 45 08             	mov    0x8(%ebp),%eax
80104275:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
80104279:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010427d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104280:	3b 45 10             	cmp    0x10(%ebp),%eax
80104283:	7c ab                	jl     80104230 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80104285:	8b 45 08             	mov    0x8(%ebp),%eax
80104288:	05 34 02 00 00       	add    $0x234,%eax
8010428d:	83 ec 0c             	sub    $0xc,%esp
80104290:	50                   	push   %eax
80104291:	e8 c3 0c 00 00       	call   80104f59 <wakeup>
80104296:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104299:	8b 45 08             	mov    0x8(%ebp),%eax
8010429c:	83 ec 0c             	sub    $0xc,%esp
8010429f:	50                   	push   %eax
801042a0:	e8 59 15 00 00       	call   801057fe <release>
801042a5:	83 c4 10             	add    $0x10,%esp
  return n;
801042a8:	8b 45 10             	mov    0x10(%ebp),%eax
}
801042ab:	c9                   	leave  
801042ac:	c3                   	ret    

801042ad <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801042ad:	55                   	push   %ebp
801042ae:	89 e5                	mov    %esp,%ebp
801042b0:	53                   	push   %ebx
801042b1:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
801042b4:	8b 45 08             	mov    0x8(%ebp),%eax
801042b7:	83 ec 0c             	sub    $0xc,%esp
801042ba:	50                   	push   %eax
801042bb:	e8 d7 14 00 00       	call   80105797 <acquire>
801042c0:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801042c3:	eb 3f                	jmp    80104304 <piperead+0x57>
    if(proc->killed){
801042c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801042cb:	8b 40 24             	mov    0x24(%eax),%eax
801042ce:	85 c0                	test   %eax,%eax
801042d0:	74 19                	je     801042eb <piperead+0x3e>
      release(&p->lock);
801042d2:	8b 45 08             	mov    0x8(%ebp),%eax
801042d5:	83 ec 0c             	sub    $0xc,%esp
801042d8:	50                   	push   %eax
801042d9:	e8 20 15 00 00       	call   801057fe <release>
801042de:	83 c4 10             	add    $0x10,%esp
      return -1;
801042e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042e6:	e9 bf 00 00 00       	jmp    801043aa <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
801042eb:	8b 45 08             	mov    0x8(%ebp),%eax
801042ee:	8b 55 08             	mov    0x8(%ebp),%edx
801042f1:	81 c2 34 02 00 00    	add    $0x234,%edx
801042f7:	83 ec 08             	sub    $0x8,%esp
801042fa:	50                   	push   %eax
801042fb:	52                   	push   %edx
801042fc:	e8 43 0b 00 00       	call   80104e44 <sleep>
80104301:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104304:	8b 45 08             	mov    0x8(%ebp),%eax
80104307:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104316:	39 c2                	cmp    %eax,%edx
80104318:	75 0d                	jne    80104327 <piperead+0x7a>
8010431a:	8b 45 08             	mov    0x8(%ebp),%eax
8010431d:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104323:	85 c0                	test   %eax,%eax
80104325:	75 9e                	jne    801042c5 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104327:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010432e:	eb 49                	jmp    80104379 <piperead+0xcc>
    if(p->nread == p->nwrite)
80104330:	8b 45 08             	mov    0x8(%ebp),%eax
80104333:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104339:	8b 45 08             	mov    0x8(%ebp),%eax
8010433c:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
80104342:	39 c2                	cmp    %eax,%edx
80104344:	74 3d                	je     80104383 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80104346:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104349:	8b 45 0c             	mov    0xc(%ebp),%eax
8010434c:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
8010434f:	8b 45 08             	mov    0x8(%ebp),%eax
80104352:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
80104358:	8d 48 01             	lea    0x1(%eax),%ecx
8010435b:	8b 55 08             	mov    0x8(%ebp),%edx
8010435e:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
80104364:	25 ff 01 00 00       	and    $0x1ff,%eax
80104369:	89 c2                	mov    %eax,%edx
8010436b:	8b 45 08             	mov    0x8(%ebp),%eax
8010436e:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
80104373:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80104375:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437c:	3b 45 10             	cmp    0x10(%ebp),%eax
8010437f:	7c af                	jl     80104330 <piperead+0x83>
80104381:	eb 01                	jmp    80104384 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
80104383:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80104384:	8b 45 08             	mov    0x8(%ebp),%eax
80104387:	05 38 02 00 00       	add    $0x238,%eax
8010438c:	83 ec 0c             	sub    $0xc,%esp
8010438f:	50                   	push   %eax
80104390:	e8 c4 0b 00 00       	call   80104f59 <wakeup>
80104395:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
80104398:	8b 45 08             	mov    0x8(%ebp),%eax
8010439b:	83 ec 0c             	sub    $0xc,%esp
8010439e:	50                   	push   %eax
8010439f:	e8 5a 14 00 00       	call   801057fe <release>
801043a4:	83 c4 10             	add    $0x10,%esp
  return i;
801043a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801043aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043ad:	c9                   	leave  
801043ae:	c3                   	ret    

801043af <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
801043af:	55                   	push   %ebp
801043b0:	89 e5                	mov    %esp,%ebp
801043b2:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801043b5:	9c                   	pushf  
801043b6:	58                   	pop    %eax
801043b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
801043ba:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801043bd:	c9                   	leave  
801043be:	c3                   	ret    

801043bf <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
801043bf:	55                   	push   %ebp
801043c0:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
801043c2:	fb                   	sti    
}
801043c3:	90                   	nop
801043c4:	5d                   	pop    %ebp
801043c5:	c3                   	ret    

801043c6 <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
801043c6:	55                   	push   %ebp
801043c7:	89 e5                	mov    %esp,%ebp
801043c9:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
801043cc:	83 ec 08             	sub    $0x8,%esp
801043cf:	68 24 91 10 80       	push   $0x80109124
801043d4:	68 80 39 11 80       	push   $0x80113980
801043d9:	e8 97 13 00 00       	call   80105775 <initlock>
801043de:	83 c4 10             	add    $0x10,%esp
}
801043e1:	90                   	nop
801043e2:	c9                   	leave  
801043e3:	c3                   	ret    

801043e4 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801043e4:	55                   	push   %ebp
801043e5:	89 e5                	mov    %esp,%ebp
801043e7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
801043ea:	83 ec 0c             	sub    $0xc,%esp
801043ed:	68 80 39 11 80       	push   $0x80113980
801043f2:	e8 a0 13 00 00       	call   80105797 <acquire>
801043f7:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043fa:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104401:	eb 11                	jmp    80104414 <allocproc+0x30>
    if(p->state == UNUSED)
80104403:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104406:	8b 40 0c             	mov    0xc(%eax),%eax
80104409:	85 c0                	test   %eax,%eax
8010440b:	74 2a                	je     80104437 <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010440d:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104414:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
8010441b:	72 e6                	jb     80104403 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
8010441d:	83 ec 0c             	sub    $0xc,%esp
80104420:	68 80 39 11 80       	push   $0x80113980
80104425:	e8 d4 13 00 00       	call   801057fe <release>
8010442a:	83 c4 10             	add    $0x10,%esp
  return 0;
8010442d:	b8 00 00 00 00       	mov    $0x0,%eax
80104432:	e9 c0 00 00 00       	jmp    801044f7 <allocproc+0x113>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
80104437:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
80104438:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010443b:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
80104442:	a1 04 c0 10 80       	mov    0x8010c004,%eax
80104447:	8d 50 01             	lea    0x1(%eax),%edx
8010444a:	89 15 04 c0 10 80    	mov    %edx,0x8010c004
80104450:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104453:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
80104456:	83 ec 0c             	sub    $0xc,%esp
80104459:	68 80 39 11 80       	push   $0x80113980
8010445e:	e8 9b 13 00 00       	call   801057fe <release>
80104463:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80104466:	e8 5a e7 ff ff       	call   80102bc5 <kalloc>
8010446b:	89 c2                	mov    %eax,%edx
8010446d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104470:	89 50 08             	mov    %edx,0x8(%eax)
80104473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104476:	8b 40 08             	mov    0x8(%eax),%eax
80104479:	85 c0                	test   %eax,%eax
8010447b:	75 11                	jne    8010448e <allocproc+0xaa>
    p->state = UNUSED;
8010447d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104480:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
80104487:	b8 00 00 00 00       	mov    $0x0,%eax
8010448c:	eb 69                	jmp    801044f7 <allocproc+0x113>
  }
  sp = p->kstack + KSTACKSIZE;
8010448e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104491:	8b 40 08             	mov    0x8(%eax),%eax
80104494:	05 00 10 00 00       	add    $0x1000,%eax
80104499:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
8010449c:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
801044a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044a6:	89 50 18             	mov    %edx,0x18(%eax)

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
801044a9:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
801044ad:	ba ea 6e 10 80       	mov    $0x80106eea,%edx
801044b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801044b5:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
801044b7:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
801044bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044be:	8b 55 f0             	mov    -0x10(%ebp),%edx
801044c1:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
801044c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044c7:	8b 40 1c             	mov    0x1c(%eax),%eax
801044ca:	83 ec 04             	sub    $0x4,%esp
801044cd:	6a 14                	push   $0x14
801044cf:	6a 00                	push   $0x0
801044d1:	50                   	push   %eax
801044d2:	e8 23 15 00 00       	call   801059fa <memset>
801044d7:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
801044da:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044dd:	8b 40 1c             	mov    0x1c(%eax),%eax
801044e0:	ba 13 4e 10 80       	mov    $0x80104e13,%edx
801044e5:	89 50 10             	mov    %edx,0x10(%eax)

  //set priority 0 by default
  p->priority = 0;
801044e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044eb:	66 c7 80 84 00 00 00 	movw   $0x0,0x84(%eax)
801044f2:	00 00 

  return p;
801044f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801044f7:	c9                   	leave  
801044f8:	c3                   	ret    

801044f9 <makerunnable>:

//PAGEBREAK: 32

void
makerunnable (struct proc* p)
{
801044f9:	55                   	push   %ebp
801044fa:	89 e5                	mov    %esp,%ebp
801044fc:	83 ec 10             	sub    $0x10,%esp
  int priority;
  struct proc* lastOfLevel ;
  p->state = RUNNABLE;
801044ff:	8b 45 08             	mov    0x8(%ebp),%eax
80104502:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  p->next=0;
80104509:	8b 45 08             	mov    0x8(%ebp),%eax
8010450c:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104513:	00 00 00 
  p->age=0;
80104516:	8b 45 08             	mov    0x8(%ebp),%eax
80104519:	66 c7 80 86 00 00 00 	movw   $0x0,0x86(%eax)
80104520:	00 00 
  priority=p->priority;
80104522:	8b 45 08             	mov    0x8(%ebp),%eax
80104525:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
8010452c:	0f b7 c0             	movzwl %ax,%eax
8010452f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  lastOfLevel = ptable.mlf[priority];
80104532:	8b 45 f8             	mov    -0x8(%ebp),%eax
80104535:	05 0c 0a 00 00       	add    $0xa0c,%eax
8010453a:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104541:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
80104544:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80104548:	75 21                	jne    8010456b <makerunnable+0x72>
    ptable.mlf[priority]=p;
8010454a:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010454d:	8d 90 0c 0a 00 00    	lea    0xa0c(%eax),%edx
80104553:	8b 45 08             	mov    0x8(%ebp),%eax
80104556:	89 04 95 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,4)
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
      lastOfLevel=lastOfLevel->next;
    }
    lastOfLevel->next=p;  //and I keep it as the last
  }
}
8010455d:	eb 25                	jmp    80104584 <makerunnable+0x8b>

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
    ptable.mlf[priority]=p;
  }else{
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
      lastOfLevel=lastOfLevel->next;
8010455f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104562:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104568:	89 45 fc             	mov    %eax,-0x4(%ebp)
  lastOfLevel = ptable.mlf[priority];

  if(lastOfLevel ==0){   //If the level does not have processes, it saves the process as the first
    ptable.mlf[priority]=p;
  }else{
    while(lastOfLevel->next != 0){ // if not, I take the first and advance until I reach the last
8010456b:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010456e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80104574:	85 c0                	test   %eax,%eax
80104576:	75 e7                	jne    8010455f <makerunnable+0x66>
      lastOfLevel=lastOfLevel->next;
    }
    lastOfLevel->next=p;  //and I keep it as the last
80104578:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010457b:	8b 55 08             	mov    0x8(%ebp),%edx
8010457e:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  }
}
80104584:	90                   	nop
80104585:	c9                   	leave  
80104586:	c3                   	ret    

80104587 <unqueue>:

struct proc*
unqueue(int level)
{
80104587:	55                   	push   %ebp
80104588:	89 e5                	mov    %esp,%ebp
8010458a:	83 ec 10             	sub    $0x10,%esp
  struct proc* res;
  res=0;
8010458d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  if(ptable.mlf[level]!=0){
80104594:	8b 45 08             	mov    0x8(%ebp),%eax
80104597:	05 0c 0a 00 00       	add    $0xa0c,%eax
8010459c:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045a3:	85 c0                	test   %eax,%eax
801045a5:	74 44                	je     801045eb <unqueue+0x64>
    res =ptable.mlf[level];
801045a7:	8b 45 08             	mov    0x8(%ebp),%eax
801045aa:	05 0c 0a 00 00       	add    $0xa0c,%eax
801045af:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045b6:	89 45 fc             	mov    %eax,-0x4(%ebp)
    ptable.mlf[level]=ptable.mlf[level]->next;
801045b9:	8b 45 08             	mov    0x8(%ebp),%eax
801045bc:	05 0c 0a 00 00       	add    $0xa0c,%eax
801045c1:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801045c8:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
801045ce:	8b 55 08             	mov    0x8(%ebp),%edx
801045d1:	81 c2 0c 0a 00 00    	add    $0xa0c,%edx
801045d7:	89 04 95 84 39 11 80 	mov    %eax,-0x7feec67c(,%edx,4)
    res->next=0;
801045de:	8b 45 fc             	mov    -0x4(%ebp),%eax
801045e1:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801045e8:	00 00 00 
  }
  return res;
801045eb:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
801045ee:	c9                   	leave  
801045ef:	c3                   	ret    

801045f0 <userinit>:


// Set up first user process.
void
userinit(void)
{
801045f0:	55                   	push   %ebp
801045f1:	89 e5                	mov    %esp,%ebp
801045f3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
801045f6:	e8 e9 fd ff ff       	call   801043e4 <allocproc>
801045fb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104601:	a3 68 c6 10 80       	mov    %eax,0x8010c668
  if((p->pgdir = setupkvm()) == 0)
80104606:	e8 1c 40 00 00       	call   80108627 <setupkvm>
8010460b:	89 c2                	mov    %eax,%edx
8010460d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104610:	89 50 04             	mov    %edx,0x4(%eax)
80104613:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104616:	8b 40 04             	mov    0x4(%eax),%eax
80104619:	85 c0                	test   %eax,%eax
8010461b:	75 0d                	jne    8010462a <userinit+0x3a>
    panic("userinit: out of memory?");
8010461d:	83 ec 0c             	sub    $0xc,%esp
80104620:	68 2b 91 10 80       	push   $0x8010912b
80104625:	e8 3c bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010462a:	ba 2c 00 00 00       	mov    $0x2c,%edx
8010462f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104632:	8b 40 04             	mov    0x4(%eax),%eax
80104635:	83 ec 04             	sub    $0x4,%esp
80104638:	52                   	push   %edx
80104639:	68 00 c5 10 80       	push   $0x8010c500
8010463e:	50                   	push   %eax
8010463f:	e8 3d 42 00 00       	call   80108881 <inituvm>
80104644:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
80104647:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010464a:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
80104650:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104653:	8b 40 18             	mov    0x18(%eax),%eax
80104656:	83 ec 04             	sub    $0x4,%esp
80104659:	6a 4c                	push   $0x4c
8010465b:	6a 00                	push   $0x0
8010465d:	50                   	push   %eax
8010465e:	e8 97 13 00 00       	call   801059fa <memset>
80104663:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80104666:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104669:	8b 40 18             	mov    0x18(%eax),%eax
8010466c:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80104672:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104675:	8b 40 18             	mov    0x18(%eax),%eax
80104678:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
8010467e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104681:	8b 40 18             	mov    0x18(%eax),%eax
80104684:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104687:	8b 52 18             	mov    0x18(%edx),%edx
8010468a:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010468e:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80104692:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104695:	8b 40 18             	mov    0x18(%eax),%eax
80104698:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010469b:	8b 52 18             	mov    0x18(%edx),%edx
8010469e:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
801046a2:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801046a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a9:	8b 40 18             	mov    0x18(%eax),%eax
801046ac:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801046b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046b6:	8b 40 18             	mov    0x18(%eax),%eax
801046b9:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801046c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046c3:	8b 40 18             	mov    0x18(%eax),%eax
801046c6:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	83 c0 6c             	add    $0x6c,%eax
801046d3:	83 ec 04             	sub    $0x4,%esp
801046d6:	6a 10                	push   $0x10
801046d8:	68 44 91 10 80       	push   $0x80109144
801046dd:	50                   	push   %eax
801046de:	e8 1a 15 00 00       	call   80105bfd <safestrcpy>
801046e3:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
801046e6:	83 ec 0c             	sub    $0xc,%esp
801046e9:	68 4d 91 10 80       	push   $0x8010914d
801046ee:	e8 d0 dd ff ff       	call   801024c3 <namei>
801046f3:	83 c4 10             	add    $0x10,%esp
801046f6:	89 c2                	mov    %eax,%edx
801046f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046fb:	89 50 68             	mov    %edx,0x68(%eax)

  //cprintf(" antes make runabbele de userinit \n");
  makerunnable(p);
801046fe:	83 ec 0c             	sub    $0xc,%esp
80104701:	ff 75 f4             	pushl  -0xc(%ebp)
80104704:	e8 f0 fd ff ff       	call   801044f9 <makerunnable>
80104709:	83 c4 10             	add    $0x10,%esp
  //cprintf("despues make runabbele de userinit \n");
}
8010470c:	90                   	nop
8010470d:	c9                   	leave  
8010470e:	c3                   	ret    

8010470f <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
8010470f:	55                   	push   %ebp
80104710:	89 e5                	mov    %esp,%ebp
80104712:	83 ec 18             	sub    $0x18,%esp
  uint sz;

  sz = proc->sz;
80104715:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010471b:	8b 00                	mov    (%eax),%eax
8010471d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
80104720:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80104724:	7e 31                	jle    80104757 <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
80104726:	8b 55 08             	mov    0x8(%ebp),%edx
80104729:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010472c:	01 c2                	add    %eax,%edx
8010472e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104734:	8b 40 04             	mov    0x4(%eax),%eax
80104737:	83 ec 04             	sub    $0x4,%esp
8010473a:	52                   	push   %edx
8010473b:	ff 75 f4             	pushl  -0xc(%ebp)
8010473e:	50                   	push   %eax
8010473f:	e8 8a 42 00 00       	call   801089ce <allocuvm>
80104744:	83 c4 10             	add    $0x10,%esp
80104747:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010474a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010474e:	75 3e                	jne    8010478e <growproc+0x7f>
      return -1;
80104750:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104755:	eb 59                	jmp    801047b0 <growproc+0xa1>
  } else if(n < 0){
80104757:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010475b:	79 31                	jns    8010478e <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
8010475d:	8b 55 08             	mov    0x8(%ebp),%edx
80104760:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104763:	01 c2                	add    %eax,%edx
80104765:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010476b:	8b 40 04             	mov    0x4(%eax),%eax
8010476e:	83 ec 04             	sub    $0x4,%esp
80104771:	52                   	push   %edx
80104772:	ff 75 f4             	pushl  -0xc(%ebp)
80104775:	50                   	push   %eax
80104776:	e8 1c 43 00 00       	call   80108a97 <deallocuvm>
8010477b:	83 c4 10             	add    $0x10,%esp
8010477e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104781:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104785:	75 07                	jne    8010478e <growproc+0x7f>
      return -1;
80104787:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010478c:	eb 22                	jmp    801047b0 <growproc+0xa1>
  }
  proc->sz = sz;
8010478e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104794:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104797:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
80104799:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010479f:	83 ec 0c             	sub    $0xc,%esp
801047a2:	50                   	push   %eax
801047a3:	e8 66 3f 00 00       	call   8010870e <switchuvm>
801047a8:	83 c4 10             	add    $0x10,%esp
  return 0;
801047ab:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047b0:	c9                   	leave  
801047b1:	c3                   	ret    

801047b2 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
801047b2:	55                   	push   %ebp
801047b3:	89 e5                	mov    %esp,%ebp
801047b5:	57                   	push   %edi
801047b6:	56                   	push   %esi
801047b7:	53                   	push   %ebx
801047b8:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
801047bb:	e8 24 fc ff ff       	call   801043e4 <allocproc>
801047c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047c3:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801047c7:	75 0a                	jne    801047d3 <fork+0x21>
    return -1;
801047c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047ce:	e9 be 01 00 00       	jmp    80104991 <fork+0x1df>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
801047d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047d9:	8b 10                	mov    (%eax),%edx
801047db:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047e1:	8b 40 04             	mov    0x4(%eax),%eax
801047e4:	83 ec 08             	sub    $0x8,%esp
801047e7:	52                   	push   %edx
801047e8:	50                   	push   %eax
801047e9:	e8 47 44 00 00       	call   80108c35 <copyuvm>
801047ee:	83 c4 10             	add    $0x10,%esp
801047f1:	89 c2                	mov    %eax,%edx
801047f3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f6:	89 50 04             	mov    %edx,0x4(%eax)
801047f9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047fc:	8b 40 04             	mov    0x4(%eax),%eax
801047ff:	85 c0                	test   %eax,%eax
80104801:	75 30                	jne    80104833 <fork+0x81>
    kfree(np->kstack);
80104803:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104806:	8b 40 08             	mov    0x8(%eax),%eax
80104809:	83 ec 0c             	sub    $0xc,%esp
8010480c:	50                   	push   %eax
8010480d:	e8 16 e3 ff ff       	call   80102b28 <kfree>
80104812:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80104815:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104818:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
8010481f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104822:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
80104829:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010482e:	e9 5e 01 00 00       	jmp    80104991 <fork+0x1df>
  }
  np->sz = proc->sz;
80104833:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104839:	8b 10                	mov    (%eax),%edx
8010483b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010483e:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
80104840:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104847:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010484a:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
8010484d:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104850:	8b 50 18             	mov    0x18(%eax),%edx
80104853:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104859:	8b 40 18             	mov    0x18(%eax),%eax
8010485c:	89 c3                	mov    %eax,%ebx
8010485e:	b8 13 00 00 00       	mov    $0x13,%eax
80104863:	89 d7                	mov    %edx,%edi
80104865:	89 de                	mov    %ebx,%esi
80104867:	89 c1                	mov    %eax,%ecx
80104869:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010486b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010486e:	8b 40 18             	mov    0x18(%eax),%eax
80104871:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
80104878:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010487f:	eb 43                	jmp    801048c4 <fork+0x112>
    if(proc->ofile[i])
80104881:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104887:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010488a:	83 c2 08             	add    $0x8,%edx
8010488d:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104891:	85 c0                	test   %eax,%eax
80104893:	74 2b                	je     801048c0 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104895:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010489b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010489e:	83 c2 08             	add    $0x8,%edx
801048a1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801048a5:	83 ec 0c             	sub    $0xc,%esp
801048a8:	50                   	push   %eax
801048a9:	e8 37 c7 ff ff       	call   80100fe5 <filedup>
801048ae:	83 c4 10             	add    $0x10,%esp
801048b1:	89 c1                	mov    %eax,%ecx
801048b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048b9:	83 c2 08             	add    $0x8,%edx
801048bc:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
801048c0:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
801048c4:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
801048c8:	7e b7                	jle    80104881 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

//duplicates the semaphore array
  for(i = 0; i < MAXPROCSEM; i++)
801048ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801048d1:	eb 43                	jmp    80104916 <fork+0x164>
    if(proc->osemaphore[i])
801048d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048dc:	83 c2 20             	add    $0x20,%edx
801048df:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801048e3:	85 c0                	test   %eax,%eax
801048e5:	74 2b                	je     80104912 <fork+0x160>
      np->osemaphore[i] = semaphoredup(proc->osemaphore[i]);
801048e7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801048ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801048f0:	83 c2 20             	add    $0x20,%edx
801048f3:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801048f7:	83 ec 0c             	sub    $0xc,%esp
801048fa:	50                   	push   %eax
801048fb:	e8 75 0d 00 00       	call   80105675 <semaphoredup>
80104900:	83 c4 10             	add    $0x10,%esp
80104903:	89 c1                	mov    %eax,%ecx
80104905:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104908:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010490b:	83 c2 20             	add    $0x20,%edx
8010490e:	89 4c 90 0c          	mov    %ecx,0xc(%eax,%edx,4)
  for(i = 0; i < NOFILE; i++)
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);

//duplicates the semaphore array
  for(i = 0; i < MAXPROCSEM; i++)
80104912:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104916:	83 7d e4 04          	cmpl   $0x4,-0x1c(%ebp)
8010491a:	7e b7                	jle    801048d3 <fork+0x121>
    if(proc->osemaphore[i])
      np->osemaphore[i] = semaphoredup(proc->osemaphore[i]);

  np->cwd = idup(proc->cwd);
8010491c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104922:	8b 40 68             	mov    0x68(%eax),%eax
80104925:	83 ec 0c             	sub    $0xc,%esp
80104928:	50                   	push   %eax
80104929:	e8 a3 cf ff ff       	call   801018d1 <idup>
8010492e:	83 c4 10             	add    $0x10,%esp
80104931:	89 c2                	mov    %eax,%edx
80104933:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104936:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
80104939:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010493f:	8d 50 6c             	lea    0x6c(%eax),%edx
80104942:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104945:	83 c0 6c             	add    $0x6c,%eax
80104948:	83 ec 04             	sub    $0x4,%esp
8010494b:	6a 10                	push   $0x10
8010494d:	52                   	push   %edx
8010494e:	50                   	push   %eax
8010494f:	e8 a9 12 00 00       	call   80105bfd <safestrcpy>
80104954:	83 c4 10             	add    $0x10,%esp

  pid = np->pid;
80104957:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010495a:	8b 40 10             	mov    0x10(%eax),%eax
8010495d:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
80104960:	83 ec 0c             	sub    $0xc,%esp
80104963:	68 80 39 11 80       	push   $0x80113980
80104968:	e8 2a 0e 00 00       	call   80105797 <acquire>
8010496d:	83 c4 10             	add    $0x10,%esp
  makerunnable(np);
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	ff 75 e0             	pushl  -0x20(%ebp)
80104976:	e8 7e fb ff ff       	call   801044f9 <makerunnable>
8010497b:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
8010497e:	83 ec 0c             	sub    $0xc,%esp
80104981:	68 80 39 11 80       	push   $0x80113980
80104986:	e8 73 0e 00 00       	call   801057fe <release>
8010498b:	83 c4 10             	add    $0x10,%esp

  return pid;
8010498e:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
80104991:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104994:	5b                   	pop    %ebx
80104995:	5e                   	pop    %esi
80104996:	5f                   	pop    %edi
80104997:	5d                   	pop    %ebp
80104998:	c3                   	ret    

80104999 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
80104999:	55                   	push   %ebp
8010499a:	89 e5                	mov    %esp,%ebp
8010499c:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
8010499f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801049a6:	a1 68 c6 10 80       	mov    0x8010c668,%eax
801049ab:	39 c2                	cmp    %eax,%edx
801049ad:	75 0d                	jne    801049bc <exit+0x23>
    panic("init exiting");
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	68 4f 91 10 80       	push   $0x8010914f
801049b7:	e8 aa bb ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
801049bc:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801049c3:	eb 48                	jmp    80104a0d <exit+0x74>
    if(proc->ofile[fd]){
801049c5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049cb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049ce:	83 c2 08             	add    $0x8,%edx
801049d1:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049d5:	85 c0                	test   %eax,%eax
801049d7:	74 30                	je     80104a09 <exit+0x70>
      fileclose(proc->ofile[fd]);
801049d9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049df:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049e2:	83 c2 08             	add    $0x8,%edx
801049e5:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801049e9:	83 ec 0c             	sub    $0xc,%esp
801049ec:	50                   	push   %eax
801049ed:	e8 44 c6 ff ff       	call   80101036 <fileclose>
801049f2:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
801049f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049fb:	8b 55 f0             	mov    -0x10(%ebp),%edx
801049fe:	83 c2 08             	add    $0x8,%edx
80104a01:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104a08:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104a09:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80104a0d:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
80104a11:	7e b2                	jle    801049c5 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104a13:	e8 9c ea ff ff       	call   801034b4 <begin_op>
  iput(proc->cwd);
80104a18:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a1e:	8b 40 68             	mov    0x68(%eax),%eax
80104a21:	83 ec 0c             	sub    $0xc,%esp
80104a24:	50                   	push   %eax
80104a25:	e8 ab d0 ff ff       	call   80101ad5 <iput>
80104a2a:	83 c4 10             	add    $0x10,%esp
  end_op();
80104a2d:	e8 0e eb ff ff       	call   80103540 <end_op>
  proc->cwd = 0;
80104a32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a38:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
80104a3f:	83 ec 0c             	sub    $0xc,%esp
80104a42:	68 80 39 11 80       	push   $0x80113980
80104a47:	e8 4b 0d 00 00       	call   80105797 <acquire>
80104a4c:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
80104a4f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a55:	8b 40 14             	mov    0x14(%eax),%eax
80104a58:	83 ec 0c             	sub    $0xc,%esp
80104a5b:	50                   	push   %eax
80104a5c:	e8 8f 04 00 00       	call   80104ef0 <wakeup1>
80104a61:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a64:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104a6b:	eb 3f                	jmp    80104aac <exit+0x113>
    if(p->parent == proc){
80104a6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a70:	8b 50 14             	mov    0x14(%eax),%edx
80104a73:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a79:	39 c2                	cmp    %eax,%edx
80104a7b:	75 28                	jne    80104aa5 <exit+0x10c>
      p->parent = initproc;
80104a7d:	8b 15 68 c6 10 80    	mov    0x8010c668,%edx
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
80104a89:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8c:	8b 40 0c             	mov    0xc(%eax),%eax
80104a8f:	83 f8 05             	cmp    $0x5,%eax
80104a92:	75 11                	jne    80104aa5 <exit+0x10c>
        wakeup1(initproc);
80104a94:	a1 68 c6 10 80       	mov    0x8010c668,%eax
80104a99:	83 ec 0c             	sub    $0xc,%esp
80104a9c:	50                   	push   %eax
80104a9d:	e8 4e 04 00 00       	call   80104ef0 <wakeup1>
80104aa2:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aa5:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104aac:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80104ab3:	72 b8                	jb     80104a6d <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104ab5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104abb:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  sched();
80104ac2:	e8 1f 02 00 00       	call   80104ce6 <sched>
  panic("zombie exit");
80104ac7:	83 ec 0c             	sub    $0xc,%esp
80104aca:	68 5c 91 10 80       	push   $0x8010915c
80104acf:	e8 92 ba ff ff       	call   80100566 <panic>

80104ad4 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104ad4:	55                   	push   %ebp
80104ad5:	89 e5                	mov    %esp,%ebp
80104ad7:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104ada:	83 ec 0c             	sub    $0xc,%esp
80104add:	68 80 39 11 80       	push   $0x80113980
80104ae2:	e8 b0 0c 00 00       	call   80105797 <acquire>
80104ae7:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104aea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104af1:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104af8:	e9 a9 00 00 00       	jmp    80104ba6 <wait+0xd2>
      if(p->parent != proc)
80104afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b00:	8b 50 14             	mov    0x14(%eax),%edx
80104b03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b09:	39 c2                	cmp    %eax,%edx
80104b0b:	0f 85 8d 00 00 00    	jne    80104b9e <wait+0xca>
        continue;
      havekids = 1;
80104b11:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b18:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b1b:	8b 40 0c             	mov    0xc(%eax),%eax
80104b1e:	83 f8 05             	cmp    $0x5,%eax
80104b21:	75 7c                	jne    80104b9f <wait+0xcb>
        // Found one.
        pid = p->pid;
80104b23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b26:	8b 40 10             	mov    0x10(%eax),%eax
80104b29:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104b2c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b2f:	8b 40 08             	mov    0x8(%eax),%eax
80104b32:	83 ec 0c             	sub    $0xc,%esp
80104b35:	50                   	push   %eax
80104b36:	e8 ed df ff ff       	call   80102b28 <kfree>
80104b3b:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104b3e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b41:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104b48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b4b:	8b 40 04             	mov    0x4(%eax),%eax
80104b4e:	83 ec 0c             	sub    $0xc,%esp
80104b51:	50                   	push   %eax
80104b52:	e8 fd 3f 00 00       	call   80108b54 <freevm>
80104b57:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104b5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b5d:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104b64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b67:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104b6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b71:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104b78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b7b:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104b7f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b82:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104b89:	83 ec 0c             	sub    $0xc,%esp
80104b8c:	68 80 39 11 80       	push   $0x80113980
80104b91:	e8 68 0c 00 00       	call   801057fe <release>
80104b96:	83 c4 10             	add    $0x10,%esp
        return pid;
80104b99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b9c:	eb 5b                	jmp    80104bf9 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104b9e:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b9f:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104ba6:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80104bad:	0f 82 4a ff ff ff    	jb     80104afd <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104bb3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104bb7:	74 0d                	je     80104bc6 <wait+0xf2>
80104bb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104bbf:	8b 40 24             	mov    0x24(%eax),%eax
80104bc2:	85 c0                	test   %eax,%eax
80104bc4:	74 17                	je     80104bdd <wait+0x109>
      release(&ptable.lock);
80104bc6:	83 ec 0c             	sub    $0xc,%esp
80104bc9:	68 80 39 11 80       	push   $0x80113980
80104bce:	e8 2b 0c 00 00       	call   801057fe <release>
80104bd3:	83 c4 10             	add    $0x10,%esp
      return -1;
80104bd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bdb:	eb 1c                	jmp    80104bf9 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104bdd:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104be3:	83 ec 08             	sub    $0x8,%esp
80104be6:	68 80 39 11 80       	push   $0x80113980
80104beb:	50                   	push   %eax
80104bec:	e8 53 02 00 00       	call   80104e44 <sleep>
80104bf1:	83 c4 10             	add    $0x10,%esp
  }
80104bf4:	e9 f1 fe ff ff       	jmp    80104aea <wait+0x16>
}
80104bf9:	c9                   	leave  
80104bfa:	c3                   	ret    

80104bfb <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104bfb:	55                   	push   %ebp
80104bfc:	89 e5                	mov    %esp,%ebp
80104bfe:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int level;
  for(;;){
    // Enable interrupts on this processor.
    sti();
80104c01:	e8 b9 f7 ff ff       	call   801043bf <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104c06:	83 ec 0c             	sub    $0xc,%esp
80104c09:	68 80 39 11 80       	push   $0x80113980
80104c0e:	e8 84 0b 00 00       	call   80105797 <acquire>
80104c13:	83 c4 10             	add    $0x10,%esp

    for(level = MLFMAXLEVEL; level < MLFLEVELS; level++){
80104c16:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80104c1d:	e9 a5 00 00 00       	jmp    80104cc7 <scheduler+0xcc>

      if(ptable.mlf[level] != 0){
80104c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c25:	05 0c 0a 00 00       	add    $0xa0c,%eax
80104c2a:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104c31:	85 c0                	test   %eax,%eax
80104c33:	0f 84 8a 00 00 00    	je     80104cc3 <scheduler+0xc8>
        p = ptable.mlf[level];
80104c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c3c:	05 0c 0a 00 00       	add    $0xa0c,%eax
80104c41:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80104c48:	89 45 f0             	mov    %eax,-0x10(%ebp)
        // Switch to chosen process.  It is the process's job
        // to release ptable.lock and then reacquire it
        // before jumping back to us.
        proc = p;
80104c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c4e:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
        switchuvm(p);
80104c54:	83 ec 0c             	sub    $0xc,%esp
80104c57:	ff 75 f0             	pushl  -0x10(%ebp)
80104c5a:	e8 af 3a 00 00       	call   8010870e <switchuvm>
80104c5f:	83 c4 10             	add    $0x10,%esp
        p->state = RUNNING;                       //puts in "RUNNING" the chosen process
80104c62:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c65:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
        p->timesscheduled++;
80104c6c:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c6f:	0f b7 80 88 00 00 00 	movzwl 0x88(%eax),%eax
80104c76:	8d 50 01             	lea    0x1(%eax),%edx
80104c79:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c7c:	66 89 90 88 00 00 00 	mov    %dx,0x88(%eax)
        unqueue(level);
80104c83:	83 ec 0c             	sub    $0xc,%esp
80104c86:	ff 75 f4             	pushl  -0xc(%ebp)
80104c89:	e8 f9 f8 ff ff       	call   80104587 <unqueue>
80104c8e:	83 c4 10             	add    $0x10,%esp


        swtch(&cpu->scheduler, proc->context);
80104c91:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c97:	8b 40 1c             	mov    0x1c(%eax),%eax
80104c9a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104ca1:	83 c2 04             	add    $0x4,%edx
80104ca4:	83 ec 08             	sub    $0x8,%esp
80104ca7:	50                   	push   %eax
80104ca8:	52                   	push   %edx
80104ca9:	e8 c0 0f 00 00       	call   80105c6e <swtch>
80104cae:	83 c4 10             	add    $0x10,%esp
        switchkvm();
80104cb1:	e8 3b 3a 00 00       	call   801086f1 <switchkvm>

        // Process is done running for now.
        // It should have changed its p->state before coming back.
        proc = 0;
80104cb6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104cbd:	00 00 00 00 
        break;
80104cc1:	eb 0e                	jmp    80104cd1 <scheduler+0xd6>
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);

    for(level = MLFMAXLEVEL; level < MLFLEVELS; level++){
80104cc3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80104cc7:	83 7d f4 03          	cmpl   $0x3,-0xc(%ebp)
80104ccb:	0f 8e 51 ff ff ff    	jle    80104c22 <scheduler+0x27>
        // It should have changed its p->state before coming back.
        proc = 0;
        break;
      }
    }
    release(&ptable.lock);
80104cd1:	83 ec 0c             	sub    $0xc,%esp
80104cd4:	68 80 39 11 80       	push   $0x80113980
80104cd9:	e8 20 0b 00 00       	call   801057fe <release>
80104cde:	83 c4 10             	add    $0x10,%esp

  }
80104ce1:	e9 1b ff ff ff       	jmp    80104c01 <scheduler+0x6>

80104ce6 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104cec:	83 ec 0c             	sub    $0xc,%esp
80104cef:	68 80 39 11 80       	push   $0x80113980
80104cf4:	e8 d1 0b 00 00       	call   801058ca <holding>
80104cf9:	83 c4 10             	add    $0x10,%esp
80104cfc:	85 c0                	test   %eax,%eax
80104cfe:	75 0d                	jne    80104d0d <sched+0x27>
    panic("sched ptable.lock");
80104d00:	83 ec 0c             	sub    $0xc,%esp
80104d03:	68 68 91 10 80       	push   $0x80109168
80104d08:	e8 59 b8 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104d0d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d13:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d19:	83 f8 01             	cmp    $0x1,%eax
80104d1c:	74 0d                	je     80104d2b <sched+0x45>
    panic("sched locks");
80104d1e:	83 ec 0c             	sub    $0xc,%esp
80104d21:	68 7a 91 10 80       	push   $0x8010917a
80104d26:	e8 3b b8 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104d2b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d31:	8b 40 0c             	mov    0xc(%eax),%eax
80104d34:	83 f8 04             	cmp    $0x4,%eax
80104d37:	75 0d                	jne    80104d46 <sched+0x60>
    panic("sched running");
80104d39:	83 ec 0c             	sub    $0xc,%esp
80104d3c:	68 86 91 10 80       	push   $0x80109186
80104d41:	e8 20 b8 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104d46:	e8 64 f6 ff ff       	call   801043af <readeflags>
80104d4b:	25 00 02 00 00       	and    $0x200,%eax
80104d50:	85 c0                	test   %eax,%eax
80104d52:	74 0d                	je     80104d61 <sched+0x7b>
    panic("sched interruptible");
80104d54:	83 ec 0c             	sub    $0xc,%esp
80104d57:	68 94 91 10 80       	push   $0x80109194
80104d5c:	e8 05 b8 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104d61:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d67:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104d6d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104d70:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d76:	8b 40 04             	mov    0x4(%eax),%eax
80104d79:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104d80:	83 c2 1c             	add    $0x1c,%edx
80104d83:	83 ec 08             	sub    $0x8,%esp
80104d86:	50                   	push   %eax
80104d87:	52                   	push   %edx
80104d88:	e8 e1 0e 00 00       	call   80105c6e <swtch>
80104d8d:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104d90:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d96:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d99:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104d9f:	90                   	nop
80104da0:	c9                   	leave  
80104da1:	c3                   	ret    

80104da2 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104da2:	55                   	push   %ebp
80104da3:	89 e5                	mov    %esp,%ebp
80104da5:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104da8:	83 ec 0c             	sub    $0xc,%esp
80104dab:	68 80 39 11 80       	push   $0x80113980
80104db0:	e8 e2 09 00 00       	call   80105797 <acquire>
80104db5:	83 c4 10             	add    $0x10,%esp
  if(proc->priority < (MLFLEVELS-1)){
80104db8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dbe:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104dc5:	66 83 f8 02          	cmp    $0x2,%ax
80104dc9:	77 1e                	ja     80104de9 <yield+0x47>
    proc->priority=(proc->priority)+1;
80104dcb:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104dd1:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104dd8:	0f b7 92 84 00 00 00 	movzwl 0x84(%edx),%edx
80104ddf:	83 c2 01             	add    $0x1,%edx
80104de2:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
  }
  makerunnable(proc);
80104de9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104def:	83 ec 0c             	sub    $0xc,%esp
80104df2:	50                   	push   %eax
80104df3:	e8 01 f7 ff ff       	call   801044f9 <makerunnable>
80104df8:	83 c4 10             	add    $0x10,%esp
  sched();
80104dfb:	e8 e6 fe ff ff       	call   80104ce6 <sched>
  release(&ptable.lock);
80104e00:	83 ec 0c             	sub    $0xc,%esp
80104e03:	68 80 39 11 80       	push   $0x80113980
80104e08:	e8 f1 09 00 00       	call   801057fe <release>
80104e0d:	83 c4 10             	add    $0x10,%esp
}
80104e10:	90                   	nop
80104e11:	c9                   	leave  
80104e12:	c3                   	ret    

80104e13 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e13:	55                   	push   %ebp
80104e14:	89 e5                	mov    %esp,%ebp
80104e16:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e19:	83 ec 0c             	sub    $0xc,%esp
80104e1c:	68 80 39 11 80       	push   $0x80113980
80104e21:	e8 d8 09 00 00       	call   801057fe <release>
80104e26:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e29:	a1 08 c0 10 80       	mov    0x8010c008,%eax
80104e2e:	85 c0                	test   %eax,%eax
80104e30:	74 0f                	je     80104e41 <forkret+0x2e>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
80104e32:	c7 05 08 c0 10 80 00 	movl   $0x0,0x8010c008
80104e39:	00 00 00 
    initlog();
80104e3c:	e8 4d e4 ff ff       	call   8010328e <initlog>
  }

  // Return to "caller", actually trapret (see allocproc).
}
80104e41:	90                   	nop
80104e42:	c9                   	leave  
80104e43:	c3                   	ret    

80104e44 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104e44:	55                   	push   %ebp
80104e45:	89 e5                	mov    %esp,%ebp
80104e47:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104e4a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e50:	85 c0                	test   %eax,%eax
80104e52:	75 0d                	jne    80104e61 <sleep+0x1d>
    panic("sleep");
80104e54:	83 ec 0c             	sub    $0xc,%esp
80104e57:	68 a8 91 10 80       	push   $0x801091a8
80104e5c:	e8 05 b7 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104e61:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104e65:	75 0d                	jne    80104e74 <sleep+0x30>
    panic("sleep without lk");
80104e67:	83 ec 0c             	sub    $0xc,%esp
80104e6a:	68 ae 91 10 80       	push   $0x801091ae
80104e6f:	e8 f2 b6 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104e74:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104e7b:	74 1e                	je     80104e9b <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104e7d:	83 ec 0c             	sub    $0xc,%esp
80104e80:	68 80 39 11 80       	push   $0x80113980
80104e85:	e8 0d 09 00 00       	call   80105797 <acquire>
80104e8a:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104e8d:	83 ec 0c             	sub    $0xc,%esp
80104e90:	ff 75 0c             	pushl  0xc(%ebp)
80104e93:	e8 66 09 00 00       	call   801057fe <release>
80104e98:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104e9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ea1:	8b 55 08             	mov    0x8(%ebp),%edx
80104ea4:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104ea7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ead:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104eb4:	e8 2d fe ff ff       	call   80104ce6 <sched>

  // Tidy up.
  proc->chan = 0;
80104eb9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ebf:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104ec6:	81 7d 0c 80 39 11 80 	cmpl   $0x80113980,0xc(%ebp)
80104ecd:	74 1e                	je     80104eed <sleep+0xa9>
    release(&ptable.lock);
80104ecf:	83 ec 0c             	sub    $0xc,%esp
80104ed2:	68 80 39 11 80       	push   $0x80113980
80104ed7:	e8 22 09 00 00       	call   801057fe <release>
80104edc:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104edf:	83 ec 0c             	sub    $0xc,%esp
80104ee2:	ff 75 0c             	pushl  0xc(%ebp)
80104ee5:	e8 ad 08 00 00       	call   80105797 <acquire>
80104eea:	83 c4 10             	add    $0x10,%esp
  }
}
80104eed:	90                   	nop
80104eee:	c9                   	leave  
80104eef:	c3                   	ret    

80104ef0 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
80104ef3:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104ef6:	c7 45 fc b4 39 11 80 	movl   $0x801139b4,-0x4(%ebp)
80104efd:	eb 4e                	jmp    80104f4d <wakeup1+0x5d>
    if(p->state == SLEEPING && p->chan == chan){
80104eff:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f02:	8b 40 0c             	mov    0xc(%eax),%eax
80104f05:	83 f8 02             	cmp    $0x2,%eax
80104f08:	75 3c                	jne    80104f46 <wakeup1+0x56>
80104f0a:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f0d:	8b 40 20             	mov    0x20(%eax),%eax
80104f10:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f13:	75 31                	jne    80104f46 <wakeup1+0x56>
      if(p->priority>MLFMAXLEVEL){
80104f15:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f18:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104f1f:	66 85 c0             	test   %ax,%ax
80104f22:	74 17                	je     80104f3b <wakeup1+0x4b>
        p->priority--;
80104f24:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f27:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
80104f2e:	8d 50 ff             	lea    -0x1(%eax),%edx
80104f31:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f34:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      }
      makerunnable(p);
80104f3b:	ff 75 fc             	pushl  -0x4(%ebp)
80104f3e:	e8 b6 f5 ff ff       	call   801044f9 <makerunnable>
80104f43:	83 c4 04             	add    $0x4,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f46:	81 45 fc a0 00 00 00 	addl   $0xa0,-0x4(%ebp)
80104f4d:	81 7d fc b4 61 11 80 	cmpl   $0x801161b4,-0x4(%ebp)
80104f54:	72 a9                	jb     80104eff <wakeup1+0xf>
        p->priority--;
      }
      makerunnable(p);
    }

}
80104f56:	90                   	nop
80104f57:	c9                   	leave  
80104f58:	c3                   	ret    

80104f59 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f59:	55                   	push   %ebp
80104f5a:	89 e5                	mov    %esp,%ebp
80104f5c:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f5f:	83 ec 0c             	sub    $0xc,%esp
80104f62:	68 80 39 11 80       	push   $0x80113980
80104f67:	e8 2b 08 00 00       	call   80105797 <acquire>
80104f6c:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104f6f:	83 ec 0c             	sub    $0xc,%esp
80104f72:	ff 75 08             	pushl  0x8(%ebp)
80104f75:	e8 76 ff ff ff       	call   80104ef0 <wakeup1>
80104f7a:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104f7d:	83 ec 0c             	sub    $0xc,%esp
80104f80:	68 80 39 11 80       	push   $0x80113980
80104f85:	e8 74 08 00 00       	call   801057fe <release>
80104f8a:	83 c4 10             	add    $0x10,%esp
}
80104f8d:	90                   	nop
80104f8e:	c9                   	leave  
80104f8f:	c3                   	ret    

80104f90 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104f90:	55                   	push   %ebp
80104f91:	89 e5                	mov    %esp,%ebp
80104f93:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104f96:	83 ec 0c             	sub    $0xc,%esp
80104f99:	68 80 39 11 80       	push   $0x80113980
80104f9e:	e8 f4 07 00 00       	call   80105797 <acquire>
80104fa3:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fa6:	c7 45 f4 b4 39 11 80 	movl   $0x801139b4,-0xc(%ebp)
80104fad:	eb 4c                	jmp    80104ffb <kill+0x6b>
    if(p->pid == pid){
80104faf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fb2:	8b 40 10             	mov    0x10(%eax),%eax
80104fb5:	3b 45 08             	cmp    0x8(%ebp),%eax
80104fb8:	75 3a                	jne    80104ff4 <kill+0x64>
      p->killed = 1;
80104fba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fbd:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104fc4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fc7:	8b 40 0c             	mov    0xc(%eax),%eax
80104fca:	83 f8 02             	cmp    $0x2,%eax
80104fcd:	75 0e                	jne    80104fdd <kill+0x4d>
        makerunnable(p);
80104fcf:	83 ec 0c             	sub    $0xc,%esp
80104fd2:	ff 75 f4             	pushl  -0xc(%ebp)
80104fd5:	e8 1f f5 ff ff       	call   801044f9 <makerunnable>
80104fda:	83 c4 10             	add    $0x10,%esp
      release(&ptable.lock);
80104fdd:	83 ec 0c             	sub    $0xc,%esp
80104fe0:	68 80 39 11 80       	push   $0x80113980
80104fe5:	e8 14 08 00 00       	call   801057fe <release>
80104fea:	83 c4 10             	add    $0x10,%esp
      return 0;
80104fed:	b8 00 00 00 00       	mov    $0x0,%eax
80104ff2:	eb 25                	jmp    80105019 <kill+0x89>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104ff4:	81 45 f4 a0 00 00 00 	addl   $0xa0,-0xc(%ebp)
80104ffb:	81 7d f4 b4 61 11 80 	cmpl   $0x801161b4,-0xc(%ebp)
80105002:	72 ab                	jb     80104faf <kill+0x1f>
        makerunnable(p);
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
80105004:	83 ec 0c             	sub    $0xc,%esp
80105007:	68 80 39 11 80       	push   $0x80113980
8010500c:	e8 ed 07 00 00       	call   801057fe <release>
80105011:	83 c4 10             	add    $0x10,%esp
  return -1;
80105014:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105019:	c9                   	leave  
8010501a:	c3                   	ret    

8010501b <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
8010501b:	55                   	push   %ebp
8010501c:	89 e5                	mov    %esp,%ebp
8010501e:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105021:	c7 45 f0 b4 39 11 80 	movl   $0x801139b4,-0x10(%ebp)
80105028:	e9 34 01 00 00       	jmp    80105161 <procdump+0x146>
    if(p->state == UNUSED)
8010502d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105030:	8b 40 0c             	mov    0xc(%eax),%eax
80105033:	85 c0                	test   %eax,%eax
80105035:	0f 84 1e 01 00 00    	je     80105159 <procdump+0x13e>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010503b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010503e:	8b 40 0c             	mov    0xc(%eax),%eax
80105041:	83 f8 05             	cmp    $0x5,%eax
80105044:	77 23                	ja     80105069 <procdump+0x4e>
80105046:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105049:	8b 40 0c             	mov    0xc(%eax),%eax
8010504c:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105053:	85 c0                	test   %eax,%eax
80105055:	74 12                	je     80105069 <procdump+0x4e>
      state = states[p->state];
80105057:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010505a:	8b 40 0c             	mov    0xc(%eax),%eax
8010505d:	8b 04 85 0c c0 10 80 	mov    -0x7fef3ff4(,%eax,4),%eax
80105064:	89 45 ec             	mov    %eax,-0x14(%ebp)
80105067:	eb 07                	jmp    80105070 <procdump+0x55>
    else
      state = "???";
80105069:	c7 45 ec bf 91 10 80 	movl   $0x801091bf,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
80105070:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105073:	8d 50 6c             	lea    0x6c(%eax),%edx
80105076:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105079:	8b 40 10             	mov    0x10(%eax),%eax
8010507c:	52                   	push   %edx
8010507d:	ff 75 ec             	pushl  -0x14(%ebp)
80105080:	50                   	push   %eax
80105081:	68 c3 91 10 80       	push   $0x801091c3
80105086:	e8 3b b3 ff ff       	call   801003c6 <cprintf>
8010508b:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
8010508e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105091:	8b 40 0c             	mov    0xc(%eax),%eax
80105094:	83 f8 02             	cmp    $0x2,%eax
80105097:	75 54                	jne    801050ed <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80105099:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010509c:	8b 40 1c             	mov    0x1c(%eax),%eax
8010509f:	8b 40 0c             	mov    0xc(%eax),%eax
801050a2:	83 c0 08             	add    $0x8,%eax
801050a5:	89 c2                	mov    %eax,%edx
801050a7:	83 ec 08             	sub    $0x8,%esp
801050aa:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050ad:	50                   	push   %eax
801050ae:	52                   	push   %edx
801050af:	e8 9c 07 00 00       	call   80105850 <getcallerpcs>
801050b4:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050b7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050be:	eb 1c                	jmp    801050dc <procdump+0xc1>
        cprintf(" %p", pc[i]);
801050c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050c3:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050c7:	83 ec 08             	sub    $0x8,%esp
801050ca:	50                   	push   %eax
801050cb:	68 cc 91 10 80       	push   $0x801091cc
801050d0:	e8 f1 b2 ff ff       	call   801003c6 <cprintf>
801050d5:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
801050d8:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801050dc:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801050e0:	7f 0b                	jg     801050ed <procdump+0xd2>
801050e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050e5:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050e9:	85 c0                	test   %eax,%eax
801050eb:	75 d3                	jne    801050c0 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf(" prioridad: %d",p->priority); //shows the priority of the process
801050ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050f0:	0f b7 80 84 00 00 00 	movzwl 0x84(%eax),%eax
801050f7:	0f b7 c0             	movzwl %ax,%eax
801050fa:	83 ec 08             	sub    $0x8,%esp
801050fd:	50                   	push   %eax
801050fe:	68 d0 91 10 80       	push   $0x801091d0
80105103:	e8 be b2 ff ff       	call   801003c6 <cprintf>
80105108:	83 c4 10             	add    $0x10,%esp
    cprintf(" edad: %d",p->age); //shows the priority of the process
8010510b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010510e:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
80105115:	0f b7 c0             	movzwl %ax,%eax
80105118:	83 ec 08             	sub    $0x8,%esp
8010511b:	50                   	push   %eax
8010511c:	68 df 91 10 80       	push   $0x801091df
80105121:	e8 a0 b2 ff ff       	call   801003c6 <cprintf>
80105126:	83 c4 10             	add    $0x10,%esp
    cprintf(" sch: %d",p->timesscheduled);
80105129:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010512c:	0f b7 80 88 00 00 00 	movzwl 0x88(%eax),%eax
80105133:	0f b7 c0             	movzwl %ax,%eax
80105136:	83 ec 08             	sub    $0x8,%esp
80105139:	50                   	push   %eax
8010513a:	68 e9 91 10 80       	push   $0x801091e9
8010513f:	e8 82 b2 ff ff       	call   801003c6 <cprintf>
80105144:	83 c4 10             	add    $0x10,%esp
    cprintf("\n");
80105147:	83 ec 0c             	sub    $0xc,%esp
8010514a:	68 f2 91 10 80       	push   $0x801091f2
8010514f:	e8 72 b2 ff ff       	call   801003c6 <cprintf>
80105154:	83 c4 10             	add    $0x10,%esp
80105157:	eb 01                	jmp    8010515a <procdump+0x13f>
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105159:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010515a:	81 45 f0 a0 00 00 00 	addl   $0xa0,-0x10(%ebp)
80105161:	81 7d f0 b4 61 11 80 	cmpl   $0x801161b4,-0x10(%ebp)
80105168:	0f 82 bf fe ff ff    	jb     8010502d <procdump+0x12>
    cprintf(" prioridad: %d",p->priority); //shows the priority of the process
    cprintf(" edad: %d",p->age); //shows the priority of the process
    cprintf(" sch: %d",p->timesscheduled);
    cprintf("\n");
  }
}
8010516e:	90                   	nop
8010516f:	c9                   	leave  
80105170:	c3                   	ret    

80105171 <raisepriority>:



void
raisepriority(int level )         //unqueue, modify the priority and enqueue
{
80105171:	55                   	push   %ebp
80105172:	89 e5                	mov    %esp,%ebp
80105174:	83 ec 10             	sub    $0x10,%esp
    struct proc* oldprocess;
    oldprocess = unqueue(level);
80105177:	ff 75 08             	pushl  0x8(%ebp)
8010517a:	e8 08 f4 ff ff       	call   80104587 <unqueue>
8010517f:	83 c4 04             	add    $0x4,%esp
80105182:	89 45 fc             	mov    %eax,-0x4(%ebp)
    if(oldprocess){
80105185:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
80105189:	74 1b                	je     801051a6 <raisepriority+0x35>
      oldprocess->priority = level-1;
8010518b:	8b 45 08             	mov    0x8(%ebp),%eax
8010518e:	8d 50 ff             	lea    -0x1(%eax),%edx
80105191:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105194:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      makerunnable(oldprocess);
8010519b:	ff 75 fc             	pushl  -0x4(%ebp)
8010519e:	e8 56 f3 ff ff       	call   801044f9 <makerunnable>
801051a3:	83 c4 04             	add    $0x4,%esp
    }
}
801051a6:	90                   	nop
801051a7:	c9                   	leave  
801051a8:	c3                   	ret    

801051a9 <aging>:


void
aging()
{
801051a9:	55                   	push   %ebp
801051aa:	89 e5                	mov    %esp,%ebp
801051ac:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int level;
  acquire(&ptable.lock);
801051af:	83 ec 0c             	sub    $0xc,%esp
801051b2:	68 80 39 11 80       	push   $0x80113980
801051b7:	e8 db 05 00 00       	call   80105797 <acquire>
801051bc:	83 c4 10             	add    $0x10,%esp
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
801051bf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
801051c6:	e9 aa 00 00 00       	jmp    80105275 <aging+0xcc>
    p =ptable.mlf[level];
801051cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801051ce:	05 0c 0a 00 00       	add    $0xa0c,%eax
801051d3:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
801051da:	89 45 f4             	mov    %eax,-0xc(%ebp)
    while(p){
801051dd:	e9 85 00 00 00       	jmp    80105267 <aging+0xbe>
      p->age++;                             // increase the age
801051e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051e5:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
801051ec:	8d 50 01             	lea    0x1(%eax),%edx
801051ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051f2:	66 89 90 86 00 00 00 	mov    %dx,0x86(%eax)
      if( (p->age == AGEFORSCALING && level != MLFMAXLEVEL)){ // check if the process deserves a priority increase
801051f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801051fc:	0f b7 80 86 00 00 00 	movzwl 0x86(%eax),%eax
80105203:	66 83 f8 32          	cmp    $0x32,%ax
80105207:	75 52                	jne    8010525b <aging+0xb2>
80105209:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010520d:	74 4c                	je     8010525b <aging+0xb2>
        procdump();                         //prints the processes BEFORE the priority increase
8010520f:	e8 07 fe ff ff       	call   8010501b <procdump>
        if(ACTIVATEAGING){                 //ACTIVATEAGING value is in param.h !
          raisepriority(level);
80105214:	83 ec 0c             	sub    $0xc,%esp
80105217:	ff 75 f0             	pushl  -0x10(%ebp)
8010521a:	e8 52 ff ff ff       	call   80105171 <raisepriority>
8010521f:	83 c4 10             	add    $0x10,%esp
          cprintf("---------------------------------\n");
80105222:	83 ec 0c             	sub    $0xc,%esp
80105225:	68 f4 91 10 80       	push   $0x801091f4
8010522a:	e8 97 b1 ff ff       	call   801003c6 <cprintf>
8010522f:	83 c4 10             	add    $0x10,%esp
          procdump();                     //prints the processes AFTER the priority increase
80105232:	e8 e4 fd ff ff       	call   8010501b <procdump>
        }
        cprintf("//////////////////////////////////////\n");
80105237:	83 ec 0c             	sub    $0xc,%esp
8010523a:	68 18 92 10 80       	push   $0x80109218
8010523f:	e8 82 b1 ff ff       	call   801003c6 <cprintf>
80105244:	83 c4 10             	add    $0x10,%esp
        p=ptable.mlf[level];              // now will continue with the new first level process
80105247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010524a:	05 0c 0a 00 00       	add    $0xa0c,%eax
8010524f:	8b 04 85 84 39 11 80 	mov    -0x7feec67c(,%eax,4),%eax
80105256:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105259:	eb 0c                	jmp    80105267 <aging+0xbe>
      }else{
        p=p->next;                        //from here only increases the age, because they will be younger
8010525b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010525e:	8b 80 80 00 00 00    	mov    0x80(%eax),%eax
80105264:	89 45 f4             	mov    %eax,-0xc(%ebp)
  struct proc *p;
  int level;
  acquire(&ptable.lock);
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
    p =ptable.mlf[level];
    while(p){
80105267:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010526b:	0f 85 71 ff ff ff    	jne    801051e2 <aging+0x39>
aging()
{
  struct proc *p;
  int level;
  acquire(&ptable.lock);
  for (level=MLFMAXLEVEL; level < MLFLEVELS; level++) { // i go through the levels of the mlf
80105271:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80105275:	83 7d f0 03          	cmpl   $0x3,-0x10(%ebp)
80105279:	0f 8e 4c ff ff ff    	jle    801051cb <aging+0x22>
      }else{
        p=p->next;                        //from here only increases the age, because they will be younger
      }
    }
  }
  release(&ptable.lock);
8010527f:	83 ec 0c             	sub    $0xc,%esp
80105282:	68 80 39 11 80       	push   $0x80113980
80105287:	e8 72 05 00 00       	call   801057fe <release>
8010528c:	83 c4 10             	add    $0x10,%esp
}
8010528f:	90                   	nop
80105290:	c9                   	leave  
80105291:	c3                   	ret    

80105292 <semtableinit>:
} semtable;


void
semtableinit(void)
{
80105292:	55                   	push   %ebp
80105293:	89 e5                	mov    %esp,%ebp
80105295:	83 ec 08             	sub    $0x8,%esp
  initlock(&semtable.lock, "semtable");
80105298:	83 ec 08             	sub    $0x8,%esp
8010529b:	68 6c 92 10 80       	push   $0x8010926c
801052a0:	68 e0 61 11 80       	push   $0x801161e0
801052a5:	e8 cb 04 00 00       	call   80105775 <initlock>
801052aa:	83 c4 10             	add    $0x10,%esp
}
801052ad:	90                   	nop
801052ae:	c9                   	leave  
801052af:	c3                   	ret    

801052b0 <semget>:
int semObtained(int semid);
void printsemaphores();

int
semget(int semid,int initvalue)
{
801052b0:	55                   	push   %ebp
801052b1:	89 e5                	mov    %esp,%ebp
801052b3:	83 ec 18             	sub    $0x18,%esp
  int i;
  struct semaphore* s;
  acquire(&semtable.lock);
801052b6:	83 ec 0c             	sub    $0xc,%esp
801052b9:	68 e0 61 11 80       	push   $0x801161e0
801052be:	e8 d4 04 00 00       	call   80105797 <acquire>
801052c3:	83 c4 10             	add    $0x10,%esp
  s = &semtable.sem[semsearch(semid)];
801052c6:	83 ec 0c             	sub    $0xc,%esp
801052c9:	ff 75 08             	pushl  0x8(%ebp)
801052cc:	e8 e8 02 00 00       	call   801055b9 <semsearch>
801052d1:	83 c4 10             	add    $0x10,%esp
801052d4:	89 c2                	mov    %eax,%edx
801052d6:	89 d0                	mov    %edx,%eax
801052d8:	01 c0                	add    %eax,%eax
801052da:	01 d0                	add    %edx,%eax
801052dc:	c1 e0 02             	shl    $0x2,%eax
801052df:	83 c0 30             	add    $0x30,%eax
801052e2:	05 e0 61 11 80       	add    $0x801161e0,%eax
801052e7:	83 c0 04             	add    $0x4,%eax
801052ea:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(semid>=0 && s->counter==0){
801052ed:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801052f1:	78 14                	js     80105307 <semget+0x57>
801052f3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801052f6:	8b 40 04             	mov    0x4(%eax),%eax
801052f9:	85 c0                	test   %eax,%eax
801052fb:	75 0a                	jne    80105307 <semget+0x57>
    return -1;    //el semaforo no esta en uso
801052fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105302:	e9 ac 00 00 00       	jmp    801053b3 <semget+0x103>
  }


  if(semid == -1){
80105307:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
8010530b:	75 34                	jne    80105341 <semget+0x91>
        s->id=s-semtable.sem;
8010530d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105310:	ba 14 62 11 80       	mov    $0x80116214,%edx
80105315:	29 d0                	sub    %edx,%eax
80105317:	c1 f8 02             	sar    $0x2,%eax
8010531a:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
80105320:	89 c2                	mov    %eax,%edx
80105322:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105325:	89 10                	mov    %edx,(%eax)
        s->counter++;
80105327:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010532a:	8b 40 04             	mov    0x4(%eax),%eax
8010532d:	8d 50 01             	lea    0x1(%eax),%edx
80105330:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105333:	89 50 04             	mov    %edx,0x4(%eax)
        s->value = initvalue;
80105336:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105339:	8b 55 0c             	mov    0xc(%ebp),%edx
8010533c:	89 50 08             	mov    %edx,0x8(%eax)
8010533f:	eb 0f                	jmp    80105350 <semget+0xa0>
  }else{
    s->counter++;
80105341:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105344:	8b 40 04             	mov    0x4(%eax),%eax
80105347:	8d 50 01             	lea    0x1(%eax),%edx
8010534a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010534d:	89 50 04             	mov    %edx,0x4(%eax)
  }

  for(i=0;i<MAXPROCSEM;i++){
80105350:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80105357:	eb 2d                	jmp    80105386 <semget+0xd6>
    if(proc->osemaphore[i]==0){
80105359:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010535f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105362:	83 c2 20             	add    $0x20,%edx
80105365:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105369:	85 c0                	test   %eax,%eax
8010536b:	75 15                	jne    80105382 <semget+0xd2>
      proc->osemaphore[i]=s;
8010536d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105373:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105376:	8d 4a 20             	lea    0x20(%edx),%ecx
80105379:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010537c:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
      break;
80105380:	eb 0a                	jmp    8010538c <semget+0xdc>
        s->value = initvalue;
  }else{
    s->counter++;
  }

  for(i=0;i<MAXPROCSEM;i++){
80105382:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105386:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010538a:	7e cd                	jle    80105359 <semget+0xa9>
    if(proc->osemaphore[i]==0){
      proc->osemaphore[i]=s;
      break;
    }
  }
  printsemaphores();
8010538c:	e8 35 03 00 00       	call   801056c6 <printsemaphores>

  if(i==MAXPROCSEM){
80105391:	83 7d f4 05          	cmpl   $0x5,-0xc(%ebp)
80105395:	75 07                	jne    8010539e <semget+0xee>
    return -2;
80105397:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
8010539c:	eb 15                	jmp    801053b3 <semget+0x103>
  }
  release(&semtable.lock);
8010539e:	83 ec 0c             	sub    $0xc,%esp
801053a1:	68 e0 61 11 80       	push   $0x801161e0
801053a6:	e8 53 04 00 00       	call   801057fe <release>
801053ab:	83 c4 10             	add    $0x10,%esp
  return s->id;
801053ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
801053b1:	8b 00                	mov    (%eax),%eax
}
801053b3:	c9                   	leave  
801053b4:	c3                   	ret    

801053b5 <semfree>:

int
semfree(int semid)
{
801053b5:	55                   	push   %ebp
801053b6:	89 e5                	mov    %esp,%ebp
801053b8:	83 ec 18             	sub    $0x18,%esp

  struct semaphore * s;
  int indexofsem;
  acquire(&semtable.lock);
801053bb:	83 ec 0c             	sub    $0xc,%esp
801053be:	68 e0 61 11 80       	push   $0x801161e0
801053c3:	e8 cf 03 00 00       	call   80105797 <acquire>
801053c8:	83 c4 10             	add    $0x10,%esp
  indexofsem = semObtained(semid);
801053cb:	83 ec 0c             	sub    $0xc,%esp
801053ce:	ff 75 08             	pushl  0x8(%ebp)
801053d1:	e8 4f 02 00 00       	call   80105625 <semObtained>
801053d6:	83 c4 10             	add    $0x10,%esp
801053d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(indexofsem==-1){
801053dc:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
801053e0:	75 17                	jne    801053f9 <semfree+0x44>
    release(&semtable.lock);
801053e2:	83 ec 0c             	sub    $0xc,%esp
801053e5:	68 e0 61 11 80       	push   $0x801161e0
801053ea:	e8 0f 04 00 00       	call   801057fe <release>
801053ef:	83 c4 10             	add    $0x10,%esp
    return -1;
801053f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053f7:	eb 4b                	jmp    80105444 <semfree+0x8f>
  }
  s=proc->osemaphore[indexofsem];
801053f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801053ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105402:	83 c2 20             	add    $0x20,%edx
80105405:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105409:	89 45 f0             	mov    %eax,-0x10(%ebp)
  s->counter--;
8010540c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010540f:	8b 40 04             	mov    0x4(%eax),%eax
80105412:	8d 50 ff             	lea    -0x1(%eax),%edx
80105415:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105418:	89 50 04             	mov    %edx,0x4(%eax)
  release(&semtable.lock);
8010541b:	83 ec 0c             	sub    $0xc,%esp
8010541e:	68 e0 61 11 80       	push   $0x801161e0
80105423:	e8 d6 03 00 00       	call   801057fe <release>
80105428:	83 c4 10             	add    $0x10,%esp
  proc->osemaphore[indexofsem]=0;
8010542b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105431:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105434:	83 c2 20             	add    $0x20,%edx
80105437:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
8010543e:	00 


  return 0;
8010543f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105444:	c9                   	leave  
80105445:	c3                   	ret    

80105446 <semdown>:

int
semdown(int semid)
{
80105446:	55                   	push   %ebp
80105447:	89 e5                	mov    %esp,%ebp
80105449:	83 ec 18             	sub    $0x18,%esp
  struct semaphore * s;
  int indexofsem;

  acquire(&semtable.lock);
8010544c:	83 ec 0c             	sub    $0xc,%esp
8010544f:	68 e0 61 11 80       	push   $0x801161e0
80105454:	e8 3e 03 00 00       	call   80105797 <acquire>
80105459:	83 c4 10             	add    $0x10,%esp
  indexofsem=semObtained(semid);
8010545c:	83 ec 0c             	sub    $0xc,%esp
8010545f:	ff 75 08             	pushl  0x8(%ebp)
80105462:	e8 be 01 00 00       	call   80105625 <semObtained>
80105467:	83 c4 10             	add    $0x10,%esp
8010546a:	89 45 f4             	mov    %eax,-0xc(%ebp)

  if(indexofsem==-1){
8010546d:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105471:	75 0a                	jne    8010547d <semdown+0x37>
    return -1;
80105473:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105478:	e9 af 00 00 00       	jmp    8010552c <semdown+0xe6>
  }
  s=proc->osemaphore[indexofsem];
8010547d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105483:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105486:	83 c2 20             	add    $0x20,%edx
80105489:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010548d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  cprintf("intentando agarrar semaforo %d\n",s->id);
80105490:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105493:	8b 00                	mov    (%eax),%eax
80105495:	83 ec 08             	sub    $0x8,%esp
80105498:	50                   	push   %eax
80105499:	68 78 92 10 80       	push   $0x80109278
8010549e:	e8 23 af ff ff       	call   801003c6 <cprintf>
801054a3:	83 c4 10             	add    $0x10,%esp
  while (s->value<=0){
801054a6:	eb 29                	jmp    801054d1 <semdown+0x8b>
     cprintf("a dormir! semafoto= %d\n",s->id);
801054a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ab:	8b 00                	mov    (%eax),%eax
801054ad:	83 ec 08             	sub    $0x8,%esp
801054b0:	50                   	push   %eax
801054b1:	68 98 92 10 80       	push   $0x80109298
801054b6:	e8 0b af ff ff       	call   801003c6 <cprintf>
801054bb:	83 c4 10             	add    $0x10,%esp
      sleep(s,&semtable.lock);
801054be:	83 ec 08             	sub    $0x8,%esp
801054c1:	68 e0 61 11 80       	push   $0x801161e0
801054c6:	ff 75 f0             	pushl  -0x10(%ebp)
801054c9:	e8 76 f9 ff ff       	call   80104e44 <sleep>
801054ce:	83 c4 10             	add    $0x10,%esp
  if(indexofsem==-1){
    return -1;
  }
  s=proc->osemaphore[indexofsem];
  cprintf("intentando agarrar semaforo %d\n",s->id);
  while (s->value<=0){
801054d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054d4:	8b 40 08             	mov    0x8(%eax),%eax
801054d7:	85 c0                	test   %eax,%eax
801054d9:	7e cd                	jle    801054a8 <semdown+0x62>
     cprintf("a dormir! semafoto= %d\n",s->id);
      sleep(s,&semtable.lock);
  }
  s->value--;
801054db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054de:	8b 40 08             	mov    0x8(%eax),%eax
801054e1:	8d 50 ff             	lea    -0x1(%eax),%edx
801054e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054e7:	89 50 08             	mov    %edx,0x8(%eax)
  cprintf("semdown! id %d\n",s->id );
801054ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
801054ed:	8b 00                	mov    (%eax),%eax
801054ef:	83 ec 08             	sub    $0x8,%esp
801054f2:	50                   	push   %eax
801054f3:	68 b0 92 10 80       	push   $0x801092b0
801054f8:	e8 c9 ae ff ff       	call   801003c6 <cprintf>
801054fd:	83 c4 10             	add    $0x10,%esp
  cprintf("termino el ciclo del semdown, semvalue = %d\n",s->value);
80105500:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105503:	8b 40 08             	mov    0x8(%eax),%eax
80105506:	83 ec 08             	sub    $0x8,%esp
80105509:	50                   	push   %eax
8010550a:	68 c0 92 10 80       	push   $0x801092c0
8010550f:	e8 b2 ae ff ff       	call   801003c6 <cprintf>
80105514:	83 c4 10             	add    $0x10,%esp
  release(&semtable.lock);
80105517:	83 ec 0c             	sub    $0xc,%esp
8010551a:	68 e0 61 11 80       	push   $0x801161e0
8010551f:	e8 da 02 00 00       	call   801057fe <release>
80105524:	83 c4 10             	add    $0x10,%esp
  return 0;
80105527:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010552c:	c9                   	leave  
8010552d:	c3                   	ret    

8010552e <semup>:

int
semup(int semid)
{
8010552e:	55                   	push   %ebp
8010552f:	89 e5                	mov    %esp,%ebp
80105531:	83 ec 18             	sub    $0x18,%esp
  struct semaphore * s;
  int indexofsem;
  acquire(&semtable.lock);
80105534:	83 ec 0c             	sub    $0xc,%esp
80105537:	68 e0 61 11 80       	push   $0x801161e0
8010553c:	e8 56 02 00 00       	call   80105797 <acquire>
80105541:	83 c4 10             	add    $0x10,%esp
  indexofsem=semObtained(semid);
80105544:	83 ec 0c             	sub    $0xc,%esp
80105547:	ff 75 08             	pushl  0x8(%ebp)
8010554a:	e8 d6 00 00 00       	call   80105625 <semObtained>
8010554f:	83 c4 10             	add    $0x10,%esp
80105552:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(indexofsem!=-1){
80105555:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
80105559:	74 47                	je     801055a2 <semup+0x74>
    s=proc->osemaphore[indexofsem];
8010555b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105561:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105564:	83 c2 20             	add    $0x20,%edx
80105567:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
8010556b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    s->value++;
8010556e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105571:	8b 40 08             	mov    0x8(%eax),%eax
80105574:	8d 50 01             	lea    0x1(%eax),%edx
80105577:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010557a:	89 50 08             	mov    %edx,0x8(%eax)
    wakeup(s);
8010557d:	83 ec 0c             	sub    $0xc,%esp
80105580:	ff 75 f0             	pushl  -0x10(%ebp)
80105583:	e8 d1 f9 ff ff       	call   80104f59 <wakeup>
80105588:	83 c4 10             	add    $0x10,%esp
    release(&semtable.lock);
8010558b:	83 ec 0c             	sub    $0xc,%esp
8010558e:	68 e0 61 11 80       	push   $0x801161e0
80105593:	e8 66 02 00 00       	call   801057fe <release>
80105598:	83 c4 10             	add    $0x10,%esp
    return 0;
8010559b:	b8 00 00 00 00       	mov    $0x0,%eax
801055a0:	eb 15                	jmp    801055b7 <semup+0x89>
  }else{
    release(&semtable.lock);
801055a2:	83 ec 0c             	sub    $0xc,%esp
801055a5:	68 e0 61 11 80       	push   $0x801161e0
801055aa:	e8 4f 02 00 00       	call   801057fe <release>
801055af:	83 c4 10             	add    $0x10,%esp
    return -1;
801055b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
}
801055b7:	c9                   	leave  
801055b8:	c3                   	ret    

801055b9 <semsearch>:

//returns of the semaphore in the table.
// If the id is -1, then it returns a pointer to the first unused semaphoro (counter 0)
//return -2 if there are no more semaphore available
int
semsearch(int semid){
801055b9:	55                   	push   %ebp
801055ba:	89 e5                	mov    %esp,%ebp
801055bc:	83 ec 10             	sub    $0x10,%esp

  int i;
  for(i=0; i < MAXSEM; i++){
801055bf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801055c6:	eb 43                	jmp    8010560b <semsearch+0x52>
    if(semtable.sem[i].id==semid){
801055c8:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055cb:	89 d0                	mov    %edx,%eax
801055cd:	01 c0                	add    %eax,%eax
801055cf:	01 d0                	add    %edx,%eax
801055d1:	c1 e0 02             	shl    $0x2,%eax
801055d4:	05 14 62 11 80       	add    $0x80116214,%eax
801055d9:	8b 00                	mov    (%eax),%eax
801055db:	3b 45 08             	cmp    0x8(%ebp),%eax
801055de:	75 05                	jne    801055e5 <semsearch+0x2c>
      return i;
801055e0:	8b 45 fc             	mov    -0x4(%ebp),%eax
801055e3:	eb 3e                	jmp    80105623 <semsearch+0x6a>
    }
    if(semid==-1 && semtable.sem[i].counter==0){
801055e5:	83 7d 08 ff          	cmpl   $0xffffffff,0x8(%ebp)
801055e9:	75 1c                	jne    80105607 <semsearch+0x4e>
801055eb:	8b 55 fc             	mov    -0x4(%ebp),%edx
801055ee:	89 d0                	mov    %edx,%eax
801055f0:	01 c0                	add    %eax,%eax
801055f2:	01 d0                	add    %edx,%eax
801055f4:	c1 e0 02             	shl    $0x2,%eax
801055f7:	05 18 62 11 80       	add    $0x80116218,%eax
801055fc:	8b 00                	mov    (%eax),%eax
801055fe:	85 c0                	test   %eax,%eax
80105600:	75 05                	jne    80105607 <semsearch+0x4e>
      return i;
80105602:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105605:	eb 1c                	jmp    80105623 <semsearch+0x6a>
//return -2 if there are no more semaphore available
int
semsearch(int semid){

  int i;
  for(i=0; i < MAXSEM; i++){
80105607:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010560b:	83 7d fc 13          	cmpl   $0x13,-0x4(%ebp)
8010560f:	7e b7                	jle    801055c8 <semsearch+0xf>
    }
    if(semid==-1 && semtable.sem[i].counter==0){
      return i;
    }
  }
  if(semid<0){
80105611:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80105615:	79 07                	jns    8010561e <semsearch+0x65>
    return -2;  //not avaible semaphores
80105617:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
8010561c:	eb 05                	jmp    80105623 <semsearch+0x6a>
  }
  return -1;
8010561e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105623:	c9                   	leave  
80105624:	c3                   	ret    

80105625 <semObtained>:

//Check if the semaphore belongs to the current process
//returns the position in the semaphore arrangement of the process or -1 if it was not found
int
semObtained(int semid){
80105625:	55                   	push   %ebp
80105626:	89 e5                	mov    %esp,%ebp
80105628:	83 ec 10             	sub    $0x10,%esp
  int i;
  for(i=0;i<MAXPROCSEM;i++){
8010562b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105632:	eb 34                	jmp    80105668 <semObtained+0x43>
    if(proc->osemaphore[i]!=0&&proc->osemaphore[i]->id==semid){
80105634:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010563a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010563d:	83 c2 20             	add    $0x20,%edx
80105640:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105644:	85 c0                	test   %eax,%eax
80105646:	74 1c                	je     80105664 <semObtained+0x3f>
80105648:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010564e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105651:	83 c2 20             	add    $0x20,%edx
80105654:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105658:	8b 00                	mov    (%eax),%eax
8010565a:	3b 45 08             	cmp    0x8(%ebp),%eax
8010565d:	75 05                	jne    80105664 <semObtained+0x3f>
      return i;
8010565f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105662:	eb 0f                	jmp    80105673 <semObtained+0x4e>
//Check if the semaphore belongs to the current process
//returns the position in the semaphore arrangement of the process or -1 if it was not found
int
semObtained(int semid){
  int i;
  for(i=0;i<MAXPROCSEM;i++){
80105664:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105668:	83 7d fc 04          	cmpl   $0x4,-0x4(%ebp)
8010566c:	7e c6                	jle    80105634 <semObtained+0xf>
      return i;
    }
  }


    return -1;
8010566e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax

}
80105673:	c9                   	leave  
80105674:	c3                   	ret    

80105675 <semaphoredup>:

struct semaphore*
semaphoredup(struct semaphore* s){
80105675:	55                   	push   %ebp
80105676:	89 e5                	mov    %esp,%ebp
80105678:	83 ec 08             	sub    $0x8,%esp
  acquire(&semtable.lock);
8010567b:	83 ec 0c             	sub    $0xc,%esp
8010567e:	68 e0 61 11 80       	push   $0x801161e0
80105683:	e8 0f 01 00 00       	call   80105797 <acquire>
80105688:	83 c4 10             	add    $0x10,%esp
  if(s->counter<0){
8010568b:	8b 45 08             	mov    0x8(%ebp),%eax
8010568e:	8b 40 04             	mov    0x4(%eax),%eax
80105691:	85 c0                	test   %eax,%eax
80105693:	79 0d                	jns    801056a2 <semaphoredup+0x2d>
    panic("error al duplicar el semaforo");
80105695:	83 ec 0c             	sub    $0xc,%esp
80105698:	68 ed 92 10 80       	push   $0x801092ed
8010569d:	e8 c4 ae ff ff       	call   80100566 <panic>
  }
  s->counter++;
801056a2:	8b 45 08             	mov    0x8(%ebp),%eax
801056a5:	8b 40 04             	mov    0x4(%eax),%eax
801056a8:	8d 50 01             	lea    0x1(%eax),%edx
801056ab:	8b 45 08             	mov    0x8(%ebp),%eax
801056ae:	89 50 04             	mov    %edx,0x4(%eax)
  release(&semtable.lock);
801056b1:	83 ec 0c             	sub    $0xc,%esp
801056b4:	68 e0 61 11 80       	push   $0x801161e0
801056b9:	e8 40 01 00 00       	call   801057fe <release>
801056be:	83 c4 10             	add    $0x10,%esp
  return s;
801056c1:	8b 45 08             	mov    0x8(%ebp),%eax
}
801056c4:	c9                   	leave  
801056c5:	c3                   	ret    

801056c6 <printsemaphores>:


void
printsemaphores()
{
801056c6:	55                   	push   %ebp
801056c7:	89 e5                	mov    %esp,%ebp
801056c9:	83 ec 18             	sub    $0x18,%esp
  cprintf("SEMAFOROS DEL PROCESO!!!\n");
801056cc:	83 ec 0c             	sub    $0xc,%esp
801056cf:	68 0b 93 10 80       	push   $0x8010930b
801056d4:	e8 ed ac ff ff       	call   801003c6 <cprintf>
801056d9:	83 c4 10             	add    $0x10,%esp
  int i;
  for(i=0;i<MAXPROCSEM;i++){
801056dc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801056e3:	eb 4f                	jmp    80105734 <printsemaphores+0x6e>
    if(proc->osemaphore[i]!=0){
801056e5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
801056ee:	83 c2 20             	add    $0x20,%edx
801056f1:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
801056f5:	85 c0                	test   %eax,%eax
801056f7:	74 37                	je     80105730 <printsemaphores+0x6a>
      cprintf("semaforo id=%d value=%d\n",proc->osemaphore[i]->id,proc->osemaphore[i]->value);
801056f9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105702:	83 c2 20             	add    $0x20,%edx
80105705:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80105709:	8b 50 08             	mov    0x8(%eax),%edx
8010570c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105712:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80105715:	83 c1 20             	add    $0x20,%ecx
80105718:	8b 44 88 0c          	mov    0xc(%eax,%ecx,4),%eax
8010571c:	8b 00                	mov    (%eax),%eax
8010571e:	83 ec 04             	sub    $0x4,%esp
80105721:	52                   	push   %edx
80105722:	50                   	push   %eax
80105723:	68 25 93 10 80       	push   $0x80109325
80105728:	e8 99 ac ff ff       	call   801003c6 <cprintf>
8010572d:	83 c4 10             	add    $0x10,%esp
void
printsemaphores()
{
  cprintf("SEMAFOROS DEL PROCESO!!!\n");
  int i;
  for(i=0;i<MAXPROCSEM;i++){
80105730:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105734:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
80105738:	7e ab                	jle    801056e5 <printsemaphores+0x1f>
  }




}
8010573a:	90                   	nop
8010573b:	c9                   	leave  
8010573c:	c3                   	ret    

8010573d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010573d:	55                   	push   %ebp
8010573e:	89 e5                	mov    %esp,%ebp
80105740:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105743:	9c                   	pushf  
80105744:	58                   	pop    %eax
80105745:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105748:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010574b:	c9                   	leave  
8010574c:	c3                   	ret    

8010574d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010574d:	55                   	push   %ebp
8010574e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105750:	fa                   	cli    
}
80105751:	90                   	nop
80105752:	5d                   	pop    %ebp
80105753:	c3                   	ret    

80105754 <sti>:

static inline void
sti(void)
{
80105754:	55                   	push   %ebp
80105755:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105757:	fb                   	sti    
}
80105758:	90                   	nop
80105759:	5d                   	pop    %ebp
8010575a:	c3                   	ret    

8010575b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010575b:	55                   	push   %ebp
8010575c:	89 e5                	mov    %esp,%ebp
8010575e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105761:	8b 55 08             	mov    0x8(%ebp),%edx
80105764:	8b 45 0c             	mov    0xc(%ebp),%eax
80105767:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010576a:	f0 87 02             	lock xchg %eax,(%edx)
8010576d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105770:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105773:	c9                   	leave  
80105774:	c3                   	ret    

80105775 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105775:	55                   	push   %ebp
80105776:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105778:	8b 45 08             	mov    0x8(%ebp),%eax
8010577b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010577e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105781:	8b 45 08             	mov    0x8(%ebp),%eax
80105784:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010578a:	8b 45 08             	mov    0x8(%ebp),%eax
8010578d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80105794:	90                   	nop
80105795:	5d                   	pop    %ebp
80105796:	c3                   	ret    

80105797 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
80105797:	55                   	push   %ebp
80105798:	89 e5                	mov    %esp,%ebp
8010579a:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
8010579d:	e8 52 01 00 00       	call   801058f4 <pushcli>
  if(holding(lk))
801057a2:	8b 45 08             	mov    0x8(%ebp),%eax
801057a5:	83 ec 0c             	sub    $0xc,%esp
801057a8:	50                   	push   %eax
801057a9:	e8 1c 01 00 00       	call   801058ca <holding>
801057ae:	83 c4 10             	add    $0x10,%esp
801057b1:	85 c0                	test   %eax,%eax
801057b3:	74 0d                	je     801057c2 <acquire+0x2b>
    panic("acquire");
801057b5:	83 ec 0c             	sub    $0xc,%esp
801057b8:	68 3e 93 10 80       	push   $0x8010933e
801057bd:	e8 a4 ad ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801057c2:	90                   	nop
801057c3:	8b 45 08             	mov    0x8(%ebp),%eax
801057c6:	83 ec 08             	sub    $0x8,%esp
801057c9:	6a 01                	push   $0x1
801057cb:	50                   	push   %eax
801057cc:	e8 8a ff ff ff       	call   8010575b <xchg>
801057d1:	83 c4 10             	add    $0x10,%esp
801057d4:	85 c0                	test   %eax,%eax
801057d6:	75 eb                	jne    801057c3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801057d8:	8b 45 08             	mov    0x8(%ebp),%eax
801057db:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801057e2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801057e5:	8b 45 08             	mov    0x8(%ebp),%eax
801057e8:	83 c0 0c             	add    $0xc,%eax
801057eb:	83 ec 08             	sub    $0x8,%esp
801057ee:	50                   	push   %eax
801057ef:	8d 45 08             	lea    0x8(%ebp),%eax
801057f2:	50                   	push   %eax
801057f3:	e8 58 00 00 00       	call   80105850 <getcallerpcs>
801057f8:	83 c4 10             	add    $0x10,%esp
}
801057fb:	90                   	nop
801057fc:	c9                   	leave  
801057fd:	c3                   	ret    

801057fe <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
801057fe:	55                   	push   %ebp
801057ff:	89 e5                	mov    %esp,%ebp
80105801:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105804:	83 ec 0c             	sub    $0xc,%esp
80105807:	ff 75 08             	pushl  0x8(%ebp)
8010580a:	e8 bb 00 00 00       	call   801058ca <holding>
8010580f:	83 c4 10             	add    $0x10,%esp
80105812:	85 c0                	test   %eax,%eax
80105814:	75 0d                	jne    80105823 <release+0x25>
    panic("release");
80105816:	83 ec 0c             	sub    $0xc,%esp
80105819:	68 46 93 10 80       	push   $0x80109346
8010581e:	e8 43 ad ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105823:	8b 45 08             	mov    0x8(%ebp),%eax
80105826:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010582d:	8b 45 08             	mov    0x8(%ebp),%eax
80105830:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105837:	8b 45 08             	mov    0x8(%ebp),%eax
8010583a:	83 ec 08             	sub    $0x8,%esp
8010583d:	6a 00                	push   $0x0
8010583f:	50                   	push   %eax
80105840:	e8 16 ff ff ff       	call   8010575b <xchg>
80105845:	83 c4 10             	add    $0x10,%esp

  popcli();
80105848:	e8 ec 00 00 00       	call   80105939 <popcli>
}
8010584d:	90                   	nop
8010584e:	c9                   	leave  
8010584f:	c3                   	ret    

80105850 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105850:	55                   	push   %ebp
80105851:	89 e5                	mov    %esp,%ebp
80105853:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105856:	8b 45 08             	mov    0x8(%ebp),%eax
80105859:	83 e8 08             	sub    $0x8,%eax
8010585c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010585f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105866:	eb 38                	jmp    801058a0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105868:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010586c:	74 53                	je     801058c1 <getcallerpcs+0x71>
8010586e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105875:	76 4a                	jbe    801058c1 <getcallerpcs+0x71>
80105877:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010587b:	74 44                	je     801058c1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010587d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105880:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105887:	8b 45 0c             	mov    0xc(%ebp),%eax
8010588a:	01 c2                	add    %eax,%edx
8010588c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010588f:	8b 40 04             	mov    0x4(%eax),%eax
80105892:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
80105894:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105897:	8b 00                	mov    (%eax),%eax
80105899:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
8010589c:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058a0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058a4:	7e c2                	jle    80105868 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058a6:	eb 19                	jmp    801058c1 <getcallerpcs+0x71>
    pcs[i] = 0;
801058a8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801058ab:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801058b2:	8b 45 0c             	mov    0xc(%ebp),%eax
801058b5:	01 d0                	add    %edx,%eax
801058b7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801058bd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801058c1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801058c5:	7e e1                	jle    801058a8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801058c7:	90                   	nop
801058c8:	c9                   	leave  
801058c9:	c3                   	ret    

801058ca <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801058ca:	55                   	push   %ebp
801058cb:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801058cd:	8b 45 08             	mov    0x8(%ebp),%eax
801058d0:	8b 00                	mov    (%eax),%eax
801058d2:	85 c0                	test   %eax,%eax
801058d4:	74 17                	je     801058ed <holding+0x23>
801058d6:	8b 45 08             	mov    0x8(%ebp),%eax
801058d9:	8b 50 08             	mov    0x8(%eax),%edx
801058dc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801058e2:	39 c2                	cmp    %eax,%edx
801058e4:	75 07                	jne    801058ed <holding+0x23>
801058e6:	b8 01 00 00 00       	mov    $0x1,%eax
801058eb:	eb 05                	jmp    801058f2 <holding+0x28>
801058ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058f2:	5d                   	pop    %ebp
801058f3:	c3                   	ret    

801058f4 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
801058f4:	55                   	push   %ebp
801058f5:	89 e5                	mov    %esp,%ebp
801058f7:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
801058fa:	e8 3e fe ff ff       	call   8010573d <readeflags>
801058ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105902:	e8 46 fe ff ff       	call   8010574d <cli>
  if(cpu->ncli++ == 0)
80105907:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010590e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105914:	8d 48 01             	lea    0x1(%eax),%ecx
80105917:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010591d:	85 c0                	test   %eax,%eax
8010591f:	75 15                	jne    80105936 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105921:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105927:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010592a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105930:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105936:	90                   	nop
80105937:	c9                   	leave  
80105938:	c3                   	ret    

80105939 <popcli>:

void
popcli(void)
{
80105939:	55                   	push   %ebp
8010593a:	89 e5                	mov    %esp,%ebp
8010593c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010593f:	e8 f9 fd ff ff       	call   8010573d <readeflags>
80105944:	25 00 02 00 00       	and    $0x200,%eax
80105949:	85 c0                	test   %eax,%eax
8010594b:	74 0d                	je     8010595a <popcli+0x21>
    panic("popcli - interruptible");
8010594d:	83 ec 0c             	sub    $0xc,%esp
80105950:	68 4e 93 10 80       	push   $0x8010934e
80105955:	e8 0c ac ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010595a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105960:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105966:	83 ea 01             	sub    $0x1,%edx
80105969:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010596f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105975:	85 c0                	test   %eax,%eax
80105977:	79 0d                	jns    80105986 <popcli+0x4d>
    panic("popcli");
80105979:	83 ec 0c             	sub    $0xc,%esp
8010597c:	68 65 93 10 80       	push   $0x80109365
80105981:	e8 e0 ab ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105986:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010598c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105992:	85 c0                	test   %eax,%eax
80105994:	75 15                	jne    801059ab <popcli+0x72>
80105996:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010599c:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801059a2:	85 c0                	test   %eax,%eax
801059a4:	74 05                	je     801059ab <popcli+0x72>
    sti();
801059a6:	e8 a9 fd ff ff       	call   80105754 <sti>
}
801059ab:	90                   	nop
801059ac:	c9                   	leave  
801059ad:	c3                   	ret    

801059ae <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801059ae:	55                   	push   %ebp
801059af:	89 e5                	mov    %esp,%ebp
801059b1:	57                   	push   %edi
801059b2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801059b3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059b6:	8b 55 10             	mov    0x10(%ebp),%edx
801059b9:	8b 45 0c             	mov    0xc(%ebp),%eax
801059bc:	89 cb                	mov    %ecx,%ebx
801059be:	89 df                	mov    %ebx,%edi
801059c0:	89 d1                	mov    %edx,%ecx
801059c2:	fc                   	cld    
801059c3:	f3 aa                	rep stos %al,%es:(%edi)
801059c5:	89 ca                	mov    %ecx,%edx
801059c7:	89 fb                	mov    %edi,%ebx
801059c9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801059cc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801059cf:	90                   	nop
801059d0:	5b                   	pop    %ebx
801059d1:	5f                   	pop    %edi
801059d2:	5d                   	pop    %ebp
801059d3:	c3                   	ret    

801059d4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801059d4:	55                   	push   %ebp
801059d5:	89 e5                	mov    %esp,%ebp
801059d7:	57                   	push   %edi
801059d8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801059d9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801059dc:	8b 55 10             	mov    0x10(%ebp),%edx
801059df:	8b 45 0c             	mov    0xc(%ebp),%eax
801059e2:	89 cb                	mov    %ecx,%ebx
801059e4:	89 df                	mov    %ebx,%edi
801059e6:	89 d1                	mov    %edx,%ecx
801059e8:	fc                   	cld    
801059e9:	f3 ab                	rep stos %eax,%es:(%edi)
801059eb:	89 ca                	mov    %ecx,%edx
801059ed:	89 fb                	mov    %edi,%ebx
801059ef:	89 5d 08             	mov    %ebx,0x8(%ebp)
801059f2:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801059f5:	90                   	nop
801059f6:	5b                   	pop    %ebx
801059f7:	5f                   	pop    %edi
801059f8:	5d                   	pop    %ebp
801059f9:	c3                   	ret    

801059fa <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
801059fa:	55                   	push   %ebp
801059fb:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
801059fd:	8b 45 08             	mov    0x8(%ebp),%eax
80105a00:	83 e0 03             	and    $0x3,%eax
80105a03:	85 c0                	test   %eax,%eax
80105a05:	75 43                	jne    80105a4a <memset+0x50>
80105a07:	8b 45 10             	mov    0x10(%ebp),%eax
80105a0a:	83 e0 03             	and    $0x3,%eax
80105a0d:	85 c0                	test   %eax,%eax
80105a0f:	75 39                	jne    80105a4a <memset+0x50>
    c &= 0xFF;
80105a11:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105a18:	8b 45 10             	mov    0x10(%ebp),%eax
80105a1b:	c1 e8 02             	shr    $0x2,%eax
80105a1e:	89 c1                	mov    %eax,%ecx
80105a20:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a23:	c1 e0 18             	shl    $0x18,%eax
80105a26:	89 c2                	mov    %eax,%edx
80105a28:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a2b:	c1 e0 10             	shl    $0x10,%eax
80105a2e:	09 c2                	or     %eax,%edx
80105a30:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a33:	c1 e0 08             	shl    $0x8,%eax
80105a36:	09 d0                	or     %edx,%eax
80105a38:	0b 45 0c             	or     0xc(%ebp),%eax
80105a3b:	51                   	push   %ecx
80105a3c:	50                   	push   %eax
80105a3d:	ff 75 08             	pushl  0x8(%ebp)
80105a40:	e8 8f ff ff ff       	call   801059d4 <stosl>
80105a45:	83 c4 0c             	add    $0xc,%esp
80105a48:	eb 12                	jmp    80105a5c <memset+0x62>
  } else
    stosb(dst, c, n);
80105a4a:	8b 45 10             	mov    0x10(%ebp),%eax
80105a4d:	50                   	push   %eax
80105a4e:	ff 75 0c             	pushl  0xc(%ebp)
80105a51:	ff 75 08             	pushl  0x8(%ebp)
80105a54:	e8 55 ff ff ff       	call   801059ae <stosb>
80105a59:	83 c4 0c             	add    $0xc,%esp
  return dst;
80105a5c:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105a5f:	c9                   	leave  
80105a60:	c3                   	ret    

80105a61 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105a61:	55                   	push   %ebp
80105a62:	89 e5                	mov    %esp,%ebp
80105a64:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105a67:	8b 45 08             	mov    0x8(%ebp),%eax
80105a6a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
80105a6d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105a70:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105a73:	eb 30                	jmp    80105aa5 <memcmp+0x44>
    if(*s1 != *s2)
80105a75:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a78:	0f b6 10             	movzbl (%eax),%edx
80105a7b:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a7e:	0f b6 00             	movzbl (%eax),%eax
80105a81:	38 c2                	cmp    %al,%dl
80105a83:	74 18                	je     80105a9d <memcmp+0x3c>
      return *s1 - *s2;
80105a85:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105a88:	0f b6 00             	movzbl (%eax),%eax
80105a8b:	0f b6 d0             	movzbl %al,%edx
80105a8e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105a91:	0f b6 00             	movzbl (%eax),%eax
80105a94:	0f b6 c0             	movzbl %al,%eax
80105a97:	29 c2                	sub    %eax,%edx
80105a99:	89 d0                	mov    %edx,%eax
80105a9b:	eb 1a                	jmp    80105ab7 <memcmp+0x56>
    s1++, s2++;
80105a9d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105aa1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80105aa5:	8b 45 10             	mov    0x10(%ebp),%eax
80105aa8:	8d 50 ff             	lea    -0x1(%eax),%edx
80105aab:	89 55 10             	mov    %edx,0x10(%ebp)
80105aae:	85 c0                	test   %eax,%eax
80105ab0:	75 c3                	jne    80105a75 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
80105ab2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ab7:	c9                   	leave  
80105ab8:	c3                   	ret    

80105ab9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80105ab9:	55                   	push   %ebp
80105aba:	89 e5                	mov    %esp,%ebp
80105abc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
80105abf:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ac2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
80105ac5:	8b 45 08             	mov    0x8(%ebp),%eax
80105ac8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
80105acb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105ace:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ad1:	73 54                	jae    80105b27 <memmove+0x6e>
80105ad3:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ad6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ad9:	01 d0                	add    %edx,%eax
80105adb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105ade:	76 47                	jbe    80105b27 <memmove+0x6e>
    s += n;
80105ae0:	8b 45 10             	mov    0x10(%ebp),%eax
80105ae3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
80105ae6:	8b 45 10             	mov    0x10(%ebp),%eax
80105ae9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
80105aec:	eb 13                	jmp    80105b01 <memmove+0x48>
      *--d = *--s;
80105aee:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105af2:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105af6:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105af9:	0f b6 10             	movzbl (%eax),%edx
80105afc:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105aff:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105b01:	8b 45 10             	mov    0x10(%ebp),%eax
80105b04:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b07:	89 55 10             	mov    %edx,0x10(%ebp)
80105b0a:	85 c0                	test   %eax,%eax
80105b0c:	75 e0                	jne    80105aee <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80105b0e:	eb 24                	jmp    80105b34 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105b10:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105b13:	8d 50 01             	lea    0x1(%eax),%edx
80105b16:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105b19:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105b1c:	8d 4a 01             	lea    0x1(%edx),%ecx
80105b1f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105b22:	0f b6 12             	movzbl (%edx),%edx
80105b25:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105b27:	8b 45 10             	mov    0x10(%ebp),%eax
80105b2a:	8d 50 ff             	lea    -0x1(%eax),%edx
80105b2d:	89 55 10             	mov    %edx,0x10(%ebp)
80105b30:	85 c0                	test   %eax,%eax
80105b32:	75 dc                	jne    80105b10 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105b34:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105b37:	c9                   	leave  
80105b38:	c3                   	ret    

80105b39 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105b39:	55                   	push   %ebp
80105b3a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80105b3c:	ff 75 10             	pushl  0x10(%ebp)
80105b3f:	ff 75 0c             	pushl  0xc(%ebp)
80105b42:	ff 75 08             	pushl  0x8(%ebp)
80105b45:	e8 6f ff ff ff       	call   80105ab9 <memmove>
80105b4a:	83 c4 0c             	add    $0xc,%esp
}
80105b4d:	c9                   	leave  
80105b4e:	c3                   	ret    

80105b4f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80105b4f:	55                   	push   %ebp
80105b50:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105b52:	eb 0c                	jmp    80105b60 <strncmp+0x11>
    n--, p++, q++;
80105b54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105b58:	83 45 08 01          	addl   $0x1,0x8(%ebp)
80105b5c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105b60:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b64:	74 1a                	je     80105b80 <strncmp+0x31>
80105b66:	8b 45 08             	mov    0x8(%ebp),%eax
80105b69:	0f b6 00             	movzbl (%eax),%eax
80105b6c:	84 c0                	test   %al,%al
80105b6e:	74 10                	je     80105b80 <strncmp+0x31>
80105b70:	8b 45 08             	mov    0x8(%ebp),%eax
80105b73:	0f b6 10             	movzbl (%eax),%edx
80105b76:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b79:	0f b6 00             	movzbl (%eax),%eax
80105b7c:	38 c2                	cmp    %al,%dl
80105b7e:	74 d4                	je     80105b54 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105b80:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105b84:	75 07                	jne    80105b8d <strncmp+0x3e>
    return 0;
80105b86:	b8 00 00 00 00       	mov    $0x0,%eax
80105b8b:	eb 16                	jmp    80105ba3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
80105b8d:	8b 45 08             	mov    0x8(%ebp),%eax
80105b90:	0f b6 00             	movzbl (%eax),%eax
80105b93:	0f b6 d0             	movzbl %al,%edx
80105b96:	8b 45 0c             	mov    0xc(%ebp),%eax
80105b99:	0f b6 00             	movzbl (%eax),%eax
80105b9c:	0f b6 c0             	movzbl %al,%eax
80105b9f:	29 c2                	sub    %eax,%edx
80105ba1:	89 d0                	mov    %edx,%eax
}
80105ba3:	5d                   	pop    %ebp
80105ba4:	c3                   	ret    

80105ba5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80105ba5:	55                   	push   %ebp
80105ba6:	89 e5                	mov    %esp,%ebp
80105ba8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105bab:	8b 45 08             	mov    0x8(%ebp),%eax
80105bae:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
80105bb1:	90                   	nop
80105bb2:	8b 45 10             	mov    0x10(%ebp),%eax
80105bb5:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bb8:	89 55 10             	mov    %edx,0x10(%ebp)
80105bbb:	85 c0                	test   %eax,%eax
80105bbd:	7e 2c                	jle    80105beb <strncpy+0x46>
80105bbf:	8b 45 08             	mov    0x8(%ebp),%eax
80105bc2:	8d 50 01             	lea    0x1(%eax),%edx
80105bc5:	89 55 08             	mov    %edx,0x8(%ebp)
80105bc8:	8b 55 0c             	mov    0xc(%ebp),%edx
80105bcb:	8d 4a 01             	lea    0x1(%edx),%ecx
80105bce:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105bd1:	0f b6 12             	movzbl (%edx),%edx
80105bd4:	88 10                	mov    %dl,(%eax)
80105bd6:	0f b6 00             	movzbl (%eax),%eax
80105bd9:	84 c0                	test   %al,%al
80105bdb:	75 d5                	jne    80105bb2 <strncpy+0xd>
    ;
  while(n-- > 0)
80105bdd:	eb 0c                	jmp    80105beb <strncpy+0x46>
    *s++ = 0;
80105bdf:	8b 45 08             	mov    0x8(%ebp),%eax
80105be2:	8d 50 01             	lea    0x1(%eax),%edx
80105be5:	89 55 08             	mov    %edx,0x8(%ebp)
80105be8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
80105beb:	8b 45 10             	mov    0x10(%ebp),%eax
80105bee:	8d 50 ff             	lea    -0x1(%eax),%edx
80105bf1:	89 55 10             	mov    %edx,0x10(%ebp)
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	7f e7                	jg     80105bdf <strncpy+0x3a>
    *s++ = 0;
  return os;
80105bf8:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105bfb:	c9                   	leave  
80105bfc:	c3                   	ret    

80105bfd <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80105bfd:	55                   	push   %ebp
80105bfe:	89 e5                	mov    %esp,%ebp
80105c00:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105c03:	8b 45 08             	mov    0x8(%ebp),%eax
80105c06:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105c09:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c0d:	7f 05                	jg     80105c14 <safestrcpy+0x17>
    return os;
80105c0f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105c12:	eb 31                	jmp    80105c45 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105c14:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105c18:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105c1c:	7e 1e                	jle    80105c3c <safestrcpy+0x3f>
80105c1e:	8b 45 08             	mov    0x8(%ebp),%eax
80105c21:	8d 50 01             	lea    0x1(%eax),%edx
80105c24:	89 55 08             	mov    %edx,0x8(%ebp)
80105c27:	8b 55 0c             	mov    0xc(%ebp),%edx
80105c2a:	8d 4a 01             	lea    0x1(%edx),%ecx
80105c2d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105c30:	0f b6 12             	movzbl (%edx),%edx
80105c33:	88 10                	mov    %dl,(%eax)
80105c35:	0f b6 00             	movzbl (%eax),%eax
80105c38:	84 c0                	test   %al,%al
80105c3a:	75 d8                	jne    80105c14 <safestrcpy+0x17>
    ;
  *s = 0;
80105c3c:	8b 45 08             	mov    0x8(%ebp),%eax
80105c3f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105c42:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c45:	c9                   	leave  
80105c46:	c3                   	ret    

80105c47 <strlen>:

int
strlen(const char *s)
{
80105c47:	55                   	push   %ebp
80105c48:	89 e5                	mov    %esp,%ebp
80105c4a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
80105c4d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105c54:	eb 04                	jmp    80105c5a <strlen+0x13>
80105c56:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105c5a:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105c5d:	8b 45 08             	mov    0x8(%ebp),%eax
80105c60:	01 d0                	add    %edx,%eax
80105c62:	0f b6 00             	movzbl (%eax),%eax
80105c65:	84 c0                	test   %al,%al
80105c67:	75 ed                	jne    80105c56 <strlen+0xf>
    ;
  return n;
80105c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105c6c:	c9                   	leave  
80105c6d:	c3                   	ret    

80105c6e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
80105c6e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105c72:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105c76:	55                   	push   %ebp
  pushl %ebx
80105c77:	53                   	push   %ebx
  pushl %esi
80105c78:	56                   	push   %esi
  pushl %edi
80105c79:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80105c7a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80105c7c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
80105c7e:	5f                   	pop    %edi
  popl %esi
80105c7f:	5e                   	pop    %esi
  popl %ebx
80105c80:	5b                   	pop    %ebx
  popl %ebp
80105c81:	5d                   	pop    %ebp
  ret
80105c82:	c3                   	ret    

80105c83 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105c83:	55                   	push   %ebp
80105c84:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105c86:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c8c:	8b 00                	mov    (%eax),%eax
80105c8e:	3b 45 08             	cmp    0x8(%ebp),%eax
80105c91:	76 12                	jbe    80105ca5 <fetchint+0x22>
80105c93:	8b 45 08             	mov    0x8(%ebp),%eax
80105c96:	8d 50 04             	lea    0x4(%eax),%edx
80105c99:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105c9f:	8b 00                	mov    (%eax),%eax
80105ca1:	39 c2                	cmp    %eax,%edx
80105ca3:	76 07                	jbe    80105cac <fetchint+0x29>
    return -1;
80105ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105caa:	eb 0f                	jmp    80105cbb <fetchint+0x38>
  *ip = *(int*)(addr);
80105cac:	8b 45 08             	mov    0x8(%ebp),%eax
80105caf:	8b 10                	mov    (%eax),%edx
80105cb1:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cb4:	89 10                	mov    %edx,(%eax)
  return 0;
80105cb6:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105cbb:	5d                   	pop    %ebp
80105cbc:	c3                   	ret    

80105cbd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80105cbd:	55                   	push   %ebp
80105cbe:	89 e5                	mov    %esp,%ebp
80105cc0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
80105cc3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105cc9:	8b 00                	mov    (%eax),%eax
80105ccb:	3b 45 08             	cmp    0x8(%ebp),%eax
80105cce:	77 07                	ja     80105cd7 <fetchstr+0x1a>
    return -1;
80105cd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105cd5:	eb 46                	jmp    80105d1d <fetchstr+0x60>
  *pp = (char*)addr;
80105cd7:	8b 55 08             	mov    0x8(%ebp),%edx
80105cda:	8b 45 0c             	mov    0xc(%ebp),%eax
80105cdd:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
80105cdf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ce5:	8b 00                	mov    (%eax),%eax
80105ce7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
80105cea:	8b 45 0c             	mov    0xc(%ebp),%eax
80105ced:	8b 00                	mov    (%eax),%eax
80105cef:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105cf2:	eb 1c                	jmp    80105d10 <fetchstr+0x53>
    if(*s == 0)
80105cf4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105cf7:	0f b6 00             	movzbl (%eax),%eax
80105cfa:	84 c0                	test   %al,%al
80105cfc:	75 0e                	jne    80105d0c <fetchstr+0x4f>
      return s - *pp;
80105cfe:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d01:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d04:	8b 00                	mov    (%eax),%eax
80105d06:	29 c2                	sub    %eax,%edx
80105d08:	89 d0                	mov    %edx,%eax
80105d0a:	eb 11                	jmp    80105d1d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
80105d0c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105d10:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d13:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105d16:	72 dc                	jb     80105cf4 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d1d:	c9                   	leave  
80105d1e:	c3                   	ret    

80105d1f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80105d1f:	55                   	push   %ebp
80105d20:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105d22:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d28:	8b 40 18             	mov    0x18(%eax),%eax
80105d2b:	8b 40 44             	mov    0x44(%eax),%eax
80105d2e:	8b 55 08             	mov    0x8(%ebp),%edx
80105d31:	c1 e2 02             	shl    $0x2,%edx
80105d34:	01 d0                	add    %edx,%eax
80105d36:	83 c0 04             	add    $0x4,%eax
80105d39:	ff 75 0c             	pushl  0xc(%ebp)
80105d3c:	50                   	push   %eax
80105d3d:	e8 41 ff ff ff       	call   80105c83 <fetchint>
80105d42:	83 c4 08             	add    $0x8,%esp
}
80105d45:	c9                   	leave  
80105d46:	c3                   	ret    

80105d47 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105d47:	55                   	push   %ebp
80105d48:	89 e5                	mov    %esp,%ebp
80105d4a:	83 ec 10             	sub    $0x10,%esp
  int i;

  if(argint(n, &i) < 0)
80105d4d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105d50:	50                   	push   %eax
80105d51:	ff 75 08             	pushl  0x8(%ebp)
80105d54:	e8 c6 ff ff ff       	call   80105d1f <argint>
80105d59:	83 c4 08             	add    $0x8,%esp
80105d5c:	85 c0                	test   %eax,%eax
80105d5e:	79 07                	jns    80105d67 <argptr+0x20>
    return -1;
80105d60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d65:	eb 3b                	jmp    80105da2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105d67:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d6d:	8b 00                	mov    (%eax),%eax
80105d6f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105d72:	39 d0                	cmp    %edx,%eax
80105d74:	76 16                	jbe    80105d8c <argptr+0x45>
80105d76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d79:	89 c2                	mov    %eax,%edx
80105d7b:	8b 45 10             	mov    0x10(%ebp),%eax
80105d7e:	01 c2                	add    %eax,%edx
80105d80:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105d86:	8b 00                	mov    (%eax),%eax
80105d88:	39 c2                	cmp    %eax,%edx
80105d8a:	76 07                	jbe    80105d93 <argptr+0x4c>
    return -1;
80105d8c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d91:	eb 0f                	jmp    80105da2 <argptr+0x5b>
  *pp = (char*)i;
80105d93:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105d96:	89 c2                	mov    %eax,%edx
80105d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80105d9b:	89 10                	mov    %edx,(%eax)
  return 0;
80105d9d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105da2:	c9                   	leave  
80105da3:	c3                   	ret    

80105da4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105da4:	55                   	push   %ebp
80105da5:	89 e5                	mov    %esp,%ebp
80105da7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
80105daa:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105dad:	50                   	push   %eax
80105dae:	ff 75 08             	pushl  0x8(%ebp)
80105db1:	e8 69 ff ff ff       	call   80105d1f <argint>
80105db6:	83 c4 08             	add    $0x8,%esp
80105db9:	85 c0                	test   %eax,%eax
80105dbb:	79 07                	jns    80105dc4 <argstr+0x20>
    return -1;
80105dbd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105dc2:	eb 0f                	jmp    80105dd3 <argstr+0x2f>
  return fetchstr(addr, pp);
80105dc4:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105dc7:	ff 75 0c             	pushl  0xc(%ebp)
80105dca:	50                   	push   %eax
80105dcb:	e8 ed fe ff ff       	call   80105cbd <fetchstr>
80105dd0:	83 c4 08             	add    $0x8,%esp
}
80105dd3:	c9                   	leave  
80105dd4:	c3                   	ret    

80105dd5 <syscall>:
[SYS_semup] sys_semup,
};

void
syscall(void)
{
80105dd5:	55                   	push   %ebp
80105dd6:	89 e5                	mov    %esp,%ebp
80105dd8:	53                   	push   %ebx
80105dd9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
80105ddc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105de2:	8b 40 18             	mov    0x18(%eax),%eax
80105de5:	8b 40 1c             	mov    0x1c(%eax),%eax
80105de8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105deb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105def:	7e 30                	jle    80105e21 <syscall+0x4c>
80105df1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105df4:	83 f8 1b             	cmp    $0x1b,%eax
80105df7:	77 28                	ja     80105e21 <syscall+0x4c>
80105df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105dfc:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e03:	85 c0                	test   %eax,%eax
80105e05:	74 1a                	je     80105e21 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105e07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e0d:	8b 58 18             	mov    0x18(%eax),%ebx
80105e10:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e13:	8b 04 85 40 c0 10 80 	mov    -0x7fef3fc0(,%eax,4),%eax
80105e1a:	ff d0                	call   *%eax
80105e1c:	89 43 1c             	mov    %eax,0x1c(%ebx)
80105e1f:	eb 34                	jmp    80105e55 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105e21:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e27:	8d 50 6c             	lea    0x6c(%eax),%edx
80105e2a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105e30:	8b 40 10             	mov    0x10(%eax),%eax
80105e33:	ff 75 f4             	pushl  -0xc(%ebp)
80105e36:	52                   	push   %edx
80105e37:	50                   	push   %eax
80105e38:	68 6c 93 10 80       	push   $0x8010936c
80105e3d:	e8 84 a5 ff ff       	call   801003c6 <cprintf>
80105e42:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105e45:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e4b:	8b 40 18             	mov    0x18(%eax),%eax
80105e4e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105e55:	90                   	nop
80105e56:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e59:	c9                   	leave  
80105e5a:	c3                   	ret    

80105e5b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80105e5b:	55                   	push   %ebp
80105e5c:	89 e5                	mov    %esp,%ebp
80105e5e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105e61:	83 ec 08             	sub    $0x8,%esp
80105e64:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e67:	50                   	push   %eax
80105e68:	ff 75 08             	pushl  0x8(%ebp)
80105e6b:	e8 af fe ff ff       	call   80105d1f <argint>
80105e70:	83 c4 10             	add    $0x10,%esp
80105e73:	85 c0                	test   %eax,%eax
80105e75:	79 07                	jns    80105e7e <argfd+0x23>
    return -1;
80105e77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e7c:	eb 50                	jmp    80105ece <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
80105e7e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e81:	85 c0                	test   %eax,%eax
80105e83:	78 21                	js     80105ea6 <argfd+0x4b>
80105e85:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e88:	83 f8 0f             	cmp    $0xf,%eax
80105e8b:	7f 19                	jg     80105ea6 <argfd+0x4b>
80105e8d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105e93:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105e96:	83 c2 08             	add    $0x8,%edx
80105e99:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105e9d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105ea0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105ea4:	75 07                	jne    80105ead <argfd+0x52>
    return -1;
80105ea6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105eab:	eb 21                	jmp    80105ece <argfd+0x73>
  if(pfd)
80105ead:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80105eb1:	74 08                	je     80105ebb <argfd+0x60>
    *pfd = fd;
80105eb3:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105eb6:	8b 45 0c             	mov    0xc(%ebp),%eax
80105eb9:	89 10                	mov    %edx,(%eax)
  if(pf)
80105ebb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105ebf:	74 08                	je     80105ec9 <argfd+0x6e>
    *pf = f;
80105ec1:	8b 45 10             	mov    0x10(%ebp),%eax
80105ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105ec7:	89 10                	mov    %edx,(%eax)
  return 0;
80105ec9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105ece:	c9                   	leave  
80105ecf:	c3                   	ret    

80105ed0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80105ed0:	55                   	push   %ebp
80105ed1:	89 e5                	mov    %esp,%ebp
80105ed3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105ed6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105edd:	eb 30                	jmp    80105f0f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
80105edf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ee5:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105ee8:	83 c2 08             	add    $0x8,%edx
80105eeb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80105eef:	85 c0                	test   %eax,%eax
80105ef1:	75 18                	jne    80105f0b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105ef3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105ef9:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105efc:	8d 4a 08             	lea    0x8(%edx),%ecx
80105eff:	8b 55 08             	mov    0x8(%ebp),%edx
80105f02:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105f06:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105f09:	eb 0f                	jmp    80105f1a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
80105f0b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105f0f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105f13:	7e ca                	jle    80105edf <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105f15:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f1a:	c9                   	leave  
80105f1b:	c3                   	ret    

80105f1c <sys_dup>:

int
sys_dup(void)
{
80105f1c:	55                   	push   %ebp
80105f1d:	89 e5                	mov    %esp,%ebp
80105f1f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105f22:	83 ec 04             	sub    $0x4,%esp
80105f25:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f28:	50                   	push   %eax
80105f29:	6a 00                	push   $0x0
80105f2b:	6a 00                	push   $0x0
80105f2d:	e8 29 ff ff ff       	call   80105e5b <argfd>
80105f32:	83 c4 10             	add    $0x10,%esp
80105f35:	85 c0                	test   %eax,%eax
80105f37:	79 07                	jns    80105f40 <sys_dup+0x24>
    return -1;
80105f39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f3e:	eb 31                	jmp    80105f71 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105f40:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f43:	83 ec 0c             	sub    $0xc,%esp
80105f46:	50                   	push   %eax
80105f47:	e8 84 ff ff ff       	call   80105ed0 <fdalloc>
80105f4c:	83 c4 10             	add    $0x10,%esp
80105f4f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f52:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f56:	79 07                	jns    80105f5f <sys_dup+0x43>
    return -1;
80105f58:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f5d:	eb 12                	jmp    80105f71 <sys_dup+0x55>
  filedup(f);
80105f5f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f62:	83 ec 0c             	sub    $0xc,%esp
80105f65:	50                   	push   %eax
80105f66:	e8 7a b0 ff ff       	call   80100fe5 <filedup>
80105f6b:	83 c4 10             	add    $0x10,%esp
  return fd;
80105f6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105f71:	c9                   	leave  
80105f72:	c3                   	ret    

80105f73 <sys_read>:

int
sys_read(void)
{
80105f73:	55                   	push   %ebp
80105f74:	89 e5                	mov    %esp,%ebp
80105f76:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105f79:	83 ec 04             	sub    $0x4,%esp
80105f7c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105f7f:	50                   	push   %eax
80105f80:	6a 00                	push   $0x0
80105f82:	6a 00                	push   $0x0
80105f84:	e8 d2 fe ff ff       	call   80105e5b <argfd>
80105f89:	83 c4 10             	add    $0x10,%esp
80105f8c:	85 c0                	test   %eax,%eax
80105f8e:	78 2e                	js     80105fbe <sys_read+0x4b>
80105f90:	83 ec 08             	sub    $0x8,%esp
80105f93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105f96:	50                   	push   %eax
80105f97:	6a 02                	push   $0x2
80105f99:	e8 81 fd ff ff       	call   80105d1f <argint>
80105f9e:	83 c4 10             	add    $0x10,%esp
80105fa1:	85 c0                	test   %eax,%eax
80105fa3:	78 19                	js     80105fbe <sys_read+0x4b>
80105fa5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fa8:	83 ec 04             	sub    $0x4,%esp
80105fab:	50                   	push   %eax
80105fac:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105faf:	50                   	push   %eax
80105fb0:	6a 01                	push   $0x1
80105fb2:	e8 90 fd ff ff       	call   80105d47 <argptr>
80105fb7:	83 c4 10             	add    $0x10,%esp
80105fba:	85 c0                	test   %eax,%eax
80105fbc:	79 07                	jns    80105fc5 <sys_read+0x52>
    return -1;
80105fbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105fc3:	eb 17                	jmp    80105fdc <sys_read+0x69>
  return fileread(f, p, n);
80105fc5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105fc8:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105fcb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fce:	83 ec 04             	sub    $0x4,%esp
80105fd1:	51                   	push   %ecx
80105fd2:	52                   	push   %edx
80105fd3:	50                   	push   %eax
80105fd4:	e8 9c b1 ff ff       	call   80101175 <fileread>
80105fd9:	83 c4 10             	add    $0x10,%esp
}
80105fdc:	c9                   	leave  
80105fdd:	c3                   	ret    

80105fde <sys_write>:

int
sys_write(void)
{
80105fde:	55                   	push   %ebp
80105fdf:	89 e5                	mov    %esp,%ebp
80105fe1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105fe4:	83 ec 04             	sub    $0x4,%esp
80105fe7:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105fea:	50                   	push   %eax
80105feb:	6a 00                	push   $0x0
80105fed:	6a 00                	push   $0x0
80105fef:	e8 67 fe ff ff       	call   80105e5b <argfd>
80105ff4:	83 c4 10             	add    $0x10,%esp
80105ff7:	85 c0                	test   %eax,%eax
80105ff9:	78 2e                	js     80106029 <sys_write+0x4b>
80105ffb:	83 ec 08             	sub    $0x8,%esp
80105ffe:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106001:	50                   	push   %eax
80106002:	6a 02                	push   $0x2
80106004:	e8 16 fd ff ff       	call   80105d1f <argint>
80106009:	83 c4 10             	add    $0x10,%esp
8010600c:	85 c0                	test   %eax,%eax
8010600e:	78 19                	js     80106029 <sys_write+0x4b>
80106010:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106013:	83 ec 04             	sub    $0x4,%esp
80106016:	50                   	push   %eax
80106017:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010601a:	50                   	push   %eax
8010601b:	6a 01                	push   $0x1
8010601d:	e8 25 fd ff ff       	call   80105d47 <argptr>
80106022:	83 c4 10             	add    $0x10,%esp
80106025:	85 c0                	test   %eax,%eax
80106027:	79 07                	jns    80106030 <sys_write+0x52>
    return -1;
80106029:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010602e:	eb 17                	jmp    80106047 <sys_write+0x69>
  return filewrite(f, p, n);
80106030:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80106033:	8b 55 ec             	mov    -0x14(%ebp),%edx
80106036:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106039:	83 ec 04             	sub    $0x4,%esp
8010603c:	51                   	push   %ecx
8010603d:	52                   	push   %edx
8010603e:	50                   	push   %eax
8010603f:	e8 e9 b1 ff ff       	call   8010122d <filewrite>
80106044:	83 c4 10             	add    $0x10,%esp
}
80106047:	c9                   	leave  
80106048:	c3                   	ret    

80106049 <sys_close>:

int
sys_close(void)
{
80106049:	55                   	push   %ebp
8010604a:	89 e5                	mov    %esp,%ebp
8010604c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
8010604f:	83 ec 04             	sub    $0x4,%esp
80106052:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106055:	50                   	push   %eax
80106056:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106059:	50                   	push   %eax
8010605a:	6a 00                	push   $0x0
8010605c:	e8 fa fd ff ff       	call   80105e5b <argfd>
80106061:	83 c4 10             	add    $0x10,%esp
80106064:	85 c0                	test   %eax,%eax
80106066:	79 07                	jns    8010606f <sys_close+0x26>
    return -1;
80106068:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010606d:	eb 28                	jmp    80106097 <sys_close+0x4e>
  proc->ofile[fd] = 0;
8010606f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106075:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106078:	83 c2 08             	add    $0x8,%edx
8010607b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106082:	00 
  fileclose(f);
80106083:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106086:	83 ec 0c             	sub    $0xc,%esp
80106089:	50                   	push   %eax
8010608a:	e8 a7 af ff ff       	call   80101036 <fileclose>
8010608f:	83 c4 10             	add    $0x10,%esp
  return 0;
80106092:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106097:	c9                   	leave  
80106098:	c3                   	ret    

80106099 <sys_fstat>:

int
sys_fstat(void)
{
80106099:	55                   	push   %ebp
8010609a:	89 e5                	mov    %esp,%ebp
8010609c:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010609f:	83 ec 04             	sub    $0x4,%esp
801060a2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801060a5:	50                   	push   %eax
801060a6:	6a 00                	push   $0x0
801060a8:	6a 00                	push   $0x0
801060aa:	e8 ac fd ff ff       	call   80105e5b <argfd>
801060af:	83 c4 10             	add    $0x10,%esp
801060b2:	85 c0                	test   %eax,%eax
801060b4:	78 17                	js     801060cd <sys_fstat+0x34>
801060b6:	83 ec 04             	sub    $0x4,%esp
801060b9:	6a 14                	push   $0x14
801060bb:	8d 45 f0             	lea    -0x10(%ebp),%eax
801060be:	50                   	push   %eax
801060bf:	6a 01                	push   $0x1
801060c1:	e8 81 fc ff ff       	call   80105d47 <argptr>
801060c6:	83 c4 10             	add    $0x10,%esp
801060c9:	85 c0                	test   %eax,%eax
801060cb:	79 07                	jns    801060d4 <sys_fstat+0x3b>
    return -1;
801060cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060d2:	eb 13                	jmp    801060e7 <sys_fstat+0x4e>
  return filestat(f, st);
801060d4:	8b 55 f0             	mov    -0x10(%ebp),%edx
801060d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801060da:	83 ec 08             	sub    $0x8,%esp
801060dd:	52                   	push   %edx
801060de:	50                   	push   %eax
801060df:	e8 3a b0 ff ff       	call   8010111e <filestat>
801060e4:	83 c4 10             	add    $0x10,%esp
}
801060e7:	c9                   	leave  
801060e8:	c3                   	ret    

801060e9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
801060e9:	55                   	push   %ebp
801060ea:	89 e5                	mov    %esp,%ebp
801060ec:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801060ef:	83 ec 08             	sub    $0x8,%esp
801060f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801060f5:	50                   	push   %eax
801060f6:	6a 00                	push   $0x0
801060f8:	e8 a7 fc ff ff       	call   80105da4 <argstr>
801060fd:	83 c4 10             	add    $0x10,%esp
80106100:	85 c0                	test   %eax,%eax
80106102:	78 15                	js     80106119 <sys_link+0x30>
80106104:	83 ec 08             	sub    $0x8,%esp
80106107:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010610a:	50                   	push   %eax
8010610b:	6a 01                	push   $0x1
8010610d:	e8 92 fc ff ff       	call   80105da4 <argstr>
80106112:	83 c4 10             	add    $0x10,%esp
80106115:	85 c0                	test   %eax,%eax
80106117:	79 0a                	jns    80106123 <sys_link+0x3a>
    return -1;
80106119:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010611e:	e9 68 01 00 00       	jmp    8010628b <sys_link+0x1a2>

  begin_op();
80106123:	e8 8c d3 ff ff       	call   801034b4 <begin_op>
  if((ip = namei(old)) == 0){
80106128:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010612b:	83 ec 0c             	sub    $0xc,%esp
8010612e:	50                   	push   %eax
8010612f:	e8 8f c3 ff ff       	call   801024c3 <namei>
80106134:	83 c4 10             	add    $0x10,%esp
80106137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010613a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010613e:	75 0f                	jne    8010614f <sys_link+0x66>
    end_op();
80106140:	e8 fb d3 ff ff       	call   80103540 <end_op>
    return -1;
80106145:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614a:	e9 3c 01 00 00       	jmp    8010628b <sys_link+0x1a2>
  }

  ilock(ip);
8010614f:	83 ec 0c             	sub    $0xc,%esp
80106152:	ff 75 f4             	pushl  -0xc(%ebp)
80106155:	e8 b1 b7 ff ff       	call   8010190b <ilock>
8010615a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
8010615d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106160:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106164:	66 83 f8 01          	cmp    $0x1,%ax
80106168:	75 1d                	jne    80106187 <sys_link+0x9e>
    iunlockput(ip);
8010616a:	83 ec 0c             	sub    $0xc,%esp
8010616d:	ff 75 f4             	pushl  -0xc(%ebp)
80106170:	e8 50 ba ff ff       	call   80101bc5 <iunlockput>
80106175:	83 c4 10             	add    $0x10,%esp
    end_op();
80106178:	e8 c3 d3 ff ff       	call   80103540 <end_op>
    return -1;
8010617d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106182:	e9 04 01 00 00       	jmp    8010628b <sys_link+0x1a2>
  }

  ip->nlink++;
80106187:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010618a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
8010618e:	83 c0 01             	add    $0x1,%eax
80106191:	89 c2                	mov    %eax,%edx
80106193:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106196:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
8010619a:	83 ec 0c             	sub    $0xc,%esp
8010619d:	ff 75 f4             	pushl  -0xc(%ebp)
801061a0:	e8 92 b5 ff ff       	call   80101737 <iupdate>
801061a5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
801061a8:	83 ec 0c             	sub    $0xc,%esp
801061ab:	ff 75 f4             	pushl  -0xc(%ebp)
801061ae:	e8 b0 b8 ff ff       	call   80101a63 <iunlock>
801061b3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
801061b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801061b9:	83 ec 08             	sub    $0x8,%esp
801061bc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
801061bf:	52                   	push   %edx
801061c0:	50                   	push   %eax
801061c1:	e8 19 c3 ff ff       	call   801024df <nameiparent>
801061c6:	83 c4 10             	add    $0x10,%esp
801061c9:	89 45 f0             	mov    %eax,-0x10(%ebp)
801061cc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061d0:	74 71                	je     80106243 <sys_link+0x15a>
    goto bad;
  ilock(dp);
801061d2:	83 ec 0c             	sub    $0xc,%esp
801061d5:	ff 75 f0             	pushl  -0x10(%ebp)
801061d8:	e8 2e b7 ff ff       	call   8010190b <ilock>
801061dd:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801061e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061e3:	8b 10                	mov    (%eax),%edx
801061e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061e8:	8b 00                	mov    (%eax),%eax
801061ea:	39 c2                	cmp    %eax,%edx
801061ec:	75 1d                	jne    8010620b <sys_link+0x122>
801061ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
801061f1:	8b 40 04             	mov    0x4(%eax),%eax
801061f4:	83 ec 04             	sub    $0x4,%esp
801061f7:	50                   	push   %eax
801061f8:	8d 45 e2             	lea    -0x1e(%ebp),%eax
801061fb:	50                   	push   %eax
801061fc:	ff 75 f0             	pushl  -0x10(%ebp)
801061ff:	e8 23 c0 ff ff       	call   80102227 <dirlink>
80106204:	83 c4 10             	add    $0x10,%esp
80106207:	85 c0                	test   %eax,%eax
80106209:	79 10                	jns    8010621b <sys_link+0x132>
    iunlockput(dp);
8010620b:	83 ec 0c             	sub    $0xc,%esp
8010620e:	ff 75 f0             	pushl  -0x10(%ebp)
80106211:	e8 af b9 ff ff       	call   80101bc5 <iunlockput>
80106216:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106219:	eb 29                	jmp    80106244 <sys_link+0x15b>
  }
  iunlockput(dp);
8010621b:	83 ec 0c             	sub    $0xc,%esp
8010621e:	ff 75 f0             	pushl  -0x10(%ebp)
80106221:	e8 9f b9 ff ff       	call   80101bc5 <iunlockput>
80106226:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80106229:	83 ec 0c             	sub    $0xc,%esp
8010622c:	ff 75 f4             	pushl  -0xc(%ebp)
8010622f:	e8 a1 b8 ff ff       	call   80101ad5 <iput>
80106234:	83 c4 10             	add    $0x10,%esp

  end_op();
80106237:	e8 04 d3 ff ff       	call   80103540 <end_op>

  return 0;
8010623c:	b8 00 00 00 00       	mov    $0x0,%eax
80106241:	eb 48                	jmp    8010628b <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80106243:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80106244:	83 ec 0c             	sub    $0xc,%esp
80106247:	ff 75 f4             	pushl  -0xc(%ebp)
8010624a:	e8 bc b6 ff ff       	call   8010190b <ilock>
8010624f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80106252:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106255:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106259:	83 e8 01             	sub    $0x1,%eax
8010625c:	89 c2                	mov    %eax,%edx
8010625e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106261:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106265:	83 ec 0c             	sub    $0xc,%esp
80106268:	ff 75 f4             	pushl  -0xc(%ebp)
8010626b:	e8 c7 b4 ff ff       	call   80101737 <iupdate>
80106270:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80106273:	83 ec 0c             	sub    $0xc,%esp
80106276:	ff 75 f4             	pushl  -0xc(%ebp)
80106279:	e8 47 b9 ff ff       	call   80101bc5 <iunlockput>
8010627e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106281:	e8 ba d2 ff ff       	call   80103540 <end_op>
  return -1;
80106286:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010628b:	c9                   	leave  
8010628c:	c3                   	ret    

8010628d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010628d:	55                   	push   %ebp
8010628e:	89 e5                	mov    %esp,%ebp
80106290:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80106293:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
8010629a:	eb 40                	jmp    801062dc <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010629c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010629f:	6a 10                	push   $0x10
801062a1:	50                   	push   %eax
801062a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062a5:	50                   	push   %eax
801062a6:	ff 75 08             	pushl  0x8(%ebp)
801062a9:	e8 c5 bb ff ff       	call   80101e73 <readi>
801062ae:	83 c4 10             	add    $0x10,%esp
801062b1:	83 f8 10             	cmp    $0x10,%eax
801062b4:	74 0d                	je     801062c3 <isdirempty+0x36>
      panic("isdirempty: readi");
801062b6:	83 ec 0c             	sub    $0xc,%esp
801062b9:	68 88 93 10 80       	push   $0x80109388
801062be:	e8 a3 a2 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
801062c3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801062c7:	66 85 c0             	test   %ax,%ax
801062ca:	74 07                	je     801062d3 <isdirempty+0x46>
      return 0;
801062cc:	b8 00 00 00 00       	mov    $0x0,%eax
801062d1:	eb 1b                	jmp    801062ee <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801062d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062d6:	83 c0 10             	add    $0x10,%eax
801062d9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062dc:	8b 45 08             	mov    0x8(%ebp),%eax
801062df:	8b 50 18             	mov    0x18(%eax),%edx
801062e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801062e5:	39 c2                	cmp    %eax,%edx
801062e7:	77 b3                	ja     8010629c <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
801062e9:	b8 01 00 00 00       	mov    $0x1,%eax
}
801062ee:	c9                   	leave  
801062ef:	c3                   	ret    

801062f0 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
801062f0:	55                   	push   %ebp
801062f1:	89 e5                	mov    %esp,%ebp
801062f3:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
801062f6:	83 ec 08             	sub    $0x8,%esp
801062f9:	8d 45 cc             	lea    -0x34(%ebp),%eax
801062fc:	50                   	push   %eax
801062fd:	6a 00                	push   $0x0
801062ff:	e8 a0 fa ff ff       	call   80105da4 <argstr>
80106304:	83 c4 10             	add    $0x10,%esp
80106307:	85 c0                	test   %eax,%eax
80106309:	79 0a                	jns    80106315 <sys_unlink+0x25>
    return -1;
8010630b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106310:	e9 bc 01 00 00       	jmp    801064d1 <sys_unlink+0x1e1>

  begin_op();
80106315:	e8 9a d1 ff ff       	call   801034b4 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010631a:	8b 45 cc             	mov    -0x34(%ebp),%eax
8010631d:	83 ec 08             	sub    $0x8,%esp
80106320:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80106323:	52                   	push   %edx
80106324:	50                   	push   %eax
80106325:	e8 b5 c1 ff ff       	call   801024df <nameiparent>
8010632a:	83 c4 10             	add    $0x10,%esp
8010632d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106330:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106334:	75 0f                	jne    80106345 <sys_unlink+0x55>
    end_op();
80106336:	e8 05 d2 ff ff       	call   80103540 <end_op>
    return -1;
8010633b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106340:	e9 8c 01 00 00       	jmp    801064d1 <sys_unlink+0x1e1>
  }

  ilock(dp);
80106345:	83 ec 0c             	sub    $0xc,%esp
80106348:	ff 75 f4             	pushl  -0xc(%ebp)
8010634b:	e8 bb b5 ff ff       	call   8010190b <ilock>
80106350:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80106353:	83 ec 08             	sub    $0x8,%esp
80106356:	68 9a 93 10 80       	push   $0x8010939a
8010635b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010635e:	50                   	push   %eax
8010635f:	e8 ee bd ff ff       	call   80102152 <namecmp>
80106364:	83 c4 10             	add    $0x10,%esp
80106367:	85 c0                	test   %eax,%eax
80106369:	0f 84 4a 01 00 00    	je     801064b9 <sys_unlink+0x1c9>
8010636f:	83 ec 08             	sub    $0x8,%esp
80106372:	68 9c 93 10 80       	push   $0x8010939c
80106377:	8d 45 d2             	lea    -0x2e(%ebp),%eax
8010637a:	50                   	push   %eax
8010637b:	e8 d2 bd ff ff       	call   80102152 <namecmp>
80106380:	83 c4 10             	add    $0x10,%esp
80106383:	85 c0                	test   %eax,%eax
80106385:	0f 84 2e 01 00 00    	je     801064b9 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
8010638b:	83 ec 04             	sub    $0x4,%esp
8010638e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80106391:	50                   	push   %eax
80106392:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80106395:	50                   	push   %eax
80106396:	ff 75 f4             	pushl  -0xc(%ebp)
80106399:	e8 cf bd ff ff       	call   8010216d <dirlookup>
8010639e:	83 c4 10             	add    $0x10,%esp
801063a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801063a4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801063a8:	0f 84 0a 01 00 00    	je     801064b8 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
801063ae:	83 ec 0c             	sub    $0xc,%esp
801063b1:	ff 75 f0             	pushl  -0x10(%ebp)
801063b4:	e8 52 b5 ff ff       	call   8010190b <ilock>
801063b9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
801063bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063bf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
801063c3:	66 85 c0             	test   %ax,%ax
801063c6:	7f 0d                	jg     801063d5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	68 9f 93 10 80       	push   $0x8010939f
801063d0:	e8 91 a1 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801063d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801063d8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063dc:	66 83 f8 01          	cmp    $0x1,%ax
801063e0:	75 25                	jne    80106407 <sys_unlink+0x117>
801063e2:	83 ec 0c             	sub    $0xc,%esp
801063e5:	ff 75 f0             	pushl  -0x10(%ebp)
801063e8:	e8 a0 fe ff ff       	call   8010628d <isdirempty>
801063ed:	83 c4 10             	add    $0x10,%esp
801063f0:	85 c0                	test   %eax,%eax
801063f2:	75 13                	jne    80106407 <sys_unlink+0x117>
    iunlockput(ip);
801063f4:	83 ec 0c             	sub    $0xc,%esp
801063f7:	ff 75 f0             	pushl  -0x10(%ebp)
801063fa:	e8 c6 b7 ff ff       	call   80101bc5 <iunlockput>
801063ff:	83 c4 10             	add    $0x10,%esp
    goto bad;
80106402:	e9 b2 00 00 00       	jmp    801064b9 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80106407:	83 ec 04             	sub    $0x4,%esp
8010640a:	6a 10                	push   $0x10
8010640c:	6a 00                	push   $0x0
8010640e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106411:	50                   	push   %eax
80106412:	e8 e3 f5 ff ff       	call   801059fa <memset>
80106417:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010641a:	8b 45 c8             	mov    -0x38(%ebp),%eax
8010641d:	6a 10                	push   $0x10
8010641f:	50                   	push   %eax
80106420:	8d 45 e0             	lea    -0x20(%ebp),%eax
80106423:	50                   	push   %eax
80106424:	ff 75 f4             	pushl  -0xc(%ebp)
80106427:	e8 9e bb ff ff       	call   80101fca <writei>
8010642c:	83 c4 10             	add    $0x10,%esp
8010642f:	83 f8 10             	cmp    $0x10,%eax
80106432:	74 0d                	je     80106441 <sys_unlink+0x151>
    panic("unlink: writei");
80106434:	83 ec 0c             	sub    $0xc,%esp
80106437:	68 b1 93 10 80       	push   $0x801093b1
8010643c:	e8 25 a1 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80106441:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106444:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106448:	66 83 f8 01          	cmp    $0x1,%ax
8010644c:	75 21                	jne    8010646f <sys_unlink+0x17f>
    dp->nlink--;
8010644e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106451:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106455:	83 e8 01             	sub    $0x1,%eax
80106458:	89 c2                	mov    %eax,%edx
8010645a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010645d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106461:	83 ec 0c             	sub    $0xc,%esp
80106464:	ff 75 f4             	pushl  -0xc(%ebp)
80106467:	e8 cb b2 ff ff       	call   80101737 <iupdate>
8010646c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
8010646f:	83 ec 0c             	sub    $0xc,%esp
80106472:	ff 75 f4             	pushl  -0xc(%ebp)
80106475:	e8 4b b7 ff ff       	call   80101bc5 <iunlockput>
8010647a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
8010647d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106480:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106484:	83 e8 01             	sub    $0x1,%eax
80106487:	89 c2                	mov    %eax,%edx
80106489:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010648c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80106490:	83 ec 0c             	sub    $0xc,%esp
80106493:	ff 75 f0             	pushl  -0x10(%ebp)
80106496:	e8 9c b2 ff ff       	call   80101737 <iupdate>
8010649b:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
8010649e:	83 ec 0c             	sub    $0xc,%esp
801064a1:	ff 75 f0             	pushl  -0x10(%ebp)
801064a4:	e8 1c b7 ff ff       	call   80101bc5 <iunlockput>
801064a9:	83 c4 10             	add    $0x10,%esp

  end_op();
801064ac:	e8 8f d0 ff ff       	call   80103540 <end_op>

  return 0;
801064b1:	b8 00 00 00 00       	mov    $0x0,%eax
801064b6:	eb 19                	jmp    801064d1 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
801064b8:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
801064b9:	83 ec 0c             	sub    $0xc,%esp
801064bc:	ff 75 f4             	pushl  -0xc(%ebp)
801064bf:	e8 01 b7 ff ff       	call   80101bc5 <iunlockput>
801064c4:	83 c4 10             	add    $0x10,%esp
  end_op();
801064c7:	e8 74 d0 ff ff       	call   80103540 <end_op>
  return -1;
801064cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801064d1:	c9                   	leave  
801064d2:	c3                   	ret    

801064d3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
801064d3:	55                   	push   %ebp
801064d4:	89 e5                	mov    %esp,%ebp
801064d6:	83 ec 38             	sub    $0x38,%esp
801064d9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801064dc:	8b 55 10             	mov    0x10(%ebp),%edx
801064df:	8b 45 14             	mov    0x14(%ebp),%eax
801064e2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
801064e6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
801064ea:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801064ee:	83 ec 08             	sub    $0x8,%esp
801064f1:	8d 45 de             	lea    -0x22(%ebp),%eax
801064f4:	50                   	push   %eax
801064f5:	ff 75 08             	pushl  0x8(%ebp)
801064f8:	e8 e2 bf ff ff       	call   801024df <nameiparent>
801064fd:	83 c4 10             	add    $0x10,%esp
80106500:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106503:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106507:	75 0a                	jne    80106513 <create+0x40>
    return 0;
80106509:	b8 00 00 00 00       	mov    $0x0,%eax
8010650e:	e9 90 01 00 00       	jmp    801066a3 <create+0x1d0>
  ilock(dp);
80106513:	83 ec 0c             	sub    $0xc,%esp
80106516:	ff 75 f4             	pushl  -0xc(%ebp)
80106519:	e8 ed b3 ff ff       	call   8010190b <ilock>
8010651e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80106521:	83 ec 04             	sub    $0x4,%esp
80106524:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106527:	50                   	push   %eax
80106528:	8d 45 de             	lea    -0x22(%ebp),%eax
8010652b:	50                   	push   %eax
8010652c:	ff 75 f4             	pushl  -0xc(%ebp)
8010652f:	e8 39 bc ff ff       	call   8010216d <dirlookup>
80106534:	83 c4 10             	add    $0x10,%esp
80106537:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010653a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010653e:	74 50                	je     80106590 <create+0xbd>
    iunlockput(dp);
80106540:	83 ec 0c             	sub    $0xc,%esp
80106543:	ff 75 f4             	pushl  -0xc(%ebp)
80106546:	e8 7a b6 ff ff       	call   80101bc5 <iunlockput>
8010654b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
8010654e:	83 ec 0c             	sub    $0xc,%esp
80106551:	ff 75 f0             	pushl  -0x10(%ebp)
80106554:	e8 b2 b3 ff ff       	call   8010190b <ilock>
80106559:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
8010655c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80106561:	75 15                	jne    80106578 <create+0xa5>
80106563:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106566:	0f b7 40 10          	movzwl 0x10(%eax),%eax
8010656a:	66 83 f8 02          	cmp    $0x2,%ax
8010656e:	75 08                	jne    80106578 <create+0xa5>
      return ip;
80106570:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106573:	e9 2b 01 00 00       	jmp    801066a3 <create+0x1d0>
    iunlockput(ip);
80106578:	83 ec 0c             	sub    $0xc,%esp
8010657b:	ff 75 f0             	pushl  -0x10(%ebp)
8010657e:	e8 42 b6 ff ff       	call   80101bc5 <iunlockput>
80106583:	83 c4 10             	add    $0x10,%esp
    return 0;
80106586:	b8 00 00 00 00       	mov    $0x0,%eax
8010658b:	e9 13 01 00 00       	jmp    801066a3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80106590:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80106594:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106597:	8b 00                	mov    (%eax),%eax
80106599:	83 ec 08             	sub    $0x8,%esp
8010659c:	52                   	push   %edx
8010659d:	50                   	push   %eax
8010659e:	e8 b3 b0 ff ff       	call   80101656 <ialloc>
801065a3:	83 c4 10             	add    $0x10,%esp
801065a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
801065a9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801065ad:	75 0d                	jne    801065bc <create+0xe9>
    panic("create: ialloc");
801065af:	83 ec 0c             	sub    $0xc,%esp
801065b2:	68 c0 93 10 80       	push   $0x801093c0
801065b7:	e8 aa 9f ff ff       	call   80100566 <panic>

  ilock(ip);
801065bc:	83 ec 0c             	sub    $0xc,%esp
801065bf:	ff 75 f0             	pushl  -0x10(%ebp)
801065c2:	e8 44 b3 ff ff       	call   8010190b <ilock>
801065c7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
801065ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065cd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
801065d1:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
801065d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
801065dc:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
801065e0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065e3:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
801065e9:	83 ec 0c             	sub    $0xc,%esp
801065ec:	ff 75 f0             	pushl  -0x10(%ebp)
801065ef:	e8 43 b1 ff ff       	call   80101737 <iupdate>
801065f4:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
801065f7:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
801065fc:	75 6a                	jne    80106668 <create+0x195>
    dp->nlink++;  // for ".."
801065fe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106601:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106605:	83 c0 01             	add    $0x1,%eax
80106608:	89 c2                	mov    %eax,%edx
8010660a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010660d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106611:	83 ec 0c             	sub    $0xc,%esp
80106614:	ff 75 f4             	pushl  -0xc(%ebp)
80106617:	e8 1b b1 ff ff       	call   80101737 <iupdate>
8010661c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010661f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106622:	8b 40 04             	mov    0x4(%eax),%eax
80106625:	83 ec 04             	sub    $0x4,%esp
80106628:	50                   	push   %eax
80106629:	68 9a 93 10 80       	push   $0x8010939a
8010662e:	ff 75 f0             	pushl  -0x10(%ebp)
80106631:	e8 f1 bb ff ff       	call   80102227 <dirlink>
80106636:	83 c4 10             	add    $0x10,%esp
80106639:	85 c0                	test   %eax,%eax
8010663b:	78 1e                	js     8010665b <create+0x188>
8010663d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106640:	8b 40 04             	mov    0x4(%eax),%eax
80106643:	83 ec 04             	sub    $0x4,%esp
80106646:	50                   	push   %eax
80106647:	68 9c 93 10 80       	push   $0x8010939c
8010664c:	ff 75 f0             	pushl  -0x10(%ebp)
8010664f:	e8 d3 bb ff ff       	call   80102227 <dirlink>
80106654:	83 c4 10             	add    $0x10,%esp
80106657:	85 c0                	test   %eax,%eax
80106659:	79 0d                	jns    80106668 <create+0x195>
      panic("create dots");
8010665b:	83 ec 0c             	sub    $0xc,%esp
8010665e:	68 cf 93 10 80       	push   $0x801093cf
80106663:	e8 fe 9e ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106668:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010666b:	8b 40 04             	mov    0x4(%eax),%eax
8010666e:	83 ec 04             	sub    $0x4,%esp
80106671:	50                   	push   %eax
80106672:	8d 45 de             	lea    -0x22(%ebp),%eax
80106675:	50                   	push   %eax
80106676:	ff 75 f4             	pushl  -0xc(%ebp)
80106679:	e8 a9 bb ff ff       	call   80102227 <dirlink>
8010667e:	83 c4 10             	add    $0x10,%esp
80106681:	85 c0                	test   %eax,%eax
80106683:	79 0d                	jns    80106692 <create+0x1bf>
    panic("create: dirlink");
80106685:	83 ec 0c             	sub    $0xc,%esp
80106688:	68 db 93 10 80       	push   $0x801093db
8010668d:	e8 d4 9e ff ff       	call   80100566 <panic>

  iunlockput(dp);
80106692:	83 ec 0c             	sub    $0xc,%esp
80106695:	ff 75 f4             	pushl  -0xc(%ebp)
80106698:	e8 28 b5 ff ff       	call   80101bc5 <iunlockput>
8010669d:	83 c4 10             	add    $0x10,%esp

  return ip;
801066a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801066a3:	c9                   	leave  
801066a4:	c3                   	ret    

801066a5 <sys_open>:

int
sys_open(void)
{
801066a5:	55                   	push   %ebp
801066a6:	89 e5                	mov    %esp,%ebp
801066a8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801066ab:	83 ec 08             	sub    $0x8,%esp
801066ae:	8d 45 e8             	lea    -0x18(%ebp),%eax
801066b1:	50                   	push   %eax
801066b2:	6a 00                	push   $0x0
801066b4:	e8 eb f6 ff ff       	call   80105da4 <argstr>
801066b9:	83 c4 10             	add    $0x10,%esp
801066bc:	85 c0                	test   %eax,%eax
801066be:	78 15                	js     801066d5 <sys_open+0x30>
801066c0:	83 ec 08             	sub    $0x8,%esp
801066c3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801066c6:	50                   	push   %eax
801066c7:	6a 01                	push   $0x1
801066c9:	e8 51 f6 ff ff       	call   80105d1f <argint>
801066ce:	83 c4 10             	add    $0x10,%esp
801066d1:	85 c0                	test   %eax,%eax
801066d3:	79 0a                	jns    801066df <sys_open+0x3a>
    return -1;
801066d5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066da:	e9 61 01 00 00       	jmp    80106840 <sys_open+0x19b>

  begin_op();
801066df:	e8 d0 cd ff ff       	call   801034b4 <begin_op>

  if(omode & O_CREATE){
801066e4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801066e7:	25 00 02 00 00       	and    $0x200,%eax
801066ec:	85 c0                	test   %eax,%eax
801066ee:	74 2a                	je     8010671a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
801066f0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801066f3:	6a 00                	push   $0x0
801066f5:	6a 00                	push   $0x0
801066f7:	6a 02                	push   $0x2
801066f9:	50                   	push   %eax
801066fa:	e8 d4 fd ff ff       	call   801064d3 <create>
801066ff:	83 c4 10             	add    $0x10,%esp
80106702:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106705:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106709:	75 75                	jne    80106780 <sys_open+0xdb>
      end_op();
8010670b:	e8 30 ce ff ff       	call   80103540 <end_op>
      return -1;
80106710:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106715:	e9 26 01 00 00       	jmp    80106840 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010671a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010671d:	83 ec 0c             	sub    $0xc,%esp
80106720:	50                   	push   %eax
80106721:	e8 9d bd ff ff       	call   801024c3 <namei>
80106726:	83 c4 10             	add    $0x10,%esp
80106729:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010672c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106730:	75 0f                	jne    80106741 <sys_open+0x9c>
      end_op();
80106732:	e8 09 ce ff ff       	call   80103540 <end_op>
      return -1;
80106737:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010673c:	e9 ff 00 00 00       	jmp    80106840 <sys_open+0x19b>
    }
    ilock(ip);
80106741:	83 ec 0c             	sub    $0xc,%esp
80106744:	ff 75 f4             	pushl  -0xc(%ebp)
80106747:	e8 bf b1 ff ff       	call   8010190b <ilock>
8010674c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010674f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106752:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106756:	66 83 f8 01          	cmp    $0x1,%ax
8010675a:	75 24                	jne    80106780 <sys_open+0xdb>
8010675c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010675f:	85 c0                	test   %eax,%eax
80106761:	74 1d                	je     80106780 <sys_open+0xdb>
      iunlockput(ip);
80106763:	83 ec 0c             	sub    $0xc,%esp
80106766:	ff 75 f4             	pushl  -0xc(%ebp)
80106769:	e8 57 b4 ff ff       	call   80101bc5 <iunlockput>
8010676e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106771:	e8 ca cd ff ff       	call   80103540 <end_op>
      return -1;
80106776:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010677b:	e9 c0 00 00 00       	jmp    80106840 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106780:	e8 f3 a7 ff ff       	call   80100f78 <filealloc>
80106785:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106788:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010678c:	74 17                	je     801067a5 <sys_open+0x100>
8010678e:	83 ec 0c             	sub    $0xc,%esp
80106791:	ff 75 f0             	pushl  -0x10(%ebp)
80106794:	e8 37 f7 ff ff       	call   80105ed0 <fdalloc>
80106799:	83 c4 10             	add    $0x10,%esp
8010679c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010679f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801067a3:	79 2e                	jns    801067d3 <sys_open+0x12e>
    if(f)
801067a5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801067a9:	74 0e                	je     801067b9 <sys_open+0x114>
      fileclose(f);
801067ab:	83 ec 0c             	sub    $0xc,%esp
801067ae:	ff 75 f0             	pushl  -0x10(%ebp)
801067b1:	e8 80 a8 ff ff       	call   80101036 <fileclose>
801067b6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801067b9:	83 ec 0c             	sub    $0xc,%esp
801067bc:	ff 75 f4             	pushl  -0xc(%ebp)
801067bf:	e8 01 b4 ff ff       	call   80101bc5 <iunlockput>
801067c4:	83 c4 10             	add    $0x10,%esp
    end_op();
801067c7:	e8 74 cd ff ff       	call   80103540 <end_op>
    return -1;
801067cc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801067d1:	eb 6d                	jmp    80106840 <sys_open+0x19b>
  }
  iunlock(ip);
801067d3:	83 ec 0c             	sub    $0xc,%esp
801067d6:	ff 75 f4             	pushl  -0xc(%ebp)
801067d9:	e8 85 b2 ff ff       	call   80101a63 <iunlock>
801067de:	83 c4 10             	add    $0x10,%esp
  end_op();
801067e1:	e8 5a cd ff ff       	call   80103540 <end_op>

  f->type = FD_INODE;
801067e6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067e9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801067ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067f2:	8b 55 f4             	mov    -0xc(%ebp),%edx
801067f5:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
801067f8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801067fb:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106802:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106805:	83 e0 01             	and    $0x1,%eax
80106808:	85 c0                	test   %eax,%eax
8010680a:	0f 94 c0             	sete   %al
8010680d:	89 c2                	mov    %eax,%edx
8010680f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106812:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106815:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106818:	83 e0 01             	and    $0x1,%eax
8010681b:	85 c0                	test   %eax,%eax
8010681d:	75 0a                	jne    80106829 <sys_open+0x184>
8010681f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106822:	83 e0 02             	and    $0x2,%eax
80106825:	85 c0                	test   %eax,%eax
80106827:	74 07                	je     80106830 <sys_open+0x18b>
80106829:	b8 01 00 00 00       	mov    $0x1,%eax
8010682e:	eb 05                	jmp    80106835 <sys_open+0x190>
80106830:	b8 00 00 00 00       	mov    $0x0,%eax
80106835:	89 c2                	mov    %eax,%edx
80106837:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010683a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010683d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106840:	c9                   	leave  
80106841:	c3                   	ret    

80106842 <sys_mkdir>:

int
sys_mkdir(void)
{
80106842:	55                   	push   %ebp
80106843:	89 e5                	mov    %esp,%ebp
80106845:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106848:	e8 67 cc ff ff       	call   801034b4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010684d:	83 ec 08             	sub    $0x8,%esp
80106850:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106853:	50                   	push   %eax
80106854:	6a 00                	push   $0x0
80106856:	e8 49 f5 ff ff       	call   80105da4 <argstr>
8010685b:	83 c4 10             	add    $0x10,%esp
8010685e:	85 c0                	test   %eax,%eax
80106860:	78 1b                	js     8010687d <sys_mkdir+0x3b>
80106862:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106865:	6a 00                	push   $0x0
80106867:	6a 00                	push   $0x0
80106869:	6a 01                	push   $0x1
8010686b:	50                   	push   %eax
8010686c:	e8 62 fc ff ff       	call   801064d3 <create>
80106871:	83 c4 10             	add    $0x10,%esp
80106874:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106877:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010687b:	75 0c                	jne    80106889 <sys_mkdir+0x47>
    end_op();
8010687d:	e8 be cc ff ff       	call   80103540 <end_op>
    return -1;
80106882:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106887:	eb 18                	jmp    801068a1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106889:	83 ec 0c             	sub    $0xc,%esp
8010688c:	ff 75 f4             	pushl  -0xc(%ebp)
8010688f:	e8 31 b3 ff ff       	call   80101bc5 <iunlockput>
80106894:	83 c4 10             	add    $0x10,%esp
  end_op();
80106897:	e8 a4 cc ff ff       	call   80103540 <end_op>
  return 0;
8010689c:	b8 00 00 00 00       	mov    $0x0,%eax
}
801068a1:	c9                   	leave  
801068a2:	c3                   	ret    

801068a3 <sys_mknod>:

int
sys_mknod(void)
{
801068a3:	55                   	push   %ebp
801068a4:	89 e5                	mov    %esp,%ebp
801068a6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801068a9:	e8 06 cc ff ff       	call   801034b4 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801068ae:	83 ec 08             	sub    $0x8,%esp
801068b1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801068b4:	50                   	push   %eax
801068b5:	6a 00                	push   $0x0
801068b7:	e8 e8 f4 ff ff       	call   80105da4 <argstr>
801068bc:	83 c4 10             	add    $0x10,%esp
801068bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801068c2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801068c6:	78 4f                	js     80106917 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801068c8:	83 ec 08             	sub    $0x8,%esp
801068cb:	8d 45 e8             	lea    -0x18(%ebp),%eax
801068ce:	50                   	push   %eax
801068cf:	6a 01                	push   $0x1
801068d1:	e8 49 f4 ff ff       	call   80105d1f <argint>
801068d6:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801068d9:	85 c0                	test   %eax,%eax
801068db:	78 3a                	js     80106917 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801068dd:	83 ec 08             	sub    $0x8,%esp
801068e0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801068e3:	50                   	push   %eax
801068e4:	6a 02                	push   $0x2
801068e6:	e8 34 f4 ff ff       	call   80105d1f <argint>
801068eb:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801068ee:	85 c0                	test   %eax,%eax
801068f0:	78 25                	js     80106917 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
801068f2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801068f5:	0f bf c8             	movswl %ax,%ecx
801068f8:	8b 45 e8             	mov    -0x18(%ebp),%eax
801068fb:	0f bf d0             	movswl %ax,%edx
801068fe:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106901:	51                   	push   %ecx
80106902:	52                   	push   %edx
80106903:	6a 03                	push   $0x3
80106905:	50                   	push   %eax
80106906:	e8 c8 fb ff ff       	call   801064d3 <create>
8010690b:	83 c4 10             	add    $0x10,%esp
8010690e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106911:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106915:	75 0c                	jne    80106923 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106917:	e8 24 cc ff ff       	call   80103540 <end_op>
    return -1;
8010691c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106921:	eb 18                	jmp    8010693b <sys_mknod+0x98>
  }
  iunlockput(ip);
80106923:	83 ec 0c             	sub    $0xc,%esp
80106926:	ff 75 f0             	pushl  -0x10(%ebp)
80106929:	e8 97 b2 ff ff       	call   80101bc5 <iunlockput>
8010692e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106931:	e8 0a cc ff ff       	call   80103540 <end_op>
  return 0;
80106936:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010693b:	c9                   	leave  
8010693c:	c3                   	ret    

8010693d <sys_chdir>:

int
sys_chdir(void)
{
8010693d:	55                   	push   %ebp
8010693e:	89 e5                	mov    %esp,%ebp
80106940:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106943:	e8 6c cb ff ff       	call   801034b4 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106948:	83 ec 08             	sub    $0x8,%esp
8010694b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010694e:	50                   	push   %eax
8010694f:	6a 00                	push   $0x0
80106951:	e8 4e f4 ff ff       	call   80105da4 <argstr>
80106956:	83 c4 10             	add    $0x10,%esp
80106959:	85 c0                	test   %eax,%eax
8010695b:	78 18                	js     80106975 <sys_chdir+0x38>
8010695d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106960:	83 ec 0c             	sub    $0xc,%esp
80106963:	50                   	push   %eax
80106964:	e8 5a bb ff ff       	call   801024c3 <namei>
80106969:	83 c4 10             	add    $0x10,%esp
8010696c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010696f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106973:	75 0c                	jne    80106981 <sys_chdir+0x44>
    end_op();
80106975:	e8 c6 cb ff ff       	call   80103540 <end_op>
    return -1;
8010697a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010697f:	eb 6e                	jmp    801069ef <sys_chdir+0xb2>
  }
  ilock(ip);
80106981:	83 ec 0c             	sub    $0xc,%esp
80106984:	ff 75 f4             	pushl  -0xc(%ebp)
80106987:	e8 7f af ff ff       	call   8010190b <ilock>
8010698c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010698f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106992:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106996:	66 83 f8 01          	cmp    $0x1,%ax
8010699a:	74 1a                	je     801069b6 <sys_chdir+0x79>
    iunlockput(ip);
8010699c:	83 ec 0c             	sub    $0xc,%esp
8010699f:	ff 75 f4             	pushl  -0xc(%ebp)
801069a2:	e8 1e b2 ff ff       	call   80101bc5 <iunlockput>
801069a7:	83 c4 10             	add    $0x10,%esp
    end_op();
801069aa:	e8 91 cb ff ff       	call   80103540 <end_op>
    return -1;
801069af:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801069b4:	eb 39                	jmp    801069ef <sys_chdir+0xb2>
  }
  iunlock(ip);
801069b6:	83 ec 0c             	sub    $0xc,%esp
801069b9:	ff 75 f4             	pushl  -0xc(%ebp)
801069bc:	e8 a2 b0 ff ff       	call   80101a63 <iunlock>
801069c1:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801069c4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069ca:	8b 40 68             	mov    0x68(%eax),%eax
801069cd:	83 ec 0c             	sub    $0xc,%esp
801069d0:	50                   	push   %eax
801069d1:	e8 ff b0 ff ff       	call   80101ad5 <iput>
801069d6:	83 c4 10             	add    $0x10,%esp
  end_op();
801069d9:	e8 62 cb ff ff       	call   80103540 <end_op>
  proc->cwd = ip;
801069de:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801069e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801069e7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801069ea:	b8 00 00 00 00       	mov    $0x0,%eax
}
801069ef:	c9                   	leave  
801069f0:	c3                   	ret    

801069f1 <sys_exec>:

int
sys_exec(void)
{
801069f1:	55                   	push   %ebp
801069f2:	89 e5                	mov    %esp,%ebp
801069f4:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
801069fa:	83 ec 08             	sub    $0x8,%esp
801069fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106a00:	50                   	push   %eax
80106a01:	6a 00                	push   $0x0
80106a03:	e8 9c f3 ff ff       	call   80105da4 <argstr>
80106a08:	83 c4 10             	add    $0x10,%esp
80106a0b:	85 c0                	test   %eax,%eax
80106a0d:	78 18                	js     80106a27 <sys_exec+0x36>
80106a0f:	83 ec 08             	sub    $0x8,%esp
80106a12:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106a18:	50                   	push   %eax
80106a19:	6a 01                	push   $0x1
80106a1b:	e8 ff f2 ff ff       	call   80105d1f <argint>
80106a20:	83 c4 10             	add    $0x10,%esp
80106a23:	85 c0                	test   %eax,%eax
80106a25:	79 0a                	jns    80106a31 <sys_exec+0x40>
    return -1;
80106a27:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a2c:	e9 c6 00 00 00       	jmp    80106af7 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106a31:	83 ec 04             	sub    $0x4,%esp
80106a34:	68 80 00 00 00       	push   $0x80
80106a39:	6a 00                	push   $0x0
80106a3b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106a41:	50                   	push   %eax
80106a42:	e8 b3 ef ff ff       	call   801059fa <memset>
80106a47:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80106a4a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106a51:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a54:	83 f8 1f             	cmp    $0x1f,%eax
80106a57:	76 0a                	jbe    80106a63 <sys_exec+0x72>
      return -1;
80106a59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a5e:	e9 94 00 00 00       	jmp    80106af7 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a66:	c1 e0 02             	shl    $0x2,%eax
80106a69:	89 c2                	mov    %eax,%edx
80106a6b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106a71:	01 c2                	add    %eax,%edx
80106a73:	83 ec 08             	sub    $0x8,%esp
80106a76:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
80106a7c:	50                   	push   %eax
80106a7d:	52                   	push   %edx
80106a7e:	e8 00 f2 ff ff       	call   80105c83 <fetchint>
80106a83:	83 c4 10             	add    $0x10,%esp
80106a86:	85 c0                	test   %eax,%eax
80106a88:	79 07                	jns    80106a91 <sys_exec+0xa0>
      return -1;
80106a8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106a8f:	eb 66                	jmp    80106af7 <sys_exec+0x106>
    if(uarg == 0){
80106a91:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106a97:	85 c0                	test   %eax,%eax
80106a99:	75 27                	jne    80106ac2 <sys_exec+0xd1>
      argv[i] = 0;
80106a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106a9e:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
80106aa5:	00 00 00 00 
      break;
80106aa9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
80106aaa:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106aad:	83 ec 08             	sub    $0x8,%esp
80106ab0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
80106ab6:	52                   	push   %edx
80106ab7:	50                   	push   %eax
80106ab8:	e8 99 a0 ff ff       	call   80100b56 <exec>
80106abd:	83 c4 10             	add    $0x10,%esp
80106ac0:	eb 35                	jmp    80106af7 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80106ac2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106ac8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106acb:	c1 e2 02             	shl    $0x2,%edx
80106ace:	01 c2                	add    %eax,%edx
80106ad0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
80106ad6:	83 ec 08             	sub    $0x8,%esp
80106ad9:	52                   	push   %edx
80106ada:	50                   	push   %eax
80106adb:	e8 dd f1 ff ff       	call   80105cbd <fetchstr>
80106ae0:	83 c4 10             	add    $0x10,%esp
80106ae3:	85 c0                	test   %eax,%eax
80106ae5:	79 07                	jns    80106aee <sys_exec+0xfd>
      return -1;
80106ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106aec:	eb 09                	jmp    80106af7 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
80106aee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106af2:	e9 5a ff ff ff       	jmp    80106a51 <sys_exec+0x60>
  return exec(path, argv);
}
80106af7:	c9                   	leave  
80106af8:	c3                   	ret    

80106af9 <sys_pipe>:

int
sys_pipe(void)
{
80106af9:	55                   	push   %ebp
80106afa:	89 e5                	mov    %esp,%ebp
80106afc:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80106aff:	83 ec 04             	sub    $0x4,%esp
80106b02:	6a 08                	push   $0x8
80106b04:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106b07:	50                   	push   %eax
80106b08:	6a 00                	push   $0x0
80106b0a:	e8 38 f2 ff ff       	call   80105d47 <argptr>
80106b0f:	83 c4 10             	add    $0x10,%esp
80106b12:	85 c0                	test   %eax,%eax
80106b14:	79 0a                	jns    80106b20 <sys_pipe+0x27>
    return -1;
80106b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b1b:	e9 af 00 00 00       	jmp    80106bcf <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106b20:	83 ec 08             	sub    $0x8,%esp
80106b23:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106b26:	50                   	push   %eax
80106b27:	8d 45 e8             	lea    -0x18(%ebp),%eax
80106b2a:	50                   	push   %eax
80106b2b:	e8 82 d4 ff ff       	call   80103fb2 <pipealloc>
80106b30:	83 c4 10             	add    $0x10,%esp
80106b33:	85 c0                	test   %eax,%eax
80106b35:	79 0a                	jns    80106b41 <sys_pipe+0x48>
    return -1;
80106b37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106b3c:	e9 8e 00 00 00       	jmp    80106bcf <sys_pipe+0xd6>
  fd0 = -1;
80106b41:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106b48:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b4b:	83 ec 0c             	sub    $0xc,%esp
80106b4e:	50                   	push   %eax
80106b4f:	e8 7c f3 ff ff       	call   80105ed0 <fdalloc>
80106b54:	83 c4 10             	add    $0x10,%esp
80106b57:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106b5a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b5e:	78 18                	js     80106b78 <sys_pipe+0x7f>
80106b60:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106b63:	83 ec 0c             	sub    $0xc,%esp
80106b66:	50                   	push   %eax
80106b67:	e8 64 f3 ff ff       	call   80105ed0 <fdalloc>
80106b6c:	83 c4 10             	add    $0x10,%esp
80106b6f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106b72:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106b76:	79 3f                	jns    80106bb7 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106b78:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106b7c:	78 14                	js     80106b92 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
80106b7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b84:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106b87:	83 c2 08             	add    $0x8,%edx
80106b8a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80106b91:	00 
    fileclose(rf);
80106b92:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106b95:	83 ec 0c             	sub    $0xc,%esp
80106b98:	50                   	push   %eax
80106b99:	e8 98 a4 ff ff       	call   80101036 <fileclose>
80106b9e:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
80106ba1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106ba4:	83 ec 0c             	sub    $0xc,%esp
80106ba7:	50                   	push   %eax
80106ba8:	e8 89 a4 ff ff       	call   80101036 <fileclose>
80106bad:	83 c4 10             	add    $0x10,%esp
    return -1;
80106bb0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106bb5:	eb 18                	jmp    80106bcf <sys_pipe+0xd6>
  }
  fd[0] = fd0;
80106bb7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106bba:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106bbd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
80106bbf:	8b 45 ec             	mov    -0x14(%ebp),%eax
80106bc2:	8d 50 04             	lea    0x4(%eax),%edx
80106bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106bc8:	89 02                	mov    %eax,(%edx)
  return 0;
80106bca:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bcf:	c9                   	leave  
80106bd0:	c3                   	ret    

80106bd1 <sys_fork>:
#include "proc.h"


int
sys_fork(void)
{
80106bd1:	55                   	push   %ebp
80106bd2:	89 e5                	mov    %esp,%ebp
80106bd4:	83 ec 08             	sub    $0x8,%esp
  return fork();
80106bd7:	e8 d6 db ff ff       	call   801047b2 <fork>
}
80106bdc:	c9                   	leave  
80106bdd:	c3                   	ret    

80106bde <sys_exit>:

int
sys_exit(void)
{
80106bde:	55                   	push   %ebp
80106bdf:	89 e5                	mov    %esp,%ebp
80106be1:	83 ec 08             	sub    $0x8,%esp
  exit();
80106be4:	e8 b0 dd ff ff       	call   80104999 <exit>
  return 0;  // not reached
80106be9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106bee:	c9                   	leave  
80106bef:	c3                   	ret    

80106bf0 <sys_wait>:

int
sys_wait(void)
{
80106bf0:	55                   	push   %ebp
80106bf1:	89 e5                	mov    %esp,%ebp
80106bf3:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106bf6:	e8 d9 de ff ff       	call   80104ad4 <wait>
}
80106bfb:	c9                   	leave  
80106bfc:	c3                   	ret    

80106bfd <sys_kill>:

int
sys_kill(void)
{
80106bfd:	55                   	push   %ebp
80106bfe:	89 e5                	mov    %esp,%ebp
80106c00:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
80106c03:	83 ec 08             	sub    $0x8,%esp
80106c06:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106c09:	50                   	push   %eax
80106c0a:	6a 00                	push   $0x0
80106c0c:	e8 0e f1 ff ff       	call   80105d1f <argint>
80106c11:	83 c4 10             	add    $0x10,%esp
80106c14:	85 c0                	test   %eax,%eax
80106c16:	79 07                	jns    80106c1f <sys_kill+0x22>
    return -1;
80106c18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c1d:	eb 0f                	jmp    80106c2e <sys_kill+0x31>
  return kill(pid);
80106c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106c22:	83 ec 0c             	sub    $0xc,%esp
80106c25:	50                   	push   %eax
80106c26:	e8 65 e3 ff ff       	call   80104f90 <kill>
80106c2b:	83 c4 10             	add    $0x10,%esp
}
80106c2e:	c9                   	leave  
80106c2f:	c3                   	ret    

80106c30 <sys_getpid>:

int
sys_getpid(void)
{
80106c30:	55                   	push   %ebp
80106c31:	89 e5                	mov    %esp,%ebp
  return proc->pid;
80106c33:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c39:	8b 40 10             	mov    0x10(%eax),%eax
}
80106c3c:	5d                   	pop    %ebp
80106c3d:	c3                   	ret    

80106c3e <sys_sbrk>:

int
sys_sbrk(void)
{
80106c3e:	55                   	push   %ebp
80106c3f:	89 e5                	mov    %esp,%ebp
80106c41:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80106c44:	83 ec 08             	sub    $0x8,%esp
80106c47:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c4a:	50                   	push   %eax
80106c4b:	6a 00                	push   $0x0
80106c4d:	e8 cd f0 ff ff       	call   80105d1f <argint>
80106c52:	83 c4 10             	add    $0x10,%esp
80106c55:	85 c0                	test   %eax,%eax
80106c57:	79 07                	jns    80106c60 <sys_sbrk+0x22>
    return -1;
80106c59:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c5e:	eb 28                	jmp    80106c88 <sys_sbrk+0x4a>
  addr = proc->sz;
80106c60:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c66:	8b 00                	mov    (%eax),%eax
80106c68:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
80106c6b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106c6e:	83 ec 0c             	sub    $0xc,%esp
80106c71:	50                   	push   %eax
80106c72:	e8 98 da ff ff       	call   8010470f <growproc>
80106c77:	83 c4 10             	add    $0x10,%esp
80106c7a:	85 c0                	test   %eax,%eax
80106c7c:	79 07                	jns    80106c85 <sys_sbrk+0x47>
    return -1;
80106c7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106c83:	eb 03                	jmp    80106c88 <sys_sbrk+0x4a>
  return addr;
80106c85:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106c88:	c9                   	leave  
80106c89:	c3                   	ret    

80106c8a <sys_sleep>:

int
sys_sleep(void)
{
80106c8a:	55                   	push   %ebp
80106c8b:	89 e5                	mov    %esp,%ebp
80106c8d:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80106c90:	83 ec 08             	sub    $0x8,%esp
80106c93:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106c96:	50                   	push   %eax
80106c97:	6a 00                	push   $0x0
80106c99:	e8 81 f0 ff ff       	call   80105d1f <argint>
80106c9e:	83 c4 10             	add    $0x10,%esp
80106ca1:	85 c0                	test   %eax,%eax
80106ca3:	79 07                	jns    80106cac <sys_sleep+0x22>
    return -1;
80106ca5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106caa:	eb 77                	jmp    80106d23 <sys_sleep+0x99>
  acquire(&tickslock);
80106cac:	83 ec 0c             	sub    $0xc,%esp
80106caf:	68 20 63 11 80       	push   $0x80116320
80106cb4:	e8 de ea ff ff       	call   80105797 <acquire>
80106cb9:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106cbc:	a1 60 6b 11 80       	mov    0x80116b60,%eax
80106cc1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
80106cc4:	eb 39                	jmp    80106cff <sys_sleep+0x75>
    if(proc->killed){
80106cc6:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ccc:	8b 40 24             	mov    0x24(%eax),%eax
80106ccf:	85 c0                	test   %eax,%eax
80106cd1:	74 17                	je     80106cea <sys_sleep+0x60>
      release(&tickslock);
80106cd3:	83 ec 0c             	sub    $0xc,%esp
80106cd6:	68 20 63 11 80       	push   $0x80116320
80106cdb:	e8 1e eb ff ff       	call   801057fe <release>
80106ce0:	83 c4 10             	add    $0x10,%esp
      return -1;
80106ce3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106ce8:	eb 39                	jmp    80106d23 <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106cea:	83 ec 08             	sub    $0x8,%esp
80106ced:	68 20 63 11 80       	push   $0x80116320
80106cf2:	68 60 6b 11 80       	push   $0x80116b60
80106cf7:	e8 48 e1 ff ff       	call   80104e44 <sleep>
80106cfc:	83 c4 10             	add    $0x10,%esp

  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106cff:	a1 60 6b 11 80       	mov    0x80116b60,%eax
80106d04:	2b 45 f4             	sub    -0xc(%ebp),%eax
80106d07:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106d0a:	39 d0                	cmp    %edx,%eax
80106d0c:	72 b8                	jb     80106cc6 <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106d0e:	83 ec 0c             	sub    $0xc,%esp
80106d11:	68 20 63 11 80       	push   $0x80116320
80106d16:	e8 e3 ea ff ff       	call   801057fe <release>
80106d1b:	83 c4 10             	add    $0x10,%esp
  return 0;
80106d1e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d23:	c9                   	leave  
80106d24:	c3                   	ret    

80106d25 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80106d25:	55                   	push   %ebp
80106d26:	89 e5                	mov    %esp,%ebp
80106d28:	83 ec 18             	sub    $0x18,%esp
  uint xticks;

  acquire(&tickslock);
80106d2b:	83 ec 0c             	sub    $0xc,%esp
80106d2e:	68 20 63 11 80       	push   $0x80116320
80106d33:	e8 5f ea ff ff       	call   80105797 <acquire>
80106d38:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
80106d3b:	a1 60 6b 11 80       	mov    0x80116b60,%eax
80106d40:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
80106d43:	83 ec 0c             	sub    $0xc,%esp
80106d46:	68 20 63 11 80       	push   $0x80116320
80106d4b:	e8 ae ea ff ff       	call   801057fe <release>
80106d50:	83 c4 10             	add    $0x10,%esp
  return xticks;
80106d53:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80106d56:	c9                   	leave  
80106d57:	c3                   	ret    

80106d58 <sys_procstat>:

//
int
sys_procstat(void)
{
80106d58:	55                   	push   %ebp
80106d59:	89 e5                	mov    %esp,%ebp
80106d5b:	83 ec 08             	sub    $0x8,%esp
  //cprintf("SE EJECUTA EL SYS_PROCSTAT\n");
  procdump();// ejecutamos la funcion procdump definida en proc.c
80106d5e:	e8 b8 e2 ff ff       	call   8010501b <procdump>
  return 0;
80106d63:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106d68:	c9                   	leave  
80106d69:	c3                   	ret    

80106d6a <sys_setpriority>:

// change the priority of the process to the specified value
//
int
sys_setpriority(void)
{
80106d6a:	55                   	push   %ebp
80106d6b:	89 e5                	mov    %esp,%ebp
80106d6d:	83 ec 18             	sub    $0x18,%esp
    int priority;
    if(argint(0, &priority) < 0){
80106d70:	83 ec 08             	sub    $0x8,%esp
80106d73:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106d76:	50                   	push   %eax
80106d77:	6a 00                	push   $0x0
80106d79:	e8 a1 ef ff ff       	call   80105d1f <argint>
80106d7e:	83 c4 10             	add    $0x10,%esp
80106d81:	85 c0                	test   %eax,%eax
80106d83:	79 07                	jns    80106d8c <sys_setpriority+0x22>
      return -1;
80106d85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106d8a:	eb 2b                	jmp    80106db7 <sys_setpriority+0x4d>
    }
    if(priority>=0 &&priority<MLFLEVELS){
80106d8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d8f:	85 c0                	test   %eax,%eax
80106d91:	78 1f                	js     80106db2 <sys_setpriority+0x48>
80106d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106d96:	83 f8 03             	cmp    $0x3,%eax
80106d99:	7f 17                	jg     80106db2 <sys_setpriority+0x48>
      proc->priority=priority;
80106d9b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106da1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106da4:	66 89 90 84 00 00 00 	mov    %dx,0x84(%eax)
      return 0;
80106dab:	b8 00 00 00 00       	mov    $0x0,%eax
80106db0:	eb 05                	jmp    80106db7 <sys_setpriority+0x4d>
    }
    else{
      return -1;
80106db2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    }

}
80106db7:	c9                   	leave  
80106db8:	c3                   	ret    

80106db9 <sys_semget>:



int
sys_semget(void)
{
80106db9:	55                   	push   %ebp
80106dba:	89 e5                	mov    %esp,%ebp
80106dbc:	83 ec 18             	sub    $0x18,%esp
  int initvalue;
  int semid;
  argint(0, &semid);
80106dbf:	83 ec 08             	sub    $0x8,%esp
80106dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106dc5:	50                   	push   %eax
80106dc6:	6a 00                	push   $0x0
80106dc8:	e8 52 ef ff ff       	call   80105d1f <argint>
80106dcd:	83 c4 10             	add    $0x10,%esp
  argint(1, &initvalue);
80106dd0:	83 ec 08             	sub    $0x8,%esp
80106dd3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106dd6:	50                   	push   %eax
80106dd7:	6a 01                	push   $0x1
80106dd9:	e8 41 ef ff ff       	call   80105d1f <argint>
80106dde:	83 c4 10             	add    $0x10,%esp
  return semget(semid,initvalue);
80106de1:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106de4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106de7:	83 ec 08             	sub    $0x8,%esp
80106dea:	52                   	push   %edx
80106deb:	50                   	push   %eax
80106dec:	e8 bf e4 ff ff       	call   801052b0 <semget>
80106df1:	83 c4 10             	add    $0x10,%esp
}
80106df4:	c9                   	leave  
80106df5:	c3                   	ret    

80106df6 <sys_semfree>:

int
sys_semfree(void)
{
80106df6:	55                   	push   %ebp
80106df7:	89 e5                	mov    %esp,%ebp
80106df9:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106dfc:	83 ec 08             	sub    $0x8,%esp
80106dff:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e02:	50                   	push   %eax
80106e03:	6a 00                	push   $0x0
80106e05:	e8 15 ef ff ff       	call   80105d1f <argint>
80106e0a:	83 c4 10             	add    $0x10,%esp
  return semfree(semid);
80106e0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e10:	83 ec 0c             	sub    $0xc,%esp
80106e13:	50                   	push   %eax
80106e14:	e8 9c e5 ff ff       	call   801053b5 <semfree>
80106e19:	83 c4 10             	add    $0x10,%esp

}
80106e1c:	c9                   	leave  
80106e1d:	c3                   	ret    

80106e1e <sys_semdown>:

int
sys_semdown(void)
{
80106e1e:	55                   	push   %ebp
80106e1f:	89 e5                	mov    %esp,%ebp
80106e21:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106e24:	83 ec 08             	sub    $0x8,%esp
80106e27:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e2a:	50                   	push   %eax
80106e2b:	6a 00                	push   $0x0
80106e2d:	e8 ed ee ff ff       	call   80105d1f <argint>
80106e32:	83 c4 10             	add    $0x10,%esp
  return semdown(semid);
80106e35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e38:	83 ec 0c             	sub    $0xc,%esp
80106e3b:	50                   	push   %eax
80106e3c:	e8 05 e6 ff ff       	call   80105446 <semdown>
80106e41:	83 c4 10             	add    $0x10,%esp
}
80106e44:	c9                   	leave  
80106e45:	c3                   	ret    

80106e46 <sys_semup>:

int
sys_semup(void)
{
80106e46:	55                   	push   %ebp
80106e47:	89 e5                	mov    %esp,%ebp
80106e49:	83 ec 18             	sub    $0x18,%esp
  int semid;
  argint(0, &semid);
80106e4c:	83 ec 08             	sub    $0x8,%esp
80106e4f:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106e52:	50                   	push   %eax
80106e53:	6a 00                	push   $0x0
80106e55:	e8 c5 ee ff ff       	call   80105d1f <argint>
80106e5a:	83 c4 10             	add    $0x10,%esp
  return semup(semid);
80106e5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106e60:	83 ec 0c             	sub    $0xc,%esp
80106e63:	50                   	push   %eax
80106e64:	e8 c5 e6 ff ff       	call   8010552e <semup>
80106e69:	83 c4 10             	add    $0x10,%esp
}
80106e6c:	c9                   	leave  
80106e6d:	c3                   	ret    

80106e6e <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106e6e:	55                   	push   %ebp
80106e6f:	89 e5                	mov    %esp,%ebp
80106e71:	83 ec 08             	sub    $0x8,%esp
80106e74:	8b 55 08             	mov    0x8(%ebp),%edx
80106e77:	8b 45 0c             	mov    0xc(%ebp),%eax
80106e7a:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106e7e:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106e81:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106e85:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106e89:	ee                   	out    %al,(%dx)
}
80106e8a:	90                   	nop
80106e8b:	c9                   	leave  
80106e8c:	c3                   	ret    

80106e8d <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
80106e8d:	55                   	push   %ebp
80106e8e:	89 e5                	mov    %esp,%ebp
80106e90:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
80106e93:	6a 34                	push   $0x34
80106e95:	6a 43                	push   $0x43
80106e97:	e8 d2 ff ff ff       	call   80106e6e <outb>
80106e9c:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
80106e9f:	68 9c 00 00 00       	push   $0x9c
80106ea4:	6a 40                	push   $0x40
80106ea6:	e8 c3 ff ff ff       	call   80106e6e <outb>
80106eab:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
80106eae:	6a 2e                	push   $0x2e
80106eb0:	6a 40                	push   $0x40
80106eb2:	e8 b7 ff ff ff       	call   80106e6e <outb>
80106eb7:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
80106eba:	83 ec 0c             	sub    $0xc,%esp
80106ebd:	6a 00                	push   $0x0
80106ebf:	e8 d8 cf ff ff       	call   80103e9c <picenable>
80106ec4:	83 c4 10             	add    $0x10,%esp
}
80106ec7:	90                   	nop
80106ec8:	c9                   	leave  
80106ec9:	c3                   	ret    

80106eca <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80106eca:	1e                   	push   %ds
  pushl %es
80106ecb:	06                   	push   %es
  pushl %fs
80106ecc:	0f a0                	push   %fs
  pushl %gs
80106ece:	0f a8                	push   %gs
  pushal
80106ed0:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106ed1:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106ed5:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106ed7:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
80106ed9:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
80106edd:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106edf:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106ee1:	54                   	push   %esp
  call trap
80106ee2:	e8 d7 01 00 00       	call   801070be <trap>
  addl $4, %esp
80106ee7:	83 c4 04             	add    $0x4,%esp

80106eea <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80106eea:	61                   	popa   
  popl %gs
80106eeb:	0f a9                	pop    %gs
  popl %fs
80106eed:	0f a1                	pop    %fs
  popl %es
80106eef:	07                   	pop    %es
  popl %ds
80106ef0:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106ef1:	83 c4 08             	add    $0x8,%esp
  iret
80106ef4:	cf                   	iret   

80106ef5 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106ef5:	55                   	push   %ebp
80106ef6:	89 e5                	mov    %esp,%ebp
80106ef8:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
80106efb:	8b 45 0c             	mov    0xc(%ebp),%eax
80106efe:	83 e8 01             	sub    $0x1,%eax
80106f01:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106f05:	8b 45 08             	mov    0x8(%ebp),%eax
80106f08:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106f0c:	8b 45 08             	mov    0x8(%ebp),%eax
80106f0f:	c1 e8 10             	shr    $0x10,%eax
80106f12:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106f16:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106f19:	0f 01 18             	lidtl  (%eax)
}
80106f1c:	90                   	nop
80106f1d:	c9                   	leave  
80106f1e:	c3                   	ret    

80106f1f <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106f1f:	55                   	push   %ebp
80106f20:	89 e5                	mov    %esp,%ebp
80106f22:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106f25:	0f 20 d0             	mov    %cr2,%eax
80106f28:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
80106f2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80106f2e:	c9                   	leave  
80106f2f:	c3                   	ret    

80106f30 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106f30:	55                   	push   %ebp
80106f31:	89 e5                	mov    %esp,%ebp
80106f33:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106f36:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106f3d:	e9 c3 00 00 00       	jmp    80107005 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106f42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f45:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106f4c:	89 c2                	mov    %eax,%edx
80106f4e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f51:	66 89 14 c5 60 63 11 	mov    %dx,-0x7fee9ca0(,%eax,8)
80106f58:	80 
80106f59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f5c:	66 c7 04 c5 62 63 11 	movw   $0x8,-0x7fee9c9e(,%eax,8)
80106f63:	80 08 00 
80106f66:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f69:	0f b6 14 c5 64 63 11 	movzbl -0x7fee9c9c(,%eax,8),%edx
80106f70:	80 
80106f71:	83 e2 e0             	and    $0xffffffe0,%edx
80106f74:	88 14 c5 64 63 11 80 	mov    %dl,-0x7fee9c9c(,%eax,8)
80106f7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f7e:	0f b6 14 c5 64 63 11 	movzbl -0x7fee9c9c(,%eax,8),%edx
80106f85:	80 
80106f86:	83 e2 1f             	and    $0x1f,%edx
80106f89:	88 14 c5 64 63 11 80 	mov    %dl,-0x7fee9c9c(,%eax,8)
80106f90:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106f93:	0f b6 14 c5 65 63 11 	movzbl -0x7fee9c9b(,%eax,8),%edx
80106f9a:	80 
80106f9b:	83 e2 f0             	and    $0xfffffff0,%edx
80106f9e:	83 ca 0e             	or     $0xe,%edx
80106fa1:	88 14 c5 65 63 11 80 	mov    %dl,-0x7fee9c9b(,%eax,8)
80106fa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fab:	0f b6 14 c5 65 63 11 	movzbl -0x7fee9c9b(,%eax,8),%edx
80106fb2:	80 
80106fb3:	83 e2 ef             	and    $0xffffffef,%edx
80106fb6:	88 14 c5 65 63 11 80 	mov    %dl,-0x7fee9c9b(,%eax,8)
80106fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fc0:	0f b6 14 c5 65 63 11 	movzbl -0x7fee9c9b(,%eax,8),%edx
80106fc7:	80 
80106fc8:	83 e2 9f             	and    $0xffffff9f,%edx
80106fcb:	88 14 c5 65 63 11 80 	mov    %dl,-0x7fee9c9b(,%eax,8)
80106fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fd5:	0f b6 14 c5 65 63 11 	movzbl -0x7fee9c9b(,%eax,8),%edx
80106fdc:	80 
80106fdd:	83 ca 80             	or     $0xffffff80,%edx
80106fe0:	88 14 c5 65 63 11 80 	mov    %dl,-0x7fee9c9b(,%eax,8)
80106fe7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106fea:	8b 04 85 b0 c0 10 80 	mov    -0x7fef3f50(,%eax,4),%eax
80106ff1:	c1 e8 10             	shr    $0x10,%eax
80106ff4:	89 c2                	mov    %eax,%edx
80106ff6:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ff9:	66 89 14 c5 66 63 11 	mov    %dx,-0x7fee9c9a(,%eax,8)
80107000:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80107001:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80107005:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010700c:	0f 8e 30 ff ff ff    	jle    80106f42 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80107012:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107017:	66 a3 60 65 11 80    	mov    %ax,0x80116560
8010701d:	66 c7 05 62 65 11 80 	movw   $0x8,0x80116562
80107024:	08 00 
80107026:	0f b6 05 64 65 11 80 	movzbl 0x80116564,%eax
8010702d:	83 e0 e0             	and    $0xffffffe0,%eax
80107030:	a2 64 65 11 80       	mov    %al,0x80116564
80107035:	0f b6 05 64 65 11 80 	movzbl 0x80116564,%eax
8010703c:	83 e0 1f             	and    $0x1f,%eax
8010703f:	a2 64 65 11 80       	mov    %al,0x80116564
80107044:	0f b6 05 65 65 11 80 	movzbl 0x80116565,%eax
8010704b:	83 c8 0f             	or     $0xf,%eax
8010704e:	a2 65 65 11 80       	mov    %al,0x80116565
80107053:	0f b6 05 65 65 11 80 	movzbl 0x80116565,%eax
8010705a:	83 e0 ef             	and    $0xffffffef,%eax
8010705d:	a2 65 65 11 80       	mov    %al,0x80116565
80107062:	0f b6 05 65 65 11 80 	movzbl 0x80116565,%eax
80107069:	83 c8 60             	or     $0x60,%eax
8010706c:	a2 65 65 11 80       	mov    %al,0x80116565
80107071:	0f b6 05 65 65 11 80 	movzbl 0x80116565,%eax
80107078:	83 c8 80             	or     $0xffffff80,%eax
8010707b:	a2 65 65 11 80       	mov    %al,0x80116565
80107080:	a1 b0 c1 10 80       	mov    0x8010c1b0,%eax
80107085:	c1 e8 10             	shr    $0x10,%eax
80107088:	66 a3 66 65 11 80    	mov    %ax,0x80116566

  initlock(&tickslock, "time");
8010708e:	83 ec 08             	sub    $0x8,%esp
80107091:	68 ec 93 10 80       	push   $0x801093ec
80107096:	68 20 63 11 80       	push   $0x80116320
8010709b:	e8 d5 e6 ff ff       	call   80105775 <initlock>
801070a0:	83 c4 10             	add    $0x10,%esp
}
801070a3:	90                   	nop
801070a4:	c9                   	leave  
801070a5:	c3                   	ret    

801070a6 <idtinit>:

void
idtinit(void)
{
801070a6:	55                   	push   %ebp
801070a7:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801070a9:	68 00 08 00 00       	push   $0x800
801070ae:	68 60 63 11 80       	push   $0x80116360
801070b3:	e8 3d fe ff ff       	call   80106ef5 <lidt>
801070b8:	83 c4 08             	add    $0x8,%esp
}
801070bb:	90                   	nop
801070bc:	c9                   	leave  
801070bd:	c3                   	ret    

801070be <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
801070be:	55                   	push   %ebp
801070bf:	89 e5                	mov    %esp,%ebp
801070c1:	57                   	push   %edi
801070c2:	56                   	push   %esi
801070c3:	53                   	push   %ebx
801070c4:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
801070c7:	8b 45 08             	mov    0x8(%ebp),%eax
801070ca:	8b 40 30             	mov    0x30(%eax),%eax
801070cd:	83 f8 40             	cmp    $0x40,%eax
801070d0:	75 3e                	jne    80107110 <trap+0x52>
    if(proc->killed)
801070d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070d8:	8b 40 24             	mov    0x24(%eax),%eax
801070db:	85 c0                	test   %eax,%eax
801070dd:	74 05                	je     801070e4 <trap+0x26>
      exit();
801070df:	e8 b5 d8 ff ff       	call   80104999 <exit>
    proc->tf = tf;
801070e4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070ea:	8b 55 08             	mov    0x8(%ebp),%edx
801070ed:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
801070f0:	e8 e0 ec ff ff       	call   80105dd5 <syscall>
    if(proc->killed)
801070f5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801070fb:	8b 40 24             	mov    0x24(%eax),%eax
801070fe:	85 c0                	test   %eax,%eax
80107100:	0f 84 93 02 00 00    	je     80107399 <trap+0x2db>
      exit();
80107106:	e8 8e d8 ff ff       	call   80104999 <exit>
    return;
8010710b:	e9 89 02 00 00       	jmp    80107399 <trap+0x2db>
  }

  switch(tf->trapno){
80107110:	8b 45 08             	mov    0x8(%ebp),%eax
80107113:	8b 40 30             	mov    0x30(%eax),%eax
80107116:	83 e8 20             	sub    $0x20,%eax
80107119:	83 f8 1f             	cmp    $0x1f,%eax
8010711c:	0f 87 c0 00 00 00    	ja     801071e2 <trap+0x124>
80107122:	8b 04 85 94 94 10 80 	mov    -0x7fef6b6c(,%eax,4),%eax
80107129:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
8010712b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107131:	0f b6 00             	movzbl (%eax),%eax
80107134:	84 c0                	test   %al,%al
80107136:	75 3d                	jne    80107175 <trap+0xb7>
      acquire(&tickslock);
80107138:	83 ec 0c             	sub    $0xc,%esp
8010713b:	68 20 63 11 80       	push   $0x80116320
80107140:	e8 52 e6 ff ff       	call   80105797 <acquire>
80107145:	83 c4 10             	add    $0x10,%esp
      ticks++;
80107148:	a1 60 6b 11 80       	mov    0x80116b60,%eax
8010714d:	83 c0 01             	add    $0x1,%eax
80107150:	a3 60 6b 11 80       	mov    %eax,0x80116b60
      wakeup(&ticks);
80107155:	83 ec 0c             	sub    $0xc,%esp
80107158:	68 60 6b 11 80       	push   $0x80116b60
8010715d:	e8 f7 dd ff ff       	call   80104f59 <wakeup>
80107162:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80107165:	83 ec 0c             	sub    $0xc,%esp
80107168:	68 20 63 11 80       	push   $0x80116320
8010716d:	e8 8c e6 ff ff       	call   801057fe <release>
80107172:	83 c4 10             	add    $0x10,%esp
    }
    lapiceoi();
80107175:	e8 0a be ff ff       	call   80102f84 <lapiceoi>
    break;
8010717a:	e9 1c 01 00 00       	jmp    8010729b <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
8010717f:	e8 13 b6 ff ff       	call   80102797 <ideintr>
    lapiceoi();
80107184:	e8 fb bd ff ff       	call   80102f84 <lapiceoi>
    break;
80107189:	e9 0d 01 00 00       	jmp    8010729b <trap+0x1dd>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
8010718e:	e8 f3 bb ff ff       	call   80102d86 <kbdintr>
    lapiceoi();
80107193:	e8 ec bd ff ff       	call   80102f84 <lapiceoi>
    break;
80107198:	e9 fe 00 00 00       	jmp    8010729b <trap+0x1dd>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
8010719d:	e8 d8 03 00 00       	call   8010757a <uartintr>
    lapiceoi();
801071a2:	e8 dd bd ff ff       	call   80102f84 <lapiceoi>
    break;
801071a7:	e9 ef 00 00 00       	jmp    8010729b <trap+0x1dd>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801071ac:	8b 45 08             	mov    0x8(%ebp),%eax
801071af:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
801071b2:	8b 45 08             	mov    0x8(%ebp),%eax
801071b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801071b9:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
801071bc:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801071c2:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801071c5:	0f b6 c0             	movzbl %al,%eax
801071c8:	51                   	push   %ecx
801071c9:	52                   	push   %edx
801071ca:	50                   	push   %eax
801071cb:	68 f4 93 10 80       	push   $0x801093f4
801071d0:	e8 f1 91 ff ff       	call   801003c6 <cprintf>
801071d5:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
801071d8:	e8 a7 bd ff ff       	call   80102f84 <lapiceoi>
    break;
801071dd:	e9 b9 00 00 00       	jmp    8010729b <trap+0x1dd>

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
801071e2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801071e8:	85 c0                	test   %eax,%eax
801071ea:	74 11                	je     801071fd <trap+0x13f>
801071ec:	8b 45 08             	mov    0x8(%ebp),%eax
801071ef:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801071f3:	0f b7 c0             	movzwl %ax,%eax
801071f6:	83 e0 03             	and    $0x3,%eax
801071f9:	85 c0                	test   %eax,%eax
801071fb:	75 40                	jne    8010723d <trap+0x17f>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801071fd:	e8 1d fd ff ff       	call   80106f1f <rcr2>
80107202:	89 c3                	mov    %eax,%ebx
80107204:	8b 45 08             	mov    0x8(%ebp),%eax
80107207:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
8010720a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107210:	0f b6 00             	movzbl (%eax),%eax

  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80107213:	0f b6 d0             	movzbl %al,%edx
80107216:	8b 45 08             	mov    0x8(%ebp),%eax
80107219:	8b 40 30             	mov    0x30(%eax),%eax
8010721c:	83 ec 0c             	sub    $0xc,%esp
8010721f:	53                   	push   %ebx
80107220:	51                   	push   %ecx
80107221:	52                   	push   %edx
80107222:	50                   	push   %eax
80107223:	68 18 94 10 80       	push   $0x80109418
80107228:	e8 99 91 ff ff       	call   801003c6 <cprintf>
8010722d:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80107230:	83 ec 0c             	sub    $0xc,%esp
80107233:	68 4a 94 10 80       	push   $0x8010944a
80107238:	e8 29 93 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010723d:	e8 dd fc ff ff       	call   80106f1f <rcr2>
80107242:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107245:	8b 45 08             	mov    0x8(%ebp),%eax
80107248:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
8010724b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80107251:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107254:	0f b6 d8             	movzbl %al,%ebx
80107257:	8b 45 08             	mov    0x8(%ebp),%eax
8010725a:	8b 48 34             	mov    0x34(%eax),%ecx
8010725d:	8b 45 08             	mov    0x8(%ebp),%eax
80107260:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
80107263:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107269:	8d 78 6c             	lea    0x6c(%eax),%edi
8010726c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80107272:	8b 40 10             	mov    0x10(%eax),%eax
80107275:	ff 75 e4             	pushl  -0x1c(%ebp)
80107278:	56                   	push   %esi
80107279:	53                   	push   %ebx
8010727a:	51                   	push   %ecx
8010727b:	52                   	push   %edx
8010727c:	57                   	push   %edi
8010727d:	50                   	push   %eax
8010727e:	68 50 94 10 80       	push   $0x80109450
80107283:	e8 3e 91 ff ff       	call   801003c6 <cprintf>
80107288:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip,
            rcr2());
    proc->killed = 1;
8010728b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107291:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80107298:	eb 01                	jmp    8010729b <trap+0x1dd>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
8010729a:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
8010729b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072a1:	85 c0                	test   %eax,%eax
801072a3:	74 24                	je     801072c9 <trap+0x20b>
801072a5:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072ab:	8b 40 24             	mov    0x24(%eax),%eax
801072ae:	85 c0                	test   %eax,%eax
801072b0:	74 17                	je     801072c9 <trap+0x20b>
801072b2:	8b 45 08             	mov    0x8(%ebp),%eax
801072b5:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
801072b9:	0f b7 c0             	movzwl %ax,%eax
801072bc:	83 e0 03             	and    $0x3,%eax
801072bf:	83 f8 03             	cmp    $0x3,%eax
801072c2:	75 05                	jne    801072c9 <trap+0x20b>
    exit();
801072c4:	e8 d0 d6 ff ff       	call   80104999 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER){
801072c9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072cf:	85 c0                	test   %eax,%eax
801072d1:	0f 84 92 00 00 00    	je     80107369 <trap+0x2ab>
801072d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072dd:	8b 40 0c             	mov    0xc(%eax),%eax
801072e0:	83 f8 04             	cmp    $0x4,%eax
801072e3:	0f 85 80 00 00 00    	jne    80107369 <trap+0x2ab>
801072e9:	8b 45 08             	mov    0x8(%ebp),%eax
801072ec:	8b 40 30             	mov    0x30(%eax),%eax
801072ef:	83 f8 20             	cmp    $0x20,%eax
801072f2:	75 75                	jne    80107369 <trap+0x2ab>
    proc->ticks++;
801072f4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801072fa:	0f b7 50 7c          	movzwl 0x7c(%eax),%edx
801072fe:	83 c2 01             	add    $0x1,%edx
80107301:	66 89 50 7c          	mov    %dx,0x7c(%eax)
    if(proc->ticks % TIMESLICE==0){
80107305:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010730b:	0f b7 48 7c          	movzwl 0x7c(%eax),%ecx
8010730f:	0f b7 c1             	movzwl %cx,%eax
80107312:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
80107318:	c1 e8 10             	shr    $0x10,%eax
8010731b:	89 c2                	mov    %eax,%edx
8010731d:	66 c1 ea 05          	shr    $0x5,%dx
80107321:	89 d0                	mov    %edx,%eax
80107323:	c1 e0 02             	shl    $0x2,%eax
80107326:	01 d0                	add    %edx,%eax
80107328:	c1 e0 03             	shl    $0x3,%eax
8010732b:	29 c1                	sub    %eax,%ecx
8010732d:	89 ca                	mov    %ecx,%edx
8010732f:	66 85 d2             	test   %dx,%dx
80107332:	75 11                	jne    80107345 <trap+0x287>
      //cprintf("proceso pid=%d ejecuta el yield en el tick %d \n",proc->pid,proc->ticks);
      proc->ticks=0;
80107334:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010733a:	66 c7 40 7c 00 00    	movw   $0x0,0x7c(%eax)
      yield();
80107340:	e8 5d da ff ff       	call   80104da2 <yield>
    }
    if(ticks % TICKSFORAGING ==0){
80107345:	8b 0d 60 6b 11 80    	mov    0x80116b60,%ecx
8010734b:	ba 1f 85 eb 51       	mov    $0x51eb851f,%edx
80107350:	89 c8                	mov    %ecx,%eax
80107352:	f7 e2                	mul    %edx
80107354:	89 d0                	mov    %edx,%eax
80107356:	c1 e8 05             	shr    $0x5,%eax
80107359:	6b c0 64             	imul   $0x64,%eax,%eax
8010735c:	29 c1                	sub    %eax,%ecx
8010735e:	89 c8                	mov    %ecx,%eax
80107360:	85 c0                	test   %eax,%eax
80107362:	75 05                	jne    80107369 <trap+0x2ab>
      //cprintf("ticks = %d pid %d\n",ticks,proc->pid);
      aging();
80107364:	e8 40 de ff ff       	call   801051a9 <aging>
    }

  }
  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80107369:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010736f:	85 c0                	test   %eax,%eax
80107371:	74 27                	je     8010739a <trap+0x2dc>
80107373:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80107379:	8b 40 24             	mov    0x24(%eax),%eax
8010737c:	85 c0                	test   %eax,%eax
8010737e:	74 1a                	je     8010739a <trap+0x2dc>
80107380:	8b 45 08             	mov    0x8(%ebp),%eax
80107383:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80107387:	0f b7 c0             	movzwl %ax,%eax
8010738a:	83 e0 03             	and    $0x3,%eax
8010738d:	83 f8 03             	cmp    $0x3,%eax
80107390:	75 08                	jne    8010739a <trap+0x2dc>
    exit();
80107392:	e8 02 d6 ff ff       	call   80104999 <exit>
80107397:	eb 01                	jmp    8010739a <trap+0x2dc>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80107399:	90                   	nop

  }
  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
8010739a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010739d:	5b                   	pop    %ebx
8010739e:	5e                   	pop    %esi
8010739f:	5f                   	pop    %edi
801073a0:	5d                   	pop    %ebp
801073a1:	c3                   	ret    

801073a2 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801073a2:	55                   	push   %ebp
801073a3:	89 e5                	mov    %esp,%ebp
801073a5:	83 ec 14             	sub    $0x14,%esp
801073a8:	8b 45 08             	mov    0x8(%ebp),%eax
801073ab:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801073af:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801073b3:	89 c2                	mov    %eax,%edx
801073b5:	ec                   	in     (%dx),%al
801073b6:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801073b9:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801073bd:	c9                   	leave  
801073be:	c3                   	ret    

801073bf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801073bf:	55                   	push   %ebp
801073c0:	89 e5                	mov    %esp,%ebp
801073c2:	83 ec 08             	sub    $0x8,%esp
801073c5:	8b 55 08             	mov    0x8(%ebp),%edx
801073c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801073cb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801073cf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801073d2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801073d6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801073da:	ee                   	out    %al,(%dx)
}
801073db:	90                   	nop
801073dc:	c9                   	leave  
801073dd:	c3                   	ret    

801073de <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
801073de:	55                   	push   %ebp
801073df:	89 e5                	mov    %esp,%ebp
801073e1:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
801073e4:	6a 00                	push   $0x0
801073e6:	68 fa 03 00 00       	push   $0x3fa
801073eb:	e8 cf ff ff ff       	call   801073bf <outb>
801073f0:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
801073f3:	68 80 00 00 00       	push   $0x80
801073f8:	68 fb 03 00 00       	push   $0x3fb
801073fd:	e8 bd ff ff ff       	call   801073bf <outb>
80107402:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80107405:	6a 0c                	push   $0xc
80107407:	68 f8 03 00 00       	push   $0x3f8
8010740c:	e8 ae ff ff ff       	call   801073bf <outb>
80107411:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80107414:	6a 00                	push   $0x0
80107416:	68 f9 03 00 00       	push   $0x3f9
8010741b:	e8 9f ff ff ff       	call   801073bf <outb>
80107420:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80107423:	6a 03                	push   $0x3
80107425:	68 fb 03 00 00       	push   $0x3fb
8010742a:	e8 90 ff ff ff       	call   801073bf <outb>
8010742f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80107432:	6a 00                	push   $0x0
80107434:	68 fc 03 00 00       	push   $0x3fc
80107439:	e8 81 ff ff ff       	call   801073bf <outb>
8010743e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80107441:	6a 01                	push   $0x1
80107443:	68 f9 03 00 00       	push   $0x3f9
80107448:	e8 72 ff ff ff       	call   801073bf <outb>
8010744d:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80107450:	68 fd 03 00 00       	push   $0x3fd
80107455:	e8 48 ff ff ff       	call   801073a2 <inb>
8010745a:	83 c4 04             	add    $0x4,%esp
8010745d:	3c ff                	cmp    $0xff,%al
8010745f:	74 6e                	je     801074cf <uartinit+0xf1>
    return;
  uart = 1;
80107461:	c7 05 6c c6 10 80 01 	movl   $0x1,0x8010c66c
80107468:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
8010746b:	68 fa 03 00 00       	push   $0x3fa
80107470:	e8 2d ff ff ff       	call   801073a2 <inb>
80107475:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80107478:	68 f8 03 00 00       	push   $0x3f8
8010747d:	e8 20 ff ff ff       	call   801073a2 <inb>
80107482:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80107485:	83 ec 0c             	sub    $0xc,%esp
80107488:	6a 04                	push   $0x4
8010748a:	e8 0d ca ff ff       	call   80103e9c <picenable>
8010748f:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80107492:	83 ec 08             	sub    $0x8,%esp
80107495:	6a 00                	push   $0x0
80107497:	6a 04                	push   $0x4
80107499:	e8 9b b5 ff ff       	call   80102a39 <ioapicenable>
8010749e:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074a1:	c7 45 f4 14 95 10 80 	movl   $0x80109514,-0xc(%ebp)
801074a8:	eb 19                	jmp    801074c3 <uartinit+0xe5>
    uartputc(*p);
801074aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074ad:	0f b6 00             	movzbl (%eax),%eax
801074b0:	0f be c0             	movsbl %al,%eax
801074b3:	83 ec 0c             	sub    $0xc,%esp
801074b6:	50                   	push   %eax
801074b7:	e8 16 00 00 00       	call   801074d2 <uartputc>
801074bc:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
801074bf:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801074c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801074c6:	0f b6 00             	movzbl (%eax),%eax
801074c9:	84 c0                	test   %al,%al
801074cb:	75 dd                	jne    801074aa <uartinit+0xcc>
801074cd:	eb 01                	jmp    801074d0 <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
801074cf:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
801074d0:	c9                   	leave  
801074d1:	c3                   	ret    

801074d2 <uartputc>:

void
uartputc(int c)
{
801074d2:	55                   	push   %ebp
801074d3:	89 e5                	mov    %esp,%ebp
801074d5:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
801074d8:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
801074dd:	85 c0                	test   %eax,%eax
801074df:	74 53                	je     80107534 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801074e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801074e8:	eb 11                	jmp    801074fb <uartputc+0x29>
    microdelay(10);
801074ea:	83 ec 0c             	sub    $0xc,%esp
801074ed:	6a 0a                	push   $0xa
801074ef:	e8 ab ba ff ff       	call   80102f9f <microdelay>
801074f4:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801074f7:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801074fb:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
801074ff:	7f 1a                	jg     8010751b <uartputc+0x49>
80107501:	83 ec 0c             	sub    $0xc,%esp
80107504:	68 fd 03 00 00       	push   $0x3fd
80107509:	e8 94 fe ff ff       	call   801073a2 <inb>
8010750e:	83 c4 10             	add    $0x10,%esp
80107511:	0f b6 c0             	movzbl %al,%eax
80107514:	83 e0 20             	and    $0x20,%eax
80107517:	85 c0                	test   %eax,%eax
80107519:	74 cf                	je     801074ea <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
8010751b:	8b 45 08             	mov    0x8(%ebp),%eax
8010751e:	0f b6 c0             	movzbl %al,%eax
80107521:	83 ec 08             	sub    $0x8,%esp
80107524:	50                   	push   %eax
80107525:	68 f8 03 00 00       	push   $0x3f8
8010752a:	e8 90 fe ff ff       	call   801073bf <outb>
8010752f:	83 c4 10             	add    $0x10,%esp
80107532:	eb 01                	jmp    80107535 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80107534:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80107535:	c9                   	leave  
80107536:	c3                   	ret    

80107537 <uartgetc>:

static int
uartgetc(void)
{
80107537:	55                   	push   %ebp
80107538:	89 e5                	mov    %esp,%ebp
  if(!uart)
8010753a:	a1 6c c6 10 80       	mov    0x8010c66c,%eax
8010753f:	85 c0                	test   %eax,%eax
80107541:	75 07                	jne    8010754a <uartgetc+0x13>
    return -1;
80107543:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107548:	eb 2e                	jmp    80107578 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
8010754a:	68 fd 03 00 00       	push   $0x3fd
8010754f:	e8 4e fe ff ff       	call   801073a2 <inb>
80107554:	83 c4 04             	add    $0x4,%esp
80107557:	0f b6 c0             	movzbl %al,%eax
8010755a:	83 e0 01             	and    $0x1,%eax
8010755d:	85 c0                	test   %eax,%eax
8010755f:	75 07                	jne    80107568 <uartgetc+0x31>
    return -1;
80107561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107566:	eb 10                	jmp    80107578 <uartgetc+0x41>
  return inb(COM1+0);
80107568:	68 f8 03 00 00       	push   $0x3f8
8010756d:	e8 30 fe ff ff       	call   801073a2 <inb>
80107572:	83 c4 04             	add    $0x4,%esp
80107575:	0f b6 c0             	movzbl %al,%eax
}
80107578:	c9                   	leave  
80107579:	c3                   	ret    

8010757a <uartintr>:

void
uartintr(void)
{
8010757a:	55                   	push   %ebp
8010757b:	89 e5                	mov    %esp,%ebp
8010757d:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80107580:	83 ec 0c             	sub    $0xc,%esp
80107583:	68 37 75 10 80       	push   $0x80107537
80107588:	e8 50 92 ff ff       	call   801007dd <consoleintr>
8010758d:	83 c4 10             	add    $0x10,%esp
}
80107590:	90                   	nop
80107591:	c9                   	leave  
80107592:	c3                   	ret    

80107593 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80107593:	6a 00                	push   $0x0
  pushl $0
80107595:	6a 00                	push   $0x0
  jmp alltraps
80107597:	e9 2e f9 ff ff       	jmp    80106eca <alltraps>

8010759c <vector1>:
.globl vector1
vector1:
  pushl $0
8010759c:	6a 00                	push   $0x0
  pushl $1
8010759e:	6a 01                	push   $0x1
  jmp alltraps
801075a0:	e9 25 f9 ff ff       	jmp    80106eca <alltraps>

801075a5 <vector2>:
.globl vector2
vector2:
  pushl $0
801075a5:	6a 00                	push   $0x0
  pushl $2
801075a7:	6a 02                	push   $0x2
  jmp alltraps
801075a9:	e9 1c f9 ff ff       	jmp    80106eca <alltraps>

801075ae <vector3>:
.globl vector3
vector3:
  pushl $0
801075ae:	6a 00                	push   $0x0
  pushl $3
801075b0:	6a 03                	push   $0x3
  jmp alltraps
801075b2:	e9 13 f9 ff ff       	jmp    80106eca <alltraps>

801075b7 <vector4>:
.globl vector4
vector4:
  pushl $0
801075b7:	6a 00                	push   $0x0
  pushl $4
801075b9:	6a 04                	push   $0x4
  jmp alltraps
801075bb:	e9 0a f9 ff ff       	jmp    80106eca <alltraps>

801075c0 <vector5>:
.globl vector5
vector5:
  pushl $0
801075c0:	6a 00                	push   $0x0
  pushl $5
801075c2:	6a 05                	push   $0x5
  jmp alltraps
801075c4:	e9 01 f9 ff ff       	jmp    80106eca <alltraps>

801075c9 <vector6>:
.globl vector6
vector6:
  pushl $0
801075c9:	6a 00                	push   $0x0
  pushl $6
801075cb:	6a 06                	push   $0x6
  jmp alltraps
801075cd:	e9 f8 f8 ff ff       	jmp    80106eca <alltraps>

801075d2 <vector7>:
.globl vector7
vector7:
  pushl $0
801075d2:	6a 00                	push   $0x0
  pushl $7
801075d4:	6a 07                	push   $0x7
  jmp alltraps
801075d6:	e9 ef f8 ff ff       	jmp    80106eca <alltraps>

801075db <vector8>:
.globl vector8
vector8:
  pushl $8
801075db:	6a 08                	push   $0x8
  jmp alltraps
801075dd:	e9 e8 f8 ff ff       	jmp    80106eca <alltraps>

801075e2 <vector9>:
.globl vector9
vector9:
  pushl $0
801075e2:	6a 00                	push   $0x0
  pushl $9
801075e4:	6a 09                	push   $0x9
  jmp alltraps
801075e6:	e9 df f8 ff ff       	jmp    80106eca <alltraps>

801075eb <vector10>:
.globl vector10
vector10:
  pushl $10
801075eb:	6a 0a                	push   $0xa
  jmp alltraps
801075ed:	e9 d8 f8 ff ff       	jmp    80106eca <alltraps>

801075f2 <vector11>:
.globl vector11
vector11:
  pushl $11
801075f2:	6a 0b                	push   $0xb
  jmp alltraps
801075f4:	e9 d1 f8 ff ff       	jmp    80106eca <alltraps>

801075f9 <vector12>:
.globl vector12
vector12:
  pushl $12
801075f9:	6a 0c                	push   $0xc
  jmp alltraps
801075fb:	e9 ca f8 ff ff       	jmp    80106eca <alltraps>

80107600 <vector13>:
.globl vector13
vector13:
  pushl $13
80107600:	6a 0d                	push   $0xd
  jmp alltraps
80107602:	e9 c3 f8 ff ff       	jmp    80106eca <alltraps>

80107607 <vector14>:
.globl vector14
vector14:
  pushl $14
80107607:	6a 0e                	push   $0xe
  jmp alltraps
80107609:	e9 bc f8 ff ff       	jmp    80106eca <alltraps>

8010760e <vector15>:
.globl vector15
vector15:
  pushl $0
8010760e:	6a 00                	push   $0x0
  pushl $15
80107610:	6a 0f                	push   $0xf
  jmp alltraps
80107612:	e9 b3 f8 ff ff       	jmp    80106eca <alltraps>

80107617 <vector16>:
.globl vector16
vector16:
  pushl $0
80107617:	6a 00                	push   $0x0
  pushl $16
80107619:	6a 10                	push   $0x10
  jmp alltraps
8010761b:	e9 aa f8 ff ff       	jmp    80106eca <alltraps>

80107620 <vector17>:
.globl vector17
vector17:
  pushl $17
80107620:	6a 11                	push   $0x11
  jmp alltraps
80107622:	e9 a3 f8 ff ff       	jmp    80106eca <alltraps>

80107627 <vector18>:
.globl vector18
vector18:
  pushl $0
80107627:	6a 00                	push   $0x0
  pushl $18
80107629:	6a 12                	push   $0x12
  jmp alltraps
8010762b:	e9 9a f8 ff ff       	jmp    80106eca <alltraps>

80107630 <vector19>:
.globl vector19
vector19:
  pushl $0
80107630:	6a 00                	push   $0x0
  pushl $19
80107632:	6a 13                	push   $0x13
  jmp alltraps
80107634:	e9 91 f8 ff ff       	jmp    80106eca <alltraps>

80107639 <vector20>:
.globl vector20
vector20:
  pushl $0
80107639:	6a 00                	push   $0x0
  pushl $20
8010763b:	6a 14                	push   $0x14
  jmp alltraps
8010763d:	e9 88 f8 ff ff       	jmp    80106eca <alltraps>

80107642 <vector21>:
.globl vector21
vector21:
  pushl $0
80107642:	6a 00                	push   $0x0
  pushl $21
80107644:	6a 15                	push   $0x15
  jmp alltraps
80107646:	e9 7f f8 ff ff       	jmp    80106eca <alltraps>

8010764b <vector22>:
.globl vector22
vector22:
  pushl $0
8010764b:	6a 00                	push   $0x0
  pushl $22
8010764d:	6a 16                	push   $0x16
  jmp alltraps
8010764f:	e9 76 f8 ff ff       	jmp    80106eca <alltraps>

80107654 <vector23>:
.globl vector23
vector23:
  pushl $0
80107654:	6a 00                	push   $0x0
  pushl $23
80107656:	6a 17                	push   $0x17
  jmp alltraps
80107658:	e9 6d f8 ff ff       	jmp    80106eca <alltraps>

8010765d <vector24>:
.globl vector24
vector24:
  pushl $0
8010765d:	6a 00                	push   $0x0
  pushl $24
8010765f:	6a 18                	push   $0x18
  jmp alltraps
80107661:	e9 64 f8 ff ff       	jmp    80106eca <alltraps>

80107666 <vector25>:
.globl vector25
vector25:
  pushl $0
80107666:	6a 00                	push   $0x0
  pushl $25
80107668:	6a 19                	push   $0x19
  jmp alltraps
8010766a:	e9 5b f8 ff ff       	jmp    80106eca <alltraps>

8010766f <vector26>:
.globl vector26
vector26:
  pushl $0
8010766f:	6a 00                	push   $0x0
  pushl $26
80107671:	6a 1a                	push   $0x1a
  jmp alltraps
80107673:	e9 52 f8 ff ff       	jmp    80106eca <alltraps>

80107678 <vector27>:
.globl vector27
vector27:
  pushl $0
80107678:	6a 00                	push   $0x0
  pushl $27
8010767a:	6a 1b                	push   $0x1b
  jmp alltraps
8010767c:	e9 49 f8 ff ff       	jmp    80106eca <alltraps>

80107681 <vector28>:
.globl vector28
vector28:
  pushl $0
80107681:	6a 00                	push   $0x0
  pushl $28
80107683:	6a 1c                	push   $0x1c
  jmp alltraps
80107685:	e9 40 f8 ff ff       	jmp    80106eca <alltraps>

8010768a <vector29>:
.globl vector29
vector29:
  pushl $0
8010768a:	6a 00                	push   $0x0
  pushl $29
8010768c:	6a 1d                	push   $0x1d
  jmp alltraps
8010768e:	e9 37 f8 ff ff       	jmp    80106eca <alltraps>

80107693 <vector30>:
.globl vector30
vector30:
  pushl $0
80107693:	6a 00                	push   $0x0
  pushl $30
80107695:	6a 1e                	push   $0x1e
  jmp alltraps
80107697:	e9 2e f8 ff ff       	jmp    80106eca <alltraps>

8010769c <vector31>:
.globl vector31
vector31:
  pushl $0
8010769c:	6a 00                	push   $0x0
  pushl $31
8010769e:	6a 1f                	push   $0x1f
  jmp alltraps
801076a0:	e9 25 f8 ff ff       	jmp    80106eca <alltraps>

801076a5 <vector32>:
.globl vector32
vector32:
  pushl $0
801076a5:	6a 00                	push   $0x0
  pushl $32
801076a7:	6a 20                	push   $0x20
  jmp alltraps
801076a9:	e9 1c f8 ff ff       	jmp    80106eca <alltraps>

801076ae <vector33>:
.globl vector33
vector33:
  pushl $0
801076ae:	6a 00                	push   $0x0
  pushl $33
801076b0:	6a 21                	push   $0x21
  jmp alltraps
801076b2:	e9 13 f8 ff ff       	jmp    80106eca <alltraps>

801076b7 <vector34>:
.globl vector34
vector34:
  pushl $0
801076b7:	6a 00                	push   $0x0
  pushl $34
801076b9:	6a 22                	push   $0x22
  jmp alltraps
801076bb:	e9 0a f8 ff ff       	jmp    80106eca <alltraps>

801076c0 <vector35>:
.globl vector35
vector35:
  pushl $0
801076c0:	6a 00                	push   $0x0
  pushl $35
801076c2:	6a 23                	push   $0x23
  jmp alltraps
801076c4:	e9 01 f8 ff ff       	jmp    80106eca <alltraps>

801076c9 <vector36>:
.globl vector36
vector36:
  pushl $0
801076c9:	6a 00                	push   $0x0
  pushl $36
801076cb:	6a 24                	push   $0x24
  jmp alltraps
801076cd:	e9 f8 f7 ff ff       	jmp    80106eca <alltraps>

801076d2 <vector37>:
.globl vector37
vector37:
  pushl $0
801076d2:	6a 00                	push   $0x0
  pushl $37
801076d4:	6a 25                	push   $0x25
  jmp alltraps
801076d6:	e9 ef f7 ff ff       	jmp    80106eca <alltraps>

801076db <vector38>:
.globl vector38
vector38:
  pushl $0
801076db:	6a 00                	push   $0x0
  pushl $38
801076dd:	6a 26                	push   $0x26
  jmp alltraps
801076df:	e9 e6 f7 ff ff       	jmp    80106eca <alltraps>

801076e4 <vector39>:
.globl vector39
vector39:
  pushl $0
801076e4:	6a 00                	push   $0x0
  pushl $39
801076e6:	6a 27                	push   $0x27
  jmp alltraps
801076e8:	e9 dd f7 ff ff       	jmp    80106eca <alltraps>

801076ed <vector40>:
.globl vector40
vector40:
  pushl $0
801076ed:	6a 00                	push   $0x0
  pushl $40
801076ef:	6a 28                	push   $0x28
  jmp alltraps
801076f1:	e9 d4 f7 ff ff       	jmp    80106eca <alltraps>

801076f6 <vector41>:
.globl vector41
vector41:
  pushl $0
801076f6:	6a 00                	push   $0x0
  pushl $41
801076f8:	6a 29                	push   $0x29
  jmp alltraps
801076fa:	e9 cb f7 ff ff       	jmp    80106eca <alltraps>

801076ff <vector42>:
.globl vector42
vector42:
  pushl $0
801076ff:	6a 00                	push   $0x0
  pushl $42
80107701:	6a 2a                	push   $0x2a
  jmp alltraps
80107703:	e9 c2 f7 ff ff       	jmp    80106eca <alltraps>

80107708 <vector43>:
.globl vector43
vector43:
  pushl $0
80107708:	6a 00                	push   $0x0
  pushl $43
8010770a:	6a 2b                	push   $0x2b
  jmp alltraps
8010770c:	e9 b9 f7 ff ff       	jmp    80106eca <alltraps>

80107711 <vector44>:
.globl vector44
vector44:
  pushl $0
80107711:	6a 00                	push   $0x0
  pushl $44
80107713:	6a 2c                	push   $0x2c
  jmp alltraps
80107715:	e9 b0 f7 ff ff       	jmp    80106eca <alltraps>

8010771a <vector45>:
.globl vector45
vector45:
  pushl $0
8010771a:	6a 00                	push   $0x0
  pushl $45
8010771c:	6a 2d                	push   $0x2d
  jmp alltraps
8010771e:	e9 a7 f7 ff ff       	jmp    80106eca <alltraps>

80107723 <vector46>:
.globl vector46
vector46:
  pushl $0
80107723:	6a 00                	push   $0x0
  pushl $46
80107725:	6a 2e                	push   $0x2e
  jmp alltraps
80107727:	e9 9e f7 ff ff       	jmp    80106eca <alltraps>

8010772c <vector47>:
.globl vector47
vector47:
  pushl $0
8010772c:	6a 00                	push   $0x0
  pushl $47
8010772e:	6a 2f                	push   $0x2f
  jmp alltraps
80107730:	e9 95 f7 ff ff       	jmp    80106eca <alltraps>

80107735 <vector48>:
.globl vector48
vector48:
  pushl $0
80107735:	6a 00                	push   $0x0
  pushl $48
80107737:	6a 30                	push   $0x30
  jmp alltraps
80107739:	e9 8c f7 ff ff       	jmp    80106eca <alltraps>

8010773e <vector49>:
.globl vector49
vector49:
  pushl $0
8010773e:	6a 00                	push   $0x0
  pushl $49
80107740:	6a 31                	push   $0x31
  jmp alltraps
80107742:	e9 83 f7 ff ff       	jmp    80106eca <alltraps>

80107747 <vector50>:
.globl vector50
vector50:
  pushl $0
80107747:	6a 00                	push   $0x0
  pushl $50
80107749:	6a 32                	push   $0x32
  jmp alltraps
8010774b:	e9 7a f7 ff ff       	jmp    80106eca <alltraps>

80107750 <vector51>:
.globl vector51
vector51:
  pushl $0
80107750:	6a 00                	push   $0x0
  pushl $51
80107752:	6a 33                	push   $0x33
  jmp alltraps
80107754:	e9 71 f7 ff ff       	jmp    80106eca <alltraps>

80107759 <vector52>:
.globl vector52
vector52:
  pushl $0
80107759:	6a 00                	push   $0x0
  pushl $52
8010775b:	6a 34                	push   $0x34
  jmp alltraps
8010775d:	e9 68 f7 ff ff       	jmp    80106eca <alltraps>

80107762 <vector53>:
.globl vector53
vector53:
  pushl $0
80107762:	6a 00                	push   $0x0
  pushl $53
80107764:	6a 35                	push   $0x35
  jmp alltraps
80107766:	e9 5f f7 ff ff       	jmp    80106eca <alltraps>

8010776b <vector54>:
.globl vector54
vector54:
  pushl $0
8010776b:	6a 00                	push   $0x0
  pushl $54
8010776d:	6a 36                	push   $0x36
  jmp alltraps
8010776f:	e9 56 f7 ff ff       	jmp    80106eca <alltraps>

80107774 <vector55>:
.globl vector55
vector55:
  pushl $0
80107774:	6a 00                	push   $0x0
  pushl $55
80107776:	6a 37                	push   $0x37
  jmp alltraps
80107778:	e9 4d f7 ff ff       	jmp    80106eca <alltraps>

8010777d <vector56>:
.globl vector56
vector56:
  pushl $0
8010777d:	6a 00                	push   $0x0
  pushl $56
8010777f:	6a 38                	push   $0x38
  jmp alltraps
80107781:	e9 44 f7 ff ff       	jmp    80106eca <alltraps>

80107786 <vector57>:
.globl vector57
vector57:
  pushl $0
80107786:	6a 00                	push   $0x0
  pushl $57
80107788:	6a 39                	push   $0x39
  jmp alltraps
8010778a:	e9 3b f7 ff ff       	jmp    80106eca <alltraps>

8010778f <vector58>:
.globl vector58
vector58:
  pushl $0
8010778f:	6a 00                	push   $0x0
  pushl $58
80107791:	6a 3a                	push   $0x3a
  jmp alltraps
80107793:	e9 32 f7 ff ff       	jmp    80106eca <alltraps>

80107798 <vector59>:
.globl vector59
vector59:
  pushl $0
80107798:	6a 00                	push   $0x0
  pushl $59
8010779a:	6a 3b                	push   $0x3b
  jmp alltraps
8010779c:	e9 29 f7 ff ff       	jmp    80106eca <alltraps>

801077a1 <vector60>:
.globl vector60
vector60:
  pushl $0
801077a1:	6a 00                	push   $0x0
  pushl $60
801077a3:	6a 3c                	push   $0x3c
  jmp alltraps
801077a5:	e9 20 f7 ff ff       	jmp    80106eca <alltraps>

801077aa <vector61>:
.globl vector61
vector61:
  pushl $0
801077aa:	6a 00                	push   $0x0
  pushl $61
801077ac:	6a 3d                	push   $0x3d
  jmp alltraps
801077ae:	e9 17 f7 ff ff       	jmp    80106eca <alltraps>

801077b3 <vector62>:
.globl vector62
vector62:
  pushl $0
801077b3:	6a 00                	push   $0x0
  pushl $62
801077b5:	6a 3e                	push   $0x3e
  jmp alltraps
801077b7:	e9 0e f7 ff ff       	jmp    80106eca <alltraps>

801077bc <vector63>:
.globl vector63
vector63:
  pushl $0
801077bc:	6a 00                	push   $0x0
  pushl $63
801077be:	6a 3f                	push   $0x3f
  jmp alltraps
801077c0:	e9 05 f7 ff ff       	jmp    80106eca <alltraps>

801077c5 <vector64>:
.globl vector64
vector64:
  pushl $0
801077c5:	6a 00                	push   $0x0
  pushl $64
801077c7:	6a 40                	push   $0x40
  jmp alltraps
801077c9:	e9 fc f6 ff ff       	jmp    80106eca <alltraps>

801077ce <vector65>:
.globl vector65
vector65:
  pushl $0
801077ce:	6a 00                	push   $0x0
  pushl $65
801077d0:	6a 41                	push   $0x41
  jmp alltraps
801077d2:	e9 f3 f6 ff ff       	jmp    80106eca <alltraps>

801077d7 <vector66>:
.globl vector66
vector66:
  pushl $0
801077d7:	6a 00                	push   $0x0
  pushl $66
801077d9:	6a 42                	push   $0x42
  jmp alltraps
801077db:	e9 ea f6 ff ff       	jmp    80106eca <alltraps>

801077e0 <vector67>:
.globl vector67
vector67:
  pushl $0
801077e0:	6a 00                	push   $0x0
  pushl $67
801077e2:	6a 43                	push   $0x43
  jmp alltraps
801077e4:	e9 e1 f6 ff ff       	jmp    80106eca <alltraps>

801077e9 <vector68>:
.globl vector68
vector68:
  pushl $0
801077e9:	6a 00                	push   $0x0
  pushl $68
801077eb:	6a 44                	push   $0x44
  jmp alltraps
801077ed:	e9 d8 f6 ff ff       	jmp    80106eca <alltraps>

801077f2 <vector69>:
.globl vector69
vector69:
  pushl $0
801077f2:	6a 00                	push   $0x0
  pushl $69
801077f4:	6a 45                	push   $0x45
  jmp alltraps
801077f6:	e9 cf f6 ff ff       	jmp    80106eca <alltraps>

801077fb <vector70>:
.globl vector70
vector70:
  pushl $0
801077fb:	6a 00                	push   $0x0
  pushl $70
801077fd:	6a 46                	push   $0x46
  jmp alltraps
801077ff:	e9 c6 f6 ff ff       	jmp    80106eca <alltraps>

80107804 <vector71>:
.globl vector71
vector71:
  pushl $0
80107804:	6a 00                	push   $0x0
  pushl $71
80107806:	6a 47                	push   $0x47
  jmp alltraps
80107808:	e9 bd f6 ff ff       	jmp    80106eca <alltraps>

8010780d <vector72>:
.globl vector72
vector72:
  pushl $0
8010780d:	6a 00                	push   $0x0
  pushl $72
8010780f:	6a 48                	push   $0x48
  jmp alltraps
80107811:	e9 b4 f6 ff ff       	jmp    80106eca <alltraps>

80107816 <vector73>:
.globl vector73
vector73:
  pushl $0
80107816:	6a 00                	push   $0x0
  pushl $73
80107818:	6a 49                	push   $0x49
  jmp alltraps
8010781a:	e9 ab f6 ff ff       	jmp    80106eca <alltraps>

8010781f <vector74>:
.globl vector74
vector74:
  pushl $0
8010781f:	6a 00                	push   $0x0
  pushl $74
80107821:	6a 4a                	push   $0x4a
  jmp alltraps
80107823:	e9 a2 f6 ff ff       	jmp    80106eca <alltraps>

80107828 <vector75>:
.globl vector75
vector75:
  pushl $0
80107828:	6a 00                	push   $0x0
  pushl $75
8010782a:	6a 4b                	push   $0x4b
  jmp alltraps
8010782c:	e9 99 f6 ff ff       	jmp    80106eca <alltraps>

80107831 <vector76>:
.globl vector76
vector76:
  pushl $0
80107831:	6a 00                	push   $0x0
  pushl $76
80107833:	6a 4c                	push   $0x4c
  jmp alltraps
80107835:	e9 90 f6 ff ff       	jmp    80106eca <alltraps>

8010783a <vector77>:
.globl vector77
vector77:
  pushl $0
8010783a:	6a 00                	push   $0x0
  pushl $77
8010783c:	6a 4d                	push   $0x4d
  jmp alltraps
8010783e:	e9 87 f6 ff ff       	jmp    80106eca <alltraps>

80107843 <vector78>:
.globl vector78
vector78:
  pushl $0
80107843:	6a 00                	push   $0x0
  pushl $78
80107845:	6a 4e                	push   $0x4e
  jmp alltraps
80107847:	e9 7e f6 ff ff       	jmp    80106eca <alltraps>

8010784c <vector79>:
.globl vector79
vector79:
  pushl $0
8010784c:	6a 00                	push   $0x0
  pushl $79
8010784e:	6a 4f                	push   $0x4f
  jmp alltraps
80107850:	e9 75 f6 ff ff       	jmp    80106eca <alltraps>

80107855 <vector80>:
.globl vector80
vector80:
  pushl $0
80107855:	6a 00                	push   $0x0
  pushl $80
80107857:	6a 50                	push   $0x50
  jmp alltraps
80107859:	e9 6c f6 ff ff       	jmp    80106eca <alltraps>

8010785e <vector81>:
.globl vector81
vector81:
  pushl $0
8010785e:	6a 00                	push   $0x0
  pushl $81
80107860:	6a 51                	push   $0x51
  jmp alltraps
80107862:	e9 63 f6 ff ff       	jmp    80106eca <alltraps>

80107867 <vector82>:
.globl vector82
vector82:
  pushl $0
80107867:	6a 00                	push   $0x0
  pushl $82
80107869:	6a 52                	push   $0x52
  jmp alltraps
8010786b:	e9 5a f6 ff ff       	jmp    80106eca <alltraps>

80107870 <vector83>:
.globl vector83
vector83:
  pushl $0
80107870:	6a 00                	push   $0x0
  pushl $83
80107872:	6a 53                	push   $0x53
  jmp alltraps
80107874:	e9 51 f6 ff ff       	jmp    80106eca <alltraps>

80107879 <vector84>:
.globl vector84
vector84:
  pushl $0
80107879:	6a 00                	push   $0x0
  pushl $84
8010787b:	6a 54                	push   $0x54
  jmp alltraps
8010787d:	e9 48 f6 ff ff       	jmp    80106eca <alltraps>

80107882 <vector85>:
.globl vector85
vector85:
  pushl $0
80107882:	6a 00                	push   $0x0
  pushl $85
80107884:	6a 55                	push   $0x55
  jmp alltraps
80107886:	e9 3f f6 ff ff       	jmp    80106eca <alltraps>

8010788b <vector86>:
.globl vector86
vector86:
  pushl $0
8010788b:	6a 00                	push   $0x0
  pushl $86
8010788d:	6a 56                	push   $0x56
  jmp alltraps
8010788f:	e9 36 f6 ff ff       	jmp    80106eca <alltraps>

80107894 <vector87>:
.globl vector87
vector87:
  pushl $0
80107894:	6a 00                	push   $0x0
  pushl $87
80107896:	6a 57                	push   $0x57
  jmp alltraps
80107898:	e9 2d f6 ff ff       	jmp    80106eca <alltraps>

8010789d <vector88>:
.globl vector88
vector88:
  pushl $0
8010789d:	6a 00                	push   $0x0
  pushl $88
8010789f:	6a 58                	push   $0x58
  jmp alltraps
801078a1:	e9 24 f6 ff ff       	jmp    80106eca <alltraps>

801078a6 <vector89>:
.globl vector89
vector89:
  pushl $0
801078a6:	6a 00                	push   $0x0
  pushl $89
801078a8:	6a 59                	push   $0x59
  jmp alltraps
801078aa:	e9 1b f6 ff ff       	jmp    80106eca <alltraps>

801078af <vector90>:
.globl vector90
vector90:
  pushl $0
801078af:	6a 00                	push   $0x0
  pushl $90
801078b1:	6a 5a                	push   $0x5a
  jmp alltraps
801078b3:	e9 12 f6 ff ff       	jmp    80106eca <alltraps>

801078b8 <vector91>:
.globl vector91
vector91:
  pushl $0
801078b8:	6a 00                	push   $0x0
  pushl $91
801078ba:	6a 5b                	push   $0x5b
  jmp alltraps
801078bc:	e9 09 f6 ff ff       	jmp    80106eca <alltraps>

801078c1 <vector92>:
.globl vector92
vector92:
  pushl $0
801078c1:	6a 00                	push   $0x0
  pushl $92
801078c3:	6a 5c                	push   $0x5c
  jmp alltraps
801078c5:	e9 00 f6 ff ff       	jmp    80106eca <alltraps>

801078ca <vector93>:
.globl vector93
vector93:
  pushl $0
801078ca:	6a 00                	push   $0x0
  pushl $93
801078cc:	6a 5d                	push   $0x5d
  jmp alltraps
801078ce:	e9 f7 f5 ff ff       	jmp    80106eca <alltraps>

801078d3 <vector94>:
.globl vector94
vector94:
  pushl $0
801078d3:	6a 00                	push   $0x0
  pushl $94
801078d5:	6a 5e                	push   $0x5e
  jmp alltraps
801078d7:	e9 ee f5 ff ff       	jmp    80106eca <alltraps>

801078dc <vector95>:
.globl vector95
vector95:
  pushl $0
801078dc:	6a 00                	push   $0x0
  pushl $95
801078de:	6a 5f                	push   $0x5f
  jmp alltraps
801078e0:	e9 e5 f5 ff ff       	jmp    80106eca <alltraps>

801078e5 <vector96>:
.globl vector96
vector96:
  pushl $0
801078e5:	6a 00                	push   $0x0
  pushl $96
801078e7:	6a 60                	push   $0x60
  jmp alltraps
801078e9:	e9 dc f5 ff ff       	jmp    80106eca <alltraps>

801078ee <vector97>:
.globl vector97
vector97:
  pushl $0
801078ee:	6a 00                	push   $0x0
  pushl $97
801078f0:	6a 61                	push   $0x61
  jmp alltraps
801078f2:	e9 d3 f5 ff ff       	jmp    80106eca <alltraps>

801078f7 <vector98>:
.globl vector98
vector98:
  pushl $0
801078f7:	6a 00                	push   $0x0
  pushl $98
801078f9:	6a 62                	push   $0x62
  jmp alltraps
801078fb:	e9 ca f5 ff ff       	jmp    80106eca <alltraps>

80107900 <vector99>:
.globl vector99
vector99:
  pushl $0
80107900:	6a 00                	push   $0x0
  pushl $99
80107902:	6a 63                	push   $0x63
  jmp alltraps
80107904:	e9 c1 f5 ff ff       	jmp    80106eca <alltraps>

80107909 <vector100>:
.globl vector100
vector100:
  pushl $0
80107909:	6a 00                	push   $0x0
  pushl $100
8010790b:	6a 64                	push   $0x64
  jmp alltraps
8010790d:	e9 b8 f5 ff ff       	jmp    80106eca <alltraps>

80107912 <vector101>:
.globl vector101
vector101:
  pushl $0
80107912:	6a 00                	push   $0x0
  pushl $101
80107914:	6a 65                	push   $0x65
  jmp alltraps
80107916:	e9 af f5 ff ff       	jmp    80106eca <alltraps>

8010791b <vector102>:
.globl vector102
vector102:
  pushl $0
8010791b:	6a 00                	push   $0x0
  pushl $102
8010791d:	6a 66                	push   $0x66
  jmp alltraps
8010791f:	e9 a6 f5 ff ff       	jmp    80106eca <alltraps>

80107924 <vector103>:
.globl vector103
vector103:
  pushl $0
80107924:	6a 00                	push   $0x0
  pushl $103
80107926:	6a 67                	push   $0x67
  jmp alltraps
80107928:	e9 9d f5 ff ff       	jmp    80106eca <alltraps>

8010792d <vector104>:
.globl vector104
vector104:
  pushl $0
8010792d:	6a 00                	push   $0x0
  pushl $104
8010792f:	6a 68                	push   $0x68
  jmp alltraps
80107931:	e9 94 f5 ff ff       	jmp    80106eca <alltraps>

80107936 <vector105>:
.globl vector105
vector105:
  pushl $0
80107936:	6a 00                	push   $0x0
  pushl $105
80107938:	6a 69                	push   $0x69
  jmp alltraps
8010793a:	e9 8b f5 ff ff       	jmp    80106eca <alltraps>

8010793f <vector106>:
.globl vector106
vector106:
  pushl $0
8010793f:	6a 00                	push   $0x0
  pushl $106
80107941:	6a 6a                	push   $0x6a
  jmp alltraps
80107943:	e9 82 f5 ff ff       	jmp    80106eca <alltraps>

80107948 <vector107>:
.globl vector107
vector107:
  pushl $0
80107948:	6a 00                	push   $0x0
  pushl $107
8010794a:	6a 6b                	push   $0x6b
  jmp alltraps
8010794c:	e9 79 f5 ff ff       	jmp    80106eca <alltraps>

80107951 <vector108>:
.globl vector108
vector108:
  pushl $0
80107951:	6a 00                	push   $0x0
  pushl $108
80107953:	6a 6c                	push   $0x6c
  jmp alltraps
80107955:	e9 70 f5 ff ff       	jmp    80106eca <alltraps>

8010795a <vector109>:
.globl vector109
vector109:
  pushl $0
8010795a:	6a 00                	push   $0x0
  pushl $109
8010795c:	6a 6d                	push   $0x6d
  jmp alltraps
8010795e:	e9 67 f5 ff ff       	jmp    80106eca <alltraps>

80107963 <vector110>:
.globl vector110
vector110:
  pushl $0
80107963:	6a 00                	push   $0x0
  pushl $110
80107965:	6a 6e                	push   $0x6e
  jmp alltraps
80107967:	e9 5e f5 ff ff       	jmp    80106eca <alltraps>

8010796c <vector111>:
.globl vector111
vector111:
  pushl $0
8010796c:	6a 00                	push   $0x0
  pushl $111
8010796e:	6a 6f                	push   $0x6f
  jmp alltraps
80107970:	e9 55 f5 ff ff       	jmp    80106eca <alltraps>

80107975 <vector112>:
.globl vector112
vector112:
  pushl $0
80107975:	6a 00                	push   $0x0
  pushl $112
80107977:	6a 70                	push   $0x70
  jmp alltraps
80107979:	e9 4c f5 ff ff       	jmp    80106eca <alltraps>

8010797e <vector113>:
.globl vector113
vector113:
  pushl $0
8010797e:	6a 00                	push   $0x0
  pushl $113
80107980:	6a 71                	push   $0x71
  jmp alltraps
80107982:	e9 43 f5 ff ff       	jmp    80106eca <alltraps>

80107987 <vector114>:
.globl vector114
vector114:
  pushl $0
80107987:	6a 00                	push   $0x0
  pushl $114
80107989:	6a 72                	push   $0x72
  jmp alltraps
8010798b:	e9 3a f5 ff ff       	jmp    80106eca <alltraps>

80107990 <vector115>:
.globl vector115
vector115:
  pushl $0
80107990:	6a 00                	push   $0x0
  pushl $115
80107992:	6a 73                	push   $0x73
  jmp alltraps
80107994:	e9 31 f5 ff ff       	jmp    80106eca <alltraps>

80107999 <vector116>:
.globl vector116
vector116:
  pushl $0
80107999:	6a 00                	push   $0x0
  pushl $116
8010799b:	6a 74                	push   $0x74
  jmp alltraps
8010799d:	e9 28 f5 ff ff       	jmp    80106eca <alltraps>

801079a2 <vector117>:
.globl vector117
vector117:
  pushl $0
801079a2:	6a 00                	push   $0x0
  pushl $117
801079a4:	6a 75                	push   $0x75
  jmp alltraps
801079a6:	e9 1f f5 ff ff       	jmp    80106eca <alltraps>

801079ab <vector118>:
.globl vector118
vector118:
  pushl $0
801079ab:	6a 00                	push   $0x0
  pushl $118
801079ad:	6a 76                	push   $0x76
  jmp alltraps
801079af:	e9 16 f5 ff ff       	jmp    80106eca <alltraps>

801079b4 <vector119>:
.globl vector119
vector119:
  pushl $0
801079b4:	6a 00                	push   $0x0
  pushl $119
801079b6:	6a 77                	push   $0x77
  jmp alltraps
801079b8:	e9 0d f5 ff ff       	jmp    80106eca <alltraps>

801079bd <vector120>:
.globl vector120
vector120:
  pushl $0
801079bd:	6a 00                	push   $0x0
  pushl $120
801079bf:	6a 78                	push   $0x78
  jmp alltraps
801079c1:	e9 04 f5 ff ff       	jmp    80106eca <alltraps>

801079c6 <vector121>:
.globl vector121
vector121:
  pushl $0
801079c6:	6a 00                	push   $0x0
  pushl $121
801079c8:	6a 79                	push   $0x79
  jmp alltraps
801079ca:	e9 fb f4 ff ff       	jmp    80106eca <alltraps>

801079cf <vector122>:
.globl vector122
vector122:
  pushl $0
801079cf:	6a 00                	push   $0x0
  pushl $122
801079d1:	6a 7a                	push   $0x7a
  jmp alltraps
801079d3:	e9 f2 f4 ff ff       	jmp    80106eca <alltraps>

801079d8 <vector123>:
.globl vector123
vector123:
  pushl $0
801079d8:	6a 00                	push   $0x0
  pushl $123
801079da:	6a 7b                	push   $0x7b
  jmp alltraps
801079dc:	e9 e9 f4 ff ff       	jmp    80106eca <alltraps>

801079e1 <vector124>:
.globl vector124
vector124:
  pushl $0
801079e1:	6a 00                	push   $0x0
  pushl $124
801079e3:	6a 7c                	push   $0x7c
  jmp alltraps
801079e5:	e9 e0 f4 ff ff       	jmp    80106eca <alltraps>

801079ea <vector125>:
.globl vector125
vector125:
  pushl $0
801079ea:	6a 00                	push   $0x0
  pushl $125
801079ec:	6a 7d                	push   $0x7d
  jmp alltraps
801079ee:	e9 d7 f4 ff ff       	jmp    80106eca <alltraps>

801079f3 <vector126>:
.globl vector126
vector126:
  pushl $0
801079f3:	6a 00                	push   $0x0
  pushl $126
801079f5:	6a 7e                	push   $0x7e
  jmp alltraps
801079f7:	e9 ce f4 ff ff       	jmp    80106eca <alltraps>

801079fc <vector127>:
.globl vector127
vector127:
  pushl $0
801079fc:	6a 00                	push   $0x0
  pushl $127
801079fe:	6a 7f                	push   $0x7f
  jmp alltraps
80107a00:	e9 c5 f4 ff ff       	jmp    80106eca <alltraps>

80107a05 <vector128>:
.globl vector128
vector128:
  pushl $0
80107a05:	6a 00                	push   $0x0
  pushl $128
80107a07:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80107a0c:	e9 b9 f4 ff ff       	jmp    80106eca <alltraps>

80107a11 <vector129>:
.globl vector129
vector129:
  pushl $0
80107a11:	6a 00                	push   $0x0
  pushl $129
80107a13:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107a18:	e9 ad f4 ff ff       	jmp    80106eca <alltraps>

80107a1d <vector130>:
.globl vector130
vector130:
  pushl $0
80107a1d:	6a 00                	push   $0x0
  pushl $130
80107a1f:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107a24:	e9 a1 f4 ff ff       	jmp    80106eca <alltraps>

80107a29 <vector131>:
.globl vector131
vector131:
  pushl $0
80107a29:	6a 00                	push   $0x0
  pushl $131
80107a2b:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80107a30:	e9 95 f4 ff ff       	jmp    80106eca <alltraps>

80107a35 <vector132>:
.globl vector132
vector132:
  pushl $0
80107a35:	6a 00                	push   $0x0
  pushl $132
80107a37:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80107a3c:	e9 89 f4 ff ff       	jmp    80106eca <alltraps>

80107a41 <vector133>:
.globl vector133
vector133:
  pushl $0
80107a41:	6a 00                	push   $0x0
  pushl $133
80107a43:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107a48:	e9 7d f4 ff ff       	jmp    80106eca <alltraps>

80107a4d <vector134>:
.globl vector134
vector134:
  pushl $0
80107a4d:	6a 00                	push   $0x0
  pushl $134
80107a4f:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107a54:	e9 71 f4 ff ff       	jmp    80106eca <alltraps>

80107a59 <vector135>:
.globl vector135
vector135:
  pushl $0
80107a59:	6a 00                	push   $0x0
  pushl $135
80107a5b:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80107a60:	e9 65 f4 ff ff       	jmp    80106eca <alltraps>

80107a65 <vector136>:
.globl vector136
vector136:
  pushl $0
80107a65:	6a 00                	push   $0x0
  pushl $136
80107a67:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80107a6c:	e9 59 f4 ff ff       	jmp    80106eca <alltraps>

80107a71 <vector137>:
.globl vector137
vector137:
  pushl $0
80107a71:	6a 00                	push   $0x0
  pushl $137
80107a73:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80107a78:	e9 4d f4 ff ff       	jmp    80106eca <alltraps>

80107a7d <vector138>:
.globl vector138
vector138:
  pushl $0
80107a7d:	6a 00                	push   $0x0
  pushl $138
80107a7f:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80107a84:	e9 41 f4 ff ff       	jmp    80106eca <alltraps>

80107a89 <vector139>:
.globl vector139
vector139:
  pushl $0
80107a89:	6a 00                	push   $0x0
  pushl $139
80107a8b:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80107a90:	e9 35 f4 ff ff       	jmp    80106eca <alltraps>

80107a95 <vector140>:
.globl vector140
vector140:
  pushl $0
80107a95:	6a 00                	push   $0x0
  pushl $140
80107a97:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80107a9c:	e9 29 f4 ff ff       	jmp    80106eca <alltraps>

80107aa1 <vector141>:
.globl vector141
vector141:
  pushl $0
80107aa1:	6a 00                	push   $0x0
  pushl $141
80107aa3:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80107aa8:	e9 1d f4 ff ff       	jmp    80106eca <alltraps>

80107aad <vector142>:
.globl vector142
vector142:
  pushl $0
80107aad:	6a 00                	push   $0x0
  pushl $142
80107aaf:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80107ab4:	e9 11 f4 ff ff       	jmp    80106eca <alltraps>

80107ab9 <vector143>:
.globl vector143
vector143:
  pushl $0
80107ab9:	6a 00                	push   $0x0
  pushl $143
80107abb:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80107ac0:	e9 05 f4 ff ff       	jmp    80106eca <alltraps>

80107ac5 <vector144>:
.globl vector144
vector144:
  pushl $0
80107ac5:	6a 00                	push   $0x0
  pushl $144
80107ac7:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80107acc:	e9 f9 f3 ff ff       	jmp    80106eca <alltraps>

80107ad1 <vector145>:
.globl vector145
vector145:
  pushl $0
80107ad1:	6a 00                	push   $0x0
  pushl $145
80107ad3:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107ad8:	e9 ed f3 ff ff       	jmp    80106eca <alltraps>

80107add <vector146>:
.globl vector146
vector146:
  pushl $0
80107add:	6a 00                	push   $0x0
  pushl $146
80107adf:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107ae4:	e9 e1 f3 ff ff       	jmp    80106eca <alltraps>

80107ae9 <vector147>:
.globl vector147
vector147:
  pushl $0
80107ae9:	6a 00                	push   $0x0
  pushl $147
80107aeb:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80107af0:	e9 d5 f3 ff ff       	jmp    80106eca <alltraps>

80107af5 <vector148>:
.globl vector148
vector148:
  pushl $0
80107af5:	6a 00                	push   $0x0
  pushl $148
80107af7:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80107afc:	e9 c9 f3 ff ff       	jmp    80106eca <alltraps>

80107b01 <vector149>:
.globl vector149
vector149:
  pushl $0
80107b01:	6a 00                	push   $0x0
  pushl $149
80107b03:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107b08:	e9 bd f3 ff ff       	jmp    80106eca <alltraps>

80107b0d <vector150>:
.globl vector150
vector150:
  pushl $0
80107b0d:	6a 00                	push   $0x0
  pushl $150
80107b0f:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107b14:	e9 b1 f3 ff ff       	jmp    80106eca <alltraps>

80107b19 <vector151>:
.globl vector151
vector151:
  pushl $0
80107b19:	6a 00                	push   $0x0
  pushl $151
80107b1b:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80107b20:	e9 a5 f3 ff ff       	jmp    80106eca <alltraps>

80107b25 <vector152>:
.globl vector152
vector152:
  pushl $0
80107b25:	6a 00                	push   $0x0
  pushl $152
80107b27:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80107b2c:	e9 99 f3 ff ff       	jmp    80106eca <alltraps>

80107b31 <vector153>:
.globl vector153
vector153:
  pushl $0
80107b31:	6a 00                	push   $0x0
  pushl $153
80107b33:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107b38:	e9 8d f3 ff ff       	jmp    80106eca <alltraps>

80107b3d <vector154>:
.globl vector154
vector154:
  pushl $0
80107b3d:	6a 00                	push   $0x0
  pushl $154
80107b3f:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107b44:	e9 81 f3 ff ff       	jmp    80106eca <alltraps>

80107b49 <vector155>:
.globl vector155
vector155:
  pushl $0
80107b49:	6a 00                	push   $0x0
  pushl $155
80107b4b:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80107b50:	e9 75 f3 ff ff       	jmp    80106eca <alltraps>

80107b55 <vector156>:
.globl vector156
vector156:
  pushl $0
80107b55:	6a 00                	push   $0x0
  pushl $156
80107b57:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80107b5c:	e9 69 f3 ff ff       	jmp    80106eca <alltraps>

80107b61 <vector157>:
.globl vector157
vector157:
  pushl $0
80107b61:	6a 00                	push   $0x0
  pushl $157
80107b63:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107b68:	e9 5d f3 ff ff       	jmp    80106eca <alltraps>

80107b6d <vector158>:
.globl vector158
vector158:
  pushl $0
80107b6d:	6a 00                	push   $0x0
  pushl $158
80107b6f:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80107b74:	e9 51 f3 ff ff       	jmp    80106eca <alltraps>

80107b79 <vector159>:
.globl vector159
vector159:
  pushl $0
80107b79:	6a 00                	push   $0x0
  pushl $159
80107b7b:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80107b80:	e9 45 f3 ff ff       	jmp    80106eca <alltraps>

80107b85 <vector160>:
.globl vector160
vector160:
  pushl $0
80107b85:	6a 00                	push   $0x0
  pushl $160
80107b87:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80107b8c:	e9 39 f3 ff ff       	jmp    80106eca <alltraps>

80107b91 <vector161>:
.globl vector161
vector161:
  pushl $0
80107b91:	6a 00                	push   $0x0
  pushl $161
80107b93:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80107b98:	e9 2d f3 ff ff       	jmp    80106eca <alltraps>

80107b9d <vector162>:
.globl vector162
vector162:
  pushl $0
80107b9d:	6a 00                	push   $0x0
  pushl $162
80107b9f:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80107ba4:	e9 21 f3 ff ff       	jmp    80106eca <alltraps>

80107ba9 <vector163>:
.globl vector163
vector163:
  pushl $0
80107ba9:	6a 00                	push   $0x0
  pushl $163
80107bab:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80107bb0:	e9 15 f3 ff ff       	jmp    80106eca <alltraps>

80107bb5 <vector164>:
.globl vector164
vector164:
  pushl $0
80107bb5:	6a 00                	push   $0x0
  pushl $164
80107bb7:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80107bbc:	e9 09 f3 ff ff       	jmp    80106eca <alltraps>

80107bc1 <vector165>:
.globl vector165
vector165:
  pushl $0
80107bc1:	6a 00                	push   $0x0
  pushl $165
80107bc3:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80107bc8:	e9 fd f2 ff ff       	jmp    80106eca <alltraps>

80107bcd <vector166>:
.globl vector166
vector166:
  pushl $0
80107bcd:	6a 00                	push   $0x0
  pushl $166
80107bcf:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107bd4:	e9 f1 f2 ff ff       	jmp    80106eca <alltraps>

80107bd9 <vector167>:
.globl vector167
vector167:
  pushl $0
80107bd9:	6a 00                	push   $0x0
  pushl $167
80107bdb:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80107be0:	e9 e5 f2 ff ff       	jmp    80106eca <alltraps>

80107be5 <vector168>:
.globl vector168
vector168:
  pushl $0
80107be5:	6a 00                	push   $0x0
  pushl $168
80107be7:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80107bec:	e9 d9 f2 ff ff       	jmp    80106eca <alltraps>

80107bf1 <vector169>:
.globl vector169
vector169:
  pushl $0
80107bf1:	6a 00                	push   $0x0
  pushl $169
80107bf3:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107bf8:	e9 cd f2 ff ff       	jmp    80106eca <alltraps>

80107bfd <vector170>:
.globl vector170
vector170:
  pushl $0
80107bfd:	6a 00                	push   $0x0
  pushl $170
80107bff:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107c04:	e9 c1 f2 ff ff       	jmp    80106eca <alltraps>

80107c09 <vector171>:
.globl vector171
vector171:
  pushl $0
80107c09:	6a 00                	push   $0x0
  pushl $171
80107c0b:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80107c10:	e9 b5 f2 ff ff       	jmp    80106eca <alltraps>

80107c15 <vector172>:
.globl vector172
vector172:
  pushl $0
80107c15:	6a 00                	push   $0x0
  pushl $172
80107c17:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80107c1c:	e9 a9 f2 ff ff       	jmp    80106eca <alltraps>

80107c21 <vector173>:
.globl vector173
vector173:
  pushl $0
80107c21:	6a 00                	push   $0x0
  pushl $173
80107c23:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107c28:	e9 9d f2 ff ff       	jmp    80106eca <alltraps>

80107c2d <vector174>:
.globl vector174
vector174:
  pushl $0
80107c2d:	6a 00                	push   $0x0
  pushl $174
80107c2f:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107c34:	e9 91 f2 ff ff       	jmp    80106eca <alltraps>

80107c39 <vector175>:
.globl vector175
vector175:
  pushl $0
80107c39:	6a 00                	push   $0x0
  pushl $175
80107c3b:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80107c40:	e9 85 f2 ff ff       	jmp    80106eca <alltraps>

80107c45 <vector176>:
.globl vector176
vector176:
  pushl $0
80107c45:	6a 00                	push   $0x0
  pushl $176
80107c47:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80107c4c:	e9 79 f2 ff ff       	jmp    80106eca <alltraps>

80107c51 <vector177>:
.globl vector177
vector177:
  pushl $0
80107c51:	6a 00                	push   $0x0
  pushl $177
80107c53:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107c58:	e9 6d f2 ff ff       	jmp    80106eca <alltraps>

80107c5d <vector178>:
.globl vector178
vector178:
  pushl $0
80107c5d:	6a 00                	push   $0x0
  pushl $178
80107c5f:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107c64:	e9 61 f2 ff ff       	jmp    80106eca <alltraps>

80107c69 <vector179>:
.globl vector179
vector179:
  pushl $0
80107c69:	6a 00                	push   $0x0
  pushl $179
80107c6b:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80107c70:	e9 55 f2 ff ff       	jmp    80106eca <alltraps>

80107c75 <vector180>:
.globl vector180
vector180:
  pushl $0
80107c75:	6a 00                	push   $0x0
  pushl $180
80107c77:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80107c7c:	e9 49 f2 ff ff       	jmp    80106eca <alltraps>

80107c81 <vector181>:
.globl vector181
vector181:
  pushl $0
80107c81:	6a 00                	push   $0x0
  pushl $181
80107c83:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80107c88:	e9 3d f2 ff ff       	jmp    80106eca <alltraps>

80107c8d <vector182>:
.globl vector182
vector182:
  pushl $0
80107c8d:	6a 00                	push   $0x0
  pushl $182
80107c8f:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80107c94:	e9 31 f2 ff ff       	jmp    80106eca <alltraps>

80107c99 <vector183>:
.globl vector183
vector183:
  pushl $0
80107c99:	6a 00                	push   $0x0
  pushl $183
80107c9b:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80107ca0:	e9 25 f2 ff ff       	jmp    80106eca <alltraps>

80107ca5 <vector184>:
.globl vector184
vector184:
  pushl $0
80107ca5:	6a 00                	push   $0x0
  pushl $184
80107ca7:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80107cac:	e9 19 f2 ff ff       	jmp    80106eca <alltraps>

80107cb1 <vector185>:
.globl vector185
vector185:
  pushl $0
80107cb1:	6a 00                	push   $0x0
  pushl $185
80107cb3:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80107cb8:	e9 0d f2 ff ff       	jmp    80106eca <alltraps>

80107cbd <vector186>:
.globl vector186
vector186:
  pushl $0
80107cbd:	6a 00                	push   $0x0
  pushl $186
80107cbf:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80107cc4:	e9 01 f2 ff ff       	jmp    80106eca <alltraps>

80107cc9 <vector187>:
.globl vector187
vector187:
  pushl $0
80107cc9:	6a 00                	push   $0x0
  pushl $187
80107ccb:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80107cd0:	e9 f5 f1 ff ff       	jmp    80106eca <alltraps>

80107cd5 <vector188>:
.globl vector188
vector188:
  pushl $0
80107cd5:	6a 00                	push   $0x0
  pushl $188
80107cd7:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80107cdc:	e9 e9 f1 ff ff       	jmp    80106eca <alltraps>

80107ce1 <vector189>:
.globl vector189
vector189:
  pushl $0
80107ce1:	6a 00                	push   $0x0
  pushl $189
80107ce3:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107ce8:	e9 dd f1 ff ff       	jmp    80106eca <alltraps>

80107ced <vector190>:
.globl vector190
vector190:
  pushl $0
80107ced:	6a 00                	push   $0x0
  pushl $190
80107cef:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107cf4:	e9 d1 f1 ff ff       	jmp    80106eca <alltraps>

80107cf9 <vector191>:
.globl vector191
vector191:
  pushl $0
80107cf9:	6a 00                	push   $0x0
  pushl $191
80107cfb:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80107d00:	e9 c5 f1 ff ff       	jmp    80106eca <alltraps>

80107d05 <vector192>:
.globl vector192
vector192:
  pushl $0
80107d05:	6a 00                	push   $0x0
  pushl $192
80107d07:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80107d0c:	e9 b9 f1 ff ff       	jmp    80106eca <alltraps>

80107d11 <vector193>:
.globl vector193
vector193:
  pushl $0
80107d11:	6a 00                	push   $0x0
  pushl $193
80107d13:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107d18:	e9 ad f1 ff ff       	jmp    80106eca <alltraps>

80107d1d <vector194>:
.globl vector194
vector194:
  pushl $0
80107d1d:	6a 00                	push   $0x0
  pushl $194
80107d1f:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107d24:	e9 a1 f1 ff ff       	jmp    80106eca <alltraps>

80107d29 <vector195>:
.globl vector195
vector195:
  pushl $0
80107d29:	6a 00                	push   $0x0
  pushl $195
80107d2b:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80107d30:	e9 95 f1 ff ff       	jmp    80106eca <alltraps>

80107d35 <vector196>:
.globl vector196
vector196:
  pushl $0
80107d35:	6a 00                	push   $0x0
  pushl $196
80107d37:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80107d3c:	e9 89 f1 ff ff       	jmp    80106eca <alltraps>

80107d41 <vector197>:
.globl vector197
vector197:
  pushl $0
80107d41:	6a 00                	push   $0x0
  pushl $197
80107d43:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107d48:	e9 7d f1 ff ff       	jmp    80106eca <alltraps>

80107d4d <vector198>:
.globl vector198
vector198:
  pushl $0
80107d4d:	6a 00                	push   $0x0
  pushl $198
80107d4f:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107d54:	e9 71 f1 ff ff       	jmp    80106eca <alltraps>

80107d59 <vector199>:
.globl vector199
vector199:
  pushl $0
80107d59:	6a 00                	push   $0x0
  pushl $199
80107d5b:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80107d60:	e9 65 f1 ff ff       	jmp    80106eca <alltraps>

80107d65 <vector200>:
.globl vector200
vector200:
  pushl $0
80107d65:	6a 00                	push   $0x0
  pushl $200
80107d67:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80107d6c:	e9 59 f1 ff ff       	jmp    80106eca <alltraps>

80107d71 <vector201>:
.globl vector201
vector201:
  pushl $0
80107d71:	6a 00                	push   $0x0
  pushl $201
80107d73:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80107d78:	e9 4d f1 ff ff       	jmp    80106eca <alltraps>

80107d7d <vector202>:
.globl vector202
vector202:
  pushl $0
80107d7d:	6a 00                	push   $0x0
  pushl $202
80107d7f:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80107d84:	e9 41 f1 ff ff       	jmp    80106eca <alltraps>

80107d89 <vector203>:
.globl vector203
vector203:
  pushl $0
80107d89:	6a 00                	push   $0x0
  pushl $203
80107d8b:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80107d90:	e9 35 f1 ff ff       	jmp    80106eca <alltraps>

80107d95 <vector204>:
.globl vector204
vector204:
  pushl $0
80107d95:	6a 00                	push   $0x0
  pushl $204
80107d97:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80107d9c:	e9 29 f1 ff ff       	jmp    80106eca <alltraps>

80107da1 <vector205>:
.globl vector205
vector205:
  pushl $0
80107da1:	6a 00                	push   $0x0
  pushl $205
80107da3:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80107da8:	e9 1d f1 ff ff       	jmp    80106eca <alltraps>

80107dad <vector206>:
.globl vector206
vector206:
  pushl $0
80107dad:	6a 00                	push   $0x0
  pushl $206
80107daf:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80107db4:	e9 11 f1 ff ff       	jmp    80106eca <alltraps>

80107db9 <vector207>:
.globl vector207
vector207:
  pushl $0
80107db9:	6a 00                	push   $0x0
  pushl $207
80107dbb:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80107dc0:	e9 05 f1 ff ff       	jmp    80106eca <alltraps>

80107dc5 <vector208>:
.globl vector208
vector208:
  pushl $0
80107dc5:	6a 00                	push   $0x0
  pushl $208
80107dc7:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80107dcc:	e9 f9 f0 ff ff       	jmp    80106eca <alltraps>

80107dd1 <vector209>:
.globl vector209
vector209:
  pushl $0
80107dd1:	6a 00                	push   $0x0
  pushl $209
80107dd3:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107dd8:	e9 ed f0 ff ff       	jmp    80106eca <alltraps>

80107ddd <vector210>:
.globl vector210
vector210:
  pushl $0
80107ddd:	6a 00                	push   $0x0
  pushl $210
80107ddf:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107de4:	e9 e1 f0 ff ff       	jmp    80106eca <alltraps>

80107de9 <vector211>:
.globl vector211
vector211:
  pushl $0
80107de9:	6a 00                	push   $0x0
  pushl $211
80107deb:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80107df0:	e9 d5 f0 ff ff       	jmp    80106eca <alltraps>

80107df5 <vector212>:
.globl vector212
vector212:
  pushl $0
80107df5:	6a 00                	push   $0x0
  pushl $212
80107df7:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80107dfc:	e9 c9 f0 ff ff       	jmp    80106eca <alltraps>

80107e01 <vector213>:
.globl vector213
vector213:
  pushl $0
80107e01:	6a 00                	push   $0x0
  pushl $213
80107e03:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107e08:	e9 bd f0 ff ff       	jmp    80106eca <alltraps>

80107e0d <vector214>:
.globl vector214
vector214:
  pushl $0
80107e0d:	6a 00                	push   $0x0
  pushl $214
80107e0f:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107e14:	e9 b1 f0 ff ff       	jmp    80106eca <alltraps>

80107e19 <vector215>:
.globl vector215
vector215:
  pushl $0
80107e19:	6a 00                	push   $0x0
  pushl $215
80107e1b:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80107e20:	e9 a5 f0 ff ff       	jmp    80106eca <alltraps>

80107e25 <vector216>:
.globl vector216
vector216:
  pushl $0
80107e25:	6a 00                	push   $0x0
  pushl $216
80107e27:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80107e2c:	e9 99 f0 ff ff       	jmp    80106eca <alltraps>

80107e31 <vector217>:
.globl vector217
vector217:
  pushl $0
80107e31:	6a 00                	push   $0x0
  pushl $217
80107e33:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107e38:	e9 8d f0 ff ff       	jmp    80106eca <alltraps>

80107e3d <vector218>:
.globl vector218
vector218:
  pushl $0
80107e3d:	6a 00                	push   $0x0
  pushl $218
80107e3f:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107e44:	e9 81 f0 ff ff       	jmp    80106eca <alltraps>

80107e49 <vector219>:
.globl vector219
vector219:
  pushl $0
80107e49:	6a 00                	push   $0x0
  pushl $219
80107e4b:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80107e50:	e9 75 f0 ff ff       	jmp    80106eca <alltraps>

80107e55 <vector220>:
.globl vector220
vector220:
  pushl $0
80107e55:	6a 00                	push   $0x0
  pushl $220
80107e57:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80107e5c:	e9 69 f0 ff ff       	jmp    80106eca <alltraps>

80107e61 <vector221>:
.globl vector221
vector221:
  pushl $0
80107e61:	6a 00                	push   $0x0
  pushl $221
80107e63:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107e68:	e9 5d f0 ff ff       	jmp    80106eca <alltraps>

80107e6d <vector222>:
.globl vector222
vector222:
  pushl $0
80107e6d:	6a 00                	push   $0x0
  pushl $222
80107e6f:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80107e74:	e9 51 f0 ff ff       	jmp    80106eca <alltraps>

80107e79 <vector223>:
.globl vector223
vector223:
  pushl $0
80107e79:	6a 00                	push   $0x0
  pushl $223
80107e7b:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80107e80:	e9 45 f0 ff ff       	jmp    80106eca <alltraps>

80107e85 <vector224>:
.globl vector224
vector224:
  pushl $0
80107e85:	6a 00                	push   $0x0
  pushl $224
80107e87:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80107e8c:	e9 39 f0 ff ff       	jmp    80106eca <alltraps>

80107e91 <vector225>:
.globl vector225
vector225:
  pushl $0
80107e91:	6a 00                	push   $0x0
  pushl $225
80107e93:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80107e98:	e9 2d f0 ff ff       	jmp    80106eca <alltraps>

80107e9d <vector226>:
.globl vector226
vector226:
  pushl $0
80107e9d:	6a 00                	push   $0x0
  pushl $226
80107e9f:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80107ea4:	e9 21 f0 ff ff       	jmp    80106eca <alltraps>

80107ea9 <vector227>:
.globl vector227
vector227:
  pushl $0
80107ea9:	6a 00                	push   $0x0
  pushl $227
80107eab:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80107eb0:	e9 15 f0 ff ff       	jmp    80106eca <alltraps>

80107eb5 <vector228>:
.globl vector228
vector228:
  pushl $0
80107eb5:	6a 00                	push   $0x0
  pushl $228
80107eb7:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80107ebc:	e9 09 f0 ff ff       	jmp    80106eca <alltraps>

80107ec1 <vector229>:
.globl vector229
vector229:
  pushl $0
80107ec1:	6a 00                	push   $0x0
  pushl $229
80107ec3:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80107ec8:	e9 fd ef ff ff       	jmp    80106eca <alltraps>

80107ecd <vector230>:
.globl vector230
vector230:
  pushl $0
80107ecd:	6a 00                	push   $0x0
  pushl $230
80107ecf:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107ed4:	e9 f1 ef ff ff       	jmp    80106eca <alltraps>

80107ed9 <vector231>:
.globl vector231
vector231:
  pushl $0
80107ed9:	6a 00                	push   $0x0
  pushl $231
80107edb:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80107ee0:	e9 e5 ef ff ff       	jmp    80106eca <alltraps>

80107ee5 <vector232>:
.globl vector232
vector232:
  pushl $0
80107ee5:	6a 00                	push   $0x0
  pushl $232
80107ee7:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80107eec:	e9 d9 ef ff ff       	jmp    80106eca <alltraps>

80107ef1 <vector233>:
.globl vector233
vector233:
  pushl $0
80107ef1:	6a 00                	push   $0x0
  pushl $233
80107ef3:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107ef8:	e9 cd ef ff ff       	jmp    80106eca <alltraps>

80107efd <vector234>:
.globl vector234
vector234:
  pushl $0
80107efd:	6a 00                	push   $0x0
  pushl $234
80107eff:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107f04:	e9 c1 ef ff ff       	jmp    80106eca <alltraps>

80107f09 <vector235>:
.globl vector235
vector235:
  pushl $0
80107f09:	6a 00                	push   $0x0
  pushl $235
80107f0b:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107f10:	e9 b5 ef ff ff       	jmp    80106eca <alltraps>

80107f15 <vector236>:
.globl vector236
vector236:
  pushl $0
80107f15:	6a 00                	push   $0x0
  pushl $236
80107f17:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80107f1c:	e9 a9 ef ff ff       	jmp    80106eca <alltraps>

80107f21 <vector237>:
.globl vector237
vector237:
  pushl $0
80107f21:	6a 00                	push   $0x0
  pushl $237
80107f23:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107f28:	e9 9d ef ff ff       	jmp    80106eca <alltraps>

80107f2d <vector238>:
.globl vector238
vector238:
  pushl $0
80107f2d:	6a 00                	push   $0x0
  pushl $238
80107f2f:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107f34:	e9 91 ef ff ff       	jmp    80106eca <alltraps>

80107f39 <vector239>:
.globl vector239
vector239:
  pushl $0
80107f39:	6a 00                	push   $0x0
  pushl $239
80107f3b:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107f40:	e9 85 ef ff ff       	jmp    80106eca <alltraps>

80107f45 <vector240>:
.globl vector240
vector240:
  pushl $0
80107f45:	6a 00                	push   $0x0
  pushl $240
80107f47:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80107f4c:	e9 79 ef ff ff       	jmp    80106eca <alltraps>

80107f51 <vector241>:
.globl vector241
vector241:
  pushl $0
80107f51:	6a 00                	push   $0x0
  pushl $241
80107f53:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107f58:	e9 6d ef ff ff       	jmp    80106eca <alltraps>

80107f5d <vector242>:
.globl vector242
vector242:
  pushl $0
80107f5d:	6a 00                	push   $0x0
  pushl $242
80107f5f:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107f64:	e9 61 ef ff ff       	jmp    80106eca <alltraps>

80107f69 <vector243>:
.globl vector243
vector243:
  pushl $0
80107f69:	6a 00                	push   $0x0
  pushl $243
80107f6b:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107f70:	e9 55 ef ff ff       	jmp    80106eca <alltraps>

80107f75 <vector244>:
.globl vector244
vector244:
  pushl $0
80107f75:	6a 00                	push   $0x0
  pushl $244
80107f77:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80107f7c:	e9 49 ef ff ff       	jmp    80106eca <alltraps>

80107f81 <vector245>:
.globl vector245
vector245:
  pushl $0
80107f81:	6a 00                	push   $0x0
  pushl $245
80107f83:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80107f88:	e9 3d ef ff ff       	jmp    80106eca <alltraps>

80107f8d <vector246>:
.globl vector246
vector246:
  pushl $0
80107f8d:	6a 00                	push   $0x0
  pushl $246
80107f8f:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80107f94:	e9 31 ef ff ff       	jmp    80106eca <alltraps>

80107f99 <vector247>:
.globl vector247
vector247:
  pushl $0
80107f99:	6a 00                	push   $0x0
  pushl $247
80107f9b:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80107fa0:	e9 25 ef ff ff       	jmp    80106eca <alltraps>

80107fa5 <vector248>:
.globl vector248
vector248:
  pushl $0
80107fa5:	6a 00                	push   $0x0
  pushl $248
80107fa7:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80107fac:	e9 19 ef ff ff       	jmp    80106eca <alltraps>

80107fb1 <vector249>:
.globl vector249
vector249:
  pushl $0
80107fb1:	6a 00                	push   $0x0
  pushl $249
80107fb3:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80107fb8:	e9 0d ef ff ff       	jmp    80106eca <alltraps>

80107fbd <vector250>:
.globl vector250
vector250:
  pushl $0
80107fbd:	6a 00                	push   $0x0
  pushl $250
80107fbf:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80107fc4:	e9 01 ef ff ff       	jmp    80106eca <alltraps>

80107fc9 <vector251>:
.globl vector251
vector251:
  pushl $0
80107fc9:	6a 00                	push   $0x0
  pushl $251
80107fcb:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80107fd0:	e9 f5 ee ff ff       	jmp    80106eca <alltraps>

80107fd5 <vector252>:
.globl vector252
vector252:
  pushl $0
80107fd5:	6a 00                	push   $0x0
  pushl $252
80107fd7:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80107fdc:	e9 e9 ee ff ff       	jmp    80106eca <alltraps>

80107fe1 <vector253>:
.globl vector253
vector253:
  pushl $0
80107fe1:	6a 00                	push   $0x0
  pushl $253
80107fe3:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107fe8:	e9 dd ee ff ff       	jmp    80106eca <alltraps>

80107fed <vector254>:
.globl vector254
vector254:
  pushl $0
80107fed:	6a 00                	push   $0x0
  pushl $254
80107fef:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107ff4:	e9 d1 ee ff ff       	jmp    80106eca <alltraps>

80107ff9 <vector255>:
.globl vector255
vector255:
  pushl $0
80107ff9:	6a 00                	push   $0x0
  pushl $255
80107ffb:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80108000:	e9 c5 ee ff ff       	jmp    80106eca <alltraps>

80108005 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80108005:	55                   	push   %ebp
80108006:	89 e5                	mov    %esp,%ebp
80108008:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010800b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010800e:	83 e8 01             	sub    $0x1,%eax
80108011:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80108015:	8b 45 08             	mov    0x8(%ebp),%eax
80108018:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010801c:	8b 45 08             	mov    0x8(%ebp),%eax
8010801f:	c1 e8 10             	shr    $0x10,%eax
80108022:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80108026:	8d 45 fa             	lea    -0x6(%ebp),%eax
80108029:	0f 01 10             	lgdtl  (%eax)
}
8010802c:	90                   	nop
8010802d:	c9                   	leave  
8010802e:	c3                   	ret    

8010802f <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010802f:	55                   	push   %ebp
80108030:	89 e5                	mov    %esp,%ebp
80108032:	83 ec 04             	sub    $0x4,%esp
80108035:	8b 45 08             	mov    0x8(%ebp),%eax
80108038:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010803c:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108040:	0f 00 d8             	ltr    %ax
}
80108043:	90                   	nop
80108044:	c9                   	leave  
80108045:	c3                   	ret    

80108046 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80108046:	55                   	push   %ebp
80108047:	89 e5                	mov    %esp,%ebp
80108049:	83 ec 04             	sub    $0x4,%esp
8010804c:	8b 45 08             	mov    0x8(%ebp),%eax
8010804f:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80108053:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80108057:	8e e8                	mov    %eax,%gs
}
80108059:	90                   	nop
8010805a:	c9                   	leave  
8010805b:	c3                   	ret    

8010805c <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010805c:	55                   	push   %ebp
8010805d:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010805f:	8b 45 08             	mov    0x8(%ebp),%eax
80108062:	0f 22 d8             	mov    %eax,%cr3
}
80108065:	90                   	nop
80108066:	5d                   	pop    %ebp
80108067:	c3                   	ret    

80108068 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80108068:	55                   	push   %ebp
80108069:	89 e5                	mov    %esp,%ebp
8010806b:	8b 45 08             	mov    0x8(%ebp),%eax
8010806e:	05 00 00 00 80       	add    $0x80000000,%eax
80108073:	5d                   	pop    %ebp
80108074:	c3                   	ret    

80108075 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
80108075:	55                   	push   %ebp
80108076:	89 e5                	mov    %esp,%ebp
80108078:	8b 45 08             	mov    0x8(%ebp),%eax
8010807b:	05 00 00 00 80       	add    $0x80000000,%eax
80108080:	5d                   	pop    %ebp
80108081:	c3                   	ret    

80108082 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
80108082:	55                   	push   %ebp
80108083:	89 e5                	mov    %esp,%ebp
80108085:	53                   	push   %ebx
80108086:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
80108089:	e8 9d ae ff ff       	call   80102f2b <cpunum>
8010808e:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80108094:	05 80 33 11 80       	add    $0x80113380,%eax
80108099:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
8010809c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010809f:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801080a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080a8:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801080ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b1:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801080b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080b8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801080bc:	83 e2 f0             	and    $0xfffffff0,%edx
801080bf:	83 ca 0a             	or     $0xa,%edx
801080c2:	88 50 7d             	mov    %dl,0x7d(%eax)
801080c5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080c8:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801080cc:	83 ca 10             	or     $0x10,%edx
801080cf:	88 50 7d             	mov    %dl,0x7d(%eax)
801080d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080d5:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801080d9:	83 e2 9f             	and    $0xffffff9f,%edx
801080dc:	88 50 7d             	mov    %dl,0x7d(%eax)
801080df:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080e2:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801080e6:	83 ca 80             	or     $0xffffff80,%edx
801080e9:	88 50 7d             	mov    %dl,0x7d(%eax)
801080ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080ef:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
801080f3:	83 ca 0f             	or     $0xf,%edx
801080f6:	88 50 7e             	mov    %dl,0x7e(%eax)
801080f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801080fc:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108100:	83 e2 ef             	and    $0xffffffef,%edx
80108103:	88 50 7e             	mov    %dl,0x7e(%eax)
80108106:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108109:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010810d:	83 e2 df             	and    $0xffffffdf,%edx
80108110:	88 50 7e             	mov    %dl,0x7e(%eax)
80108113:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108116:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
8010811a:	83 ca 40             	or     $0x40,%edx
8010811d:	88 50 7e             	mov    %dl,0x7e(%eax)
80108120:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108123:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80108127:	83 ca 80             	or     $0xffffff80,%edx
8010812a:	88 50 7e             	mov    %dl,0x7e(%eax)
8010812d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108130:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80108134:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108137:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
8010813e:	ff ff 
80108140:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108143:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
8010814a:	00 00 
8010814c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010814f:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80108156:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108159:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108160:	83 e2 f0             	and    $0xfffffff0,%edx
80108163:	83 ca 02             	or     $0x2,%edx
80108166:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010816c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010816f:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108176:	83 ca 10             	or     $0x10,%edx
80108179:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
8010817f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108182:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80108189:	83 e2 9f             	and    $0xffffff9f,%edx
8010818c:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80108192:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108195:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
8010819c:	83 ca 80             	or     $0xffffff80,%edx
8010819f:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
801081a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081a8:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081af:	83 ca 0f             	or     $0xf,%edx
801081b2:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081bb:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081c2:	83 e2 ef             	and    $0xffffffef,%edx
801081c5:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081ce:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081d5:	83 e2 df             	and    $0xffffffdf,%edx
801081d8:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081e1:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081e8:	83 ca 40             	or     $0x40,%edx
801081eb:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
801081f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801081f4:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
801081fb:	83 ca 80             	or     $0xffffff80,%edx
801081fe:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80108204:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108207:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010820e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108211:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80108218:	ff ff 
8010821a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010821d:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80108224:	00 00 
80108226:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108229:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80108230:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108233:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
8010823a:	83 e2 f0             	and    $0xfffffff0,%edx
8010823d:	83 ca 0a             	or     $0xa,%edx
80108240:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108246:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108249:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108250:	83 ca 10             	or     $0x10,%edx
80108253:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80108259:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010825c:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108263:	83 ca 60             	or     $0x60,%edx
80108266:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010826c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010826f:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80108276:	83 ca 80             	or     $0xffffff80,%edx
80108279:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
8010827f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108282:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80108289:	83 ca 0f             	or     $0xf,%edx
8010828c:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80108292:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108295:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
8010829c:	83 e2 ef             	and    $0xffffffef,%edx
8010829f:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082a8:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082af:	83 e2 df             	and    $0xffffffdf,%edx
801082b2:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082bb:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082c2:	83 ca 40             	or     $0x40,%edx
801082c5:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ce:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
801082d5:	83 ca 80             	or     $0xffffff80,%edx
801082d8:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
801082de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082e1:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
801082e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082eb:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
801082f2:	ff ff 
801082f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082f7:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
801082fe:	00 00 
80108300:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108303:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
8010830a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010830d:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108314:	83 e2 f0             	and    $0xfffffff0,%edx
80108317:	83 ca 02             	or     $0x2,%edx
8010831a:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108320:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108323:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010832a:	83 ca 10             	or     $0x10,%edx
8010832d:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108333:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108336:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010833d:	83 ca 60             	or     $0x60,%edx
80108340:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108346:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108349:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80108350:	83 ca 80             	or     $0xffffff80,%edx
80108353:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80108359:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010835c:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108363:	83 ca 0f             	or     $0xf,%edx
80108366:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010836c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010836f:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108376:	83 e2 ef             	and    $0xffffffef,%edx
80108379:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
8010837f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108382:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80108389:	83 e2 df             	and    $0xffffffdf,%edx
8010838c:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80108392:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108395:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
8010839c:	83 ca 40             	or     $0x40,%edx
8010839f:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083a8:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
801083af:	83 ca 80             	or     $0xffffff80,%edx
801083b2:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
801083b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083bb:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
801083c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083c5:	05 b4 00 00 00       	add    $0xb4,%eax
801083ca:	89 c3                	mov    %eax,%ebx
801083cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083cf:	05 b4 00 00 00       	add    $0xb4,%eax
801083d4:	c1 e8 10             	shr    $0x10,%eax
801083d7:	89 c2                	mov    %eax,%edx
801083d9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083dc:	05 b4 00 00 00       	add    $0xb4,%eax
801083e1:	c1 e8 18             	shr    $0x18,%eax
801083e4:	89 c1                	mov    %eax,%ecx
801083e6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083e9:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
801083f0:	00 00 
801083f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f5:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
801083fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083ff:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80108405:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108408:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010840f:	83 e2 f0             	and    $0xfffffff0,%edx
80108412:	83 ca 02             	or     $0x2,%edx
80108415:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010841b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010841e:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108425:	83 ca 10             	or     $0x10,%edx
80108428:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
8010842e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108431:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80108438:	83 e2 9f             	and    $0xffffff9f,%edx
8010843b:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108441:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108444:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
8010844b:	83 ca 80             	or     $0xffffff80,%edx
8010844e:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80108454:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108457:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
8010845e:	83 e2 f0             	and    $0xfffffff0,%edx
80108461:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80108467:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010846a:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108471:	83 e2 ef             	and    $0xffffffef,%edx
80108474:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010847a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010847d:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108484:	83 e2 df             	and    $0xffffffdf,%edx
80108487:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
8010848d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108490:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80108497:	83 ca 40             	or     $0x40,%edx
8010849a:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084a3:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
801084aa:	83 ca 80             	or     $0xffffff80,%edx
801084ad:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
801084b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084b6:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
801084bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bf:	83 c0 70             	add    $0x70,%eax
801084c2:	83 ec 08             	sub    $0x8,%esp
801084c5:	6a 38                	push   $0x38
801084c7:	50                   	push   %eax
801084c8:	e8 38 fb ff ff       	call   80108005 <lgdt>
801084cd:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
801084d0:	83 ec 0c             	sub    $0xc,%esp
801084d3:	6a 18                	push   $0x18
801084d5:	e8 6c fb ff ff       	call   80108046 <loadgs>
801084da:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
801084dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084e0:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
801084e6:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
801084ed:	00 00 00 00 
}
801084f1:	90                   	nop
801084f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801084f5:	c9                   	leave  
801084f6:	c3                   	ret    

801084f7 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
801084f7:	55                   	push   %ebp
801084f8:	89 e5                	mov    %esp,%ebp
801084fa:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801084fd:	8b 45 0c             	mov    0xc(%ebp),%eax
80108500:	c1 e8 16             	shr    $0x16,%eax
80108503:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010850a:	8b 45 08             	mov    0x8(%ebp),%eax
8010850d:	01 d0                	add    %edx,%eax
8010850f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80108512:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108515:	8b 00                	mov    (%eax),%eax
80108517:	83 e0 01             	and    $0x1,%eax
8010851a:	85 c0                	test   %eax,%eax
8010851c:	74 18                	je     80108536 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
8010851e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108521:	8b 00                	mov    (%eax),%eax
80108523:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108528:	50                   	push   %eax
80108529:	e8 47 fb ff ff       	call   80108075 <p2v>
8010852e:	83 c4 04             	add    $0x4,%esp
80108531:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108534:	eb 48                	jmp    8010857e <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80108536:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010853a:	74 0e                	je     8010854a <walkpgdir+0x53>
8010853c:	e8 84 a6 ff ff       	call   80102bc5 <kalloc>
80108541:	89 45 f4             	mov    %eax,-0xc(%ebp)
80108544:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108548:	75 07                	jne    80108551 <walkpgdir+0x5a>
      return 0;
8010854a:	b8 00 00 00 00       	mov    $0x0,%eax
8010854f:	eb 44                	jmp    80108595 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80108551:	83 ec 04             	sub    $0x4,%esp
80108554:	68 00 10 00 00       	push   $0x1000
80108559:	6a 00                	push   $0x0
8010855b:	ff 75 f4             	pushl  -0xc(%ebp)
8010855e:	e8 97 d4 ff ff       	call   801059fa <memset>
80108563:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80108566:	83 ec 0c             	sub    $0xc,%esp
80108569:	ff 75 f4             	pushl  -0xc(%ebp)
8010856c:	e8 f7 fa ff ff       	call   80108068 <v2p>
80108571:	83 c4 10             	add    $0x10,%esp
80108574:	83 c8 07             	or     $0x7,%eax
80108577:	89 c2                	mov    %eax,%edx
80108579:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010857c:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
8010857e:	8b 45 0c             	mov    0xc(%ebp),%eax
80108581:	c1 e8 0c             	shr    $0xc,%eax
80108584:	25 ff 03 00 00       	and    $0x3ff,%eax
80108589:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108590:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108593:	01 d0                	add    %edx,%eax
}
80108595:	c9                   	leave  
80108596:	c3                   	ret    

80108597 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80108597:	55                   	push   %ebp
80108598:	89 e5                	mov    %esp,%ebp
8010859a:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
8010859d:	8b 45 0c             	mov    0xc(%ebp),%eax
801085a0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085a5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801085a8:	8b 55 0c             	mov    0xc(%ebp),%edx
801085ab:	8b 45 10             	mov    0x10(%ebp),%eax
801085ae:	01 d0                	add    %edx,%eax
801085b0:	83 e8 01             	sub    $0x1,%eax
801085b3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
801085bb:	83 ec 04             	sub    $0x4,%esp
801085be:	6a 01                	push   $0x1
801085c0:	ff 75 f4             	pushl  -0xc(%ebp)
801085c3:	ff 75 08             	pushl  0x8(%ebp)
801085c6:	e8 2c ff ff ff       	call   801084f7 <walkpgdir>
801085cb:	83 c4 10             	add    $0x10,%esp
801085ce:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085d1:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085d5:	75 07                	jne    801085de <mappages+0x47>
      return -1;
801085d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801085dc:	eb 47                	jmp    80108625 <mappages+0x8e>
    if(*pte & PTE_P)
801085de:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e1:	8b 00                	mov    (%eax),%eax
801085e3:	83 e0 01             	and    $0x1,%eax
801085e6:	85 c0                	test   %eax,%eax
801085e8:	74 0d                	je     801085f7 <mappages+0x60>
      panic("remap");
801085ea:	83 ec 0c             	sub    $0xc,%esp
801085ed:	68 1c 95 10 80       	push   $0x8010951c
801085f2:	e8 6f 7f ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
801085f7:	8b 45 18             	mov    0x18(%ebp),%eax
801085fa:	0b 45 14             	or     0x14(%ebp),%eax
801085fd:	83 c8 01             	or     $0x1,%eax
80108600:	89 c2                	mov    %eax,%edx
80108602:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108605:	89 10                	mov    %edx,(%eax)
    if(a == last)
80108607:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010860a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010860d:	74 10                	je     8010861f <mappages+0x88>
      break;
    a += PGSIZE;
8010860f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80108616:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
8010861d:	eb 9c                	jmp    801085bb <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
8010861f:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80108620:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108625:	c9                   	leave  
80108626:	c3                   	ret    

80108627 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80108627:	55                   	push   %ebp
80108628:	89 e5                	mov    %esp,%ebp
8010862a:	53                   	push   %ebx
8010862b:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
8010862e:	e8 92 a5 ff ff       	call   80102bc5 <kalloc>
80108633:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108636:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010863a:	75 0a                	jne    80108646 <setupkvm+0x1f>
    return 0;
8010863c:	b8 00 00 00 00       	mov    $0x0,%eax
80108641:	e9 8e 00 00 00       	jmp    801086d4 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80108646:	83 ec 04             	sub    $0x4,%esp
80108649:	68 00 10 00 00       	push   $0x1000
8010864e:	6a 00                	push   $0x0
80108650:	ff 75 f0             	pushl  -0x10(%ebp)
80108653:	e8 a2 d3 ff ff       	call   801059fa <memset>
80108658:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
8010865b:	83 ec 0c             	sub    $0xc,%esp
8010865e:	68 00 00 00 0e       	push   $0xe000000
80108663:	e8 0d fa ff ff       	call   80108075 <p2v>
80108668:	83 c4 10             	add    $0x10,%esp
8010866b:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80108670:	76 0d                	jbe    8010867f <setupkvm+0x58>
    panic("PHYSTOP too high");
80108672:	83 ec 0c             	sub    $0xc,%esp
80108675:	68 22 95 10 80       	push   $0x80109522
8010867a:	e8 e7 7e ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010867f:	c7 45 f4 c0 c4 10 80 	movl   $0x8010c4c0,-0xc(%ebp)
80108686:	eb 40                	jmp    801086c8 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108688:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010868b:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
8010868e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108691:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80108694:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108697:	8b 58 08             	mov    0x8(%eax),%ebx
8010869a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869d:	8b 40 04             	mov    0x4(%eax),%eax
801086a0:	29 c3                	sub    %eax,%ebx
801086a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086a5:	8b 00                	mov    (%eax),%eax
801086a7:	83 ec 0c             	sub    $0xc,%esp
801086aa:	51                   	push   %ecx
801086ab:	52                   	push   %edx
801086ac:	53                   	push   %ebx
801086ad:	50                   	push   %eax
801086ae:	ff 75 f0             	pushl  -0x10(%ebp)
801086b1:	e8 e1 fe ff ff       	call   80108597 <mappages>
801086b6:	83 c4 20             	add    $0x20,%esp
801086b9:	85 c0                	test   %eax,%eax
801086bb:	79 07                	jns    801086c4 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
801086bd:	b8 00 00 00 00       	mov    $0x0,%eax
801086c2:	eb 10                	jmp    801086d4 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801086c4:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
801086c8:	81 7d f4 00 c5 10 80 	cmpl   $0x8010c500,-0xc(%ebp)
801086cf:	72 b7                	jb     80108688 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
801086d1:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801086d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801086d7:	c9                   	leave  
801086d8:	c3                   	ret    

801086d9 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
801086d9:	55                   	push   %ebp
801086da:	89 e5                	mov    %esp,%ebp
801086dc:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801086df:	e8 43 ff ff ff       	call   80108627 <setupkvm>
801086e4:	a3 b8 6b 11 80       	mov    %eax,0x80116bb8
  switchkvm();
801086e9:	e8 03 00 00 00       	call   801086f1 <switchkvm>
}
801086ee:	90                   	nop
801086ef:	c9                   	leave  
801086f0:	c3                   	ret    

801086f1 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801086f1:	55                   	push   %ebp
801086f2:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
801086f4:	a1 b8 6b 11 80       	mov    0x80116bb8,%eax
801086f9:	50                   	push   %eax
801086fa:	e8 69 f9 ff ff       	call   80108068 <v2p>
801086ff:	83 c4 04             	add    $0x4,%esp
80108702:	50                   	push   %eax
80108703:	e8 54 f9 ff ff       	call   8010805c <lcr3>
80108708:	83 c4 04             	add    $0x4,%esp
}
8010870b:	90                   	nop
8010870c:	c9                   	leave  
8010870d:	c3                   	ret    

8010870e <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010870e:	55                   	push   %ebp
8010870f:	89 e5                	mov    %esp,%ebp
80108711:	56                   	push   %esi
80108712:	53                   	push   %ebx
  pushcli();
80108713:	e8 dc d1 ff ff       	call   801058f4 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108718:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010871e:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108725:	83 c2 08             	add    $0x8,%edx
80108728:	89 d6                	mov    %edx,%esi
8010872a:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108731:	83 c2 08             	add    $0x8,%edx
80108734:	c1 ea 10             	shr    $0x10,%edx
80108737:	89 d3                	mov    %edx,%ebx
80108739:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108740:	83 c2 08             	add    $0x8,%edx
80108743:	c1 ea 18             	shr    $0x18,%edx
80108746:	89 d1                	mov    %edx,%ecx
80108748:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010874f:	67 00 
80108751:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108758:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
8010875e:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108765:	83 e2 f0             	and    $0xfffffff0,%edx
80108768:	83 ca 09             	or     $0x9,%edx
8010876b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108771:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108778:	83 ca 10             	or     $0x10,%edx
8010877b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108781:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108788:	83 e2 9f             	and    $0xffffff9f,%edx
8010878b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
80108791:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108798:	83 ca 80             	or     $0xffffff80,%edx
8010879b:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801087a1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087a8:	83 e2 f0             	and    $0xfffffff0,%edx
801087ab:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087b1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087b8:	83 e2 ef             	and    $0xffffffef,%edx
801087bb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087c1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087c8:	83 e2 df             	and    $0xffffffdf,%edx
801087cb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087d1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087d8:	83 ca 40             	or     $0x40,%edx
801087db:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087e1:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801087e8:	83 e2 7f             	and    $0x7f,%edx
801087eb:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801087f1:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
801087f7:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801087fd:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108804:	83 e2 ef             	and    $0xffffffef,%edx
80108807:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010880d:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108813:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108819:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010881f:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108826:	8b 52 08             	mov    0x8(%edx),%edx
80108829:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010882f:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108832:	83 ec 0c             	sub    $0xc,%esp
80108835:	6a 30                	push   $0x30
80108837:	e8 f3 f7 ff ff       	call   8010802f <ltr>
8010883c:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
8010883f:	8b 45 08             	mov    0x8(%ebp),%eax
80108842:	8b 40 04             	mov    0x4(%eax),%eax
80108845:	85 c0                	test   %eax,%eax
80108847:	75 0d                	jne    80108856 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108849:	83 ec 0c             	sub    $0xc,%esp
8010884c:	68 33 95 10 80       	push   $0x80109533
80108851:	e8 10 7d ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108856:	8b 45 08             	mov    0x8(%ebp),%eax
80108859:	8b 40 04             	mov    0x4(%eax),%eax
8010885c:	83 ec 0c             	sub    $0xc,%esp
8010885f:	50                   	push   %eax
80108860:	e8 03 f8 ff ff       	call   80108068 <v2p>
80108865:	83 c4 10             	add    $0x10,%esp
80108868:	83 ec 0c             	sub    $0xc,%esp
8010886b:	50                   	push   %eax
8010886c:	e8 eb f7 ff ff       	call   8010805c <lcr3>
80108871:	83 c4 10             	add    $0x10,%esp
  popcli();
80108874:	e8 c0 d0 ff ff       	call   80105939 <popcli>
}
80108879:	90                   	nop
8010887a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010887d:	5b                   	pop    %ebx
8010887e:	5e                   	pop    %esi
8010887f:	5d                   	pop    %ebp
80108880:	c3                   	ret    

80108881 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80108881:	55                   	push   %ebp
80108882:	89 e5                	mov    %esp,%ebp
80108884:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
80108887:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
8010888e:	76 0d                	jbe    8010889d <inituvm+0x1c>
    panic("inituvm: more than a page");
80108890:	83 ec 0c             	sub    $0xc,%esp
80108893:	68 47 95 10 80       	push   $0x80109547
80108898:	e8 c9 7c ff ff       	call   80100566 <panic>
  mem = kalloc();
8010889d:	e8 23 a3 ff ff       	call   80102bc5 <kalloc>
801088a2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801088a5:	83 ec 04             	sub    $0x4,%esp
801088a8:	68 00 10 00 00       	push   $0x1000
801088ad:	6a 00                	push   $0x0
801088af:	ff 75 f4             	pushl  -0xc(%ebp)
801088b2:	e8 43 d1 ff ff       	call   801059fa <memset>
801088b7:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801088ba:	83 ec 0c             	sub    $0xc,%esp
801088bd:	ff 75 f4             	pushl  -0xc(%ebp)
801088c0:	e8 a3 f7 ff ff       	call   80108068 <v2p>
801088c5:	83 c4 10             	add    $0x10,%esp
801088c8:	83 ec 0c             	sub    $0xc,%esp
801088cb:	6a 06                	push   $0x6
801088cd:	50                   	push   %eax
801088ce:	68 00 10 00 00       	push   $0x1000
801088d3:	6a 00                	push   $0x0
801088d5:	ff 75 08             	pushl  0x8(%ebp)
801088d8:	e8 ba fc ff ff       	call   80108597 <mappages>
801088dd:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
801088e0:	83 ec 04             	sub    $0x4,%esp
801088e3:	ff 75 10             	pushl  0x10(%ebp)
801088e6:	ff 75 0c             	pushl  0xc(%ebp)
801088e9:	ff 75 f4             	pushl  -0xc(%ebp)
801088ec:	e8 c8 d1 ff ff       	call   80105ab9 <memmove>
801088f1:	83 c4 10             	add    $0x10,%esp
}
801088f4:	90                   	nop
801088f5:	c9                   	leave  
801088f6:	c3                   	ret    

801088f7 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
801088f7:	55                   	push   %ebp
801088f8:	89 e5                	mov    %esp,%ebp
801088fa:	53                   	push   %ebx
801088fb:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
801088fe:	8b 45 0c             	mov    0xc(%ebp),%eax
80108901:	25 ff 0f 00 00       	and    $0xfff,%eax
80108906:	85 c0                	test   %eax,%eax
80108908:	74 0d                	je     80108917 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
8010890a:	83 ec 0c             	sub    $0xc,%esp
8010890d:	68 64 95 10 80       	push   $0x80109564
80108912:	e8 4f 7c ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108917:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010891e:	e9 95 00 00 00       	jmp    801089b8 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108923:	8b 55 0c             	mov    0xc(%ebp),%edx
80108926:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108929:	01 d0                	add    %edx,%eax
8010892b:	83 ec 04             	sub    $0x4,%esp
8010892e:	6a 00                	push   $0x0
80108930:	50                   	push   %eax
80108931:	ff 75 08             	pushl  0x8(%ebp)
80108934:	e8 be fb ff ff       	call   801084f7 <walkpgdir>
80108939:	83 c4 10             	add    $0x10,%esp
8010893c:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010893f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108943:	75 0d                	jne    80108952 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108945:	83 ec 0c             	sub    $0xc,%esp
80108948:	68 87 95 10 80       	push   $0x80109587
8010894d:	e8 14 7c ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108952:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108955:	8b 00                	mov    (%eax),%eax
80108957:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010895c:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010895f:	8b 45 18             	mov    0x18(%ebp),%eax
80108962:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108965:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010896a:	77 0b                	ja     80108977 <loaduvm+0x80>
      n = sz - i;
8010896c:	8b 45 18             	mov    0x18(%ebp),%eax
8010896f:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108972:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108975:	eb 07                	jmp    8010897e <loaduvm+0x87>
    else
      n = PGSIZE;
80108977:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
8010897e:	8b 55 14             	mov    0x14(%ebp),%edx
80108981:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108984:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80108987:	83 ec 0c             	sub    $0xc,%esp
8010898a:	ff 75 e8             	pushl  -0x18(%ebp)
8010898d:	e8 e3 f6 ff ff       	call   80108075 <p2v>
80108992:	83 c4 10             	add    $0x10,%esp
80108995:	ff 75 f0             	pushl  -0x10(%ebp)
80108998:	53                   	push   %ebx
80108999:	50                   	push   %eax
8010899a:	ff 75 10             	pushl  0x10(%ebp)
8010899d:	e8 d1 94 ff ff       	call   80101e73 <readi>
801089a2:	83 c4 10             	add    $0x10,%esp
801089a5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801089a8:	74 07                	je     801089b1 <loaduvm+0xba>
      return -1;
801089aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801089af:	eb 18                	jmp    801089c9 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801089b1:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801089b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801089bb:	3b 45 18             	cmp    0x18(%ebp),%eax
801089be:	0f 82 5f ff ff ff    	jb     80108923 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801089c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801089c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801089cc:	c9                   	leave  
801089cd:	c3                   	ret    

801089ce <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801089ce:	55                   	push   %ebp
801089cf:	89 e5                	mov    %esp,%ebp
801089d1:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
801089d4:	8b 45 10             	mov    0x10(%ebp),%eax
801089d7:	85 c0                	test   %eax,%eax
801089d9:	79 0a                	jns    801089e5 <allocuvm+0x17>
    return 0;
801089db:	b8 00 00 00 00       	mov    $0x0,%eax
801089e0:	e9 b0 00 00 00       	jmp    80108a95 <allocuvm+0xc7>
  if(newsz < oldsz)
801089e5:	8b 45 10             	mov    0x10(%ebp),%eax
801089e8:	3b 45 0c             	cmp    0xc(%ebp),%eax
801089eb:	73 08                	jae    801089f5 <allocuvm+0x27>
    return oldsz;
801089ed:	8b 45 0c             	mov    0xc(%ebp),%eax
801089f0:	e9 a0 00 00 00       	jmp    80108a95 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
801089f5:	8b 45 0c             	mov    0xc(%ebp),%eax
801089f8:	05 ff 0f 00 00       	add    $0xfff,%eax
801089fd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108a02:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108a05:	eb 7f                	jmp    80108a86 <allocuvm+0xb8>
    mem = kalloc();
80108a07:	e8 b9 a1 ff ff       	call   80102bc5 <kalloc>
80108a0c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
80108a0f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108a13:	75 2b                	jne    80108a40 <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108a15:	83 ec 0c             	sub    $0xc,%esp
80108a18:	68 a5 95 10 80       	push   $0x801095a5
80108a1d:	e8 a4 79 ff ff       	call   801003c6 <cprintf>
80108a22:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108a25:	83 ec 04             	sub    $0x4,%esp
80108a28:	ff 75 0c             	pushl  0xc(%ebp)
80108a2b:	ff 75 10             	pushl  0x10(%ebp)
80108a2e:	ff 75 08             	pushl  0x8(%ebp)
80108a31:	e8 61 00 00 00       	call   80108a97 <deallocuvm>
80108a36:	83 c4 10             	add    $0x10,%esp
      return 0;
80108a39:	b8 00 00 00 00       	mov    $0x0,%eax
80108a3e:	eb 55                	jmp    80108a95 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
80108a40:	83 ec 04             	sub    $0x4,%esp
80108a43:	68 00 10 00 00       	push   $0x1000
80108a48:	6a 00                	push   $0x0
80108a4a:	ff 75 f0             	pushl  -0x10(%ebp)
80108a4d:	e8 a8 cf ff ff       	call   801059fa <memset>
80108a52:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108a55:	83 ec 0c             	sub    $0xc,%esp
80108a58:	ff 75 f0             	pushl  -0x10(%ebp)
80108a5b:	e8 08 f6 ff ff       	call   80108068 <v2p>
80108a60:	83 c4 10             	add    $0x10,%esp
80108a63:	89 c2                	mov    %eax,%edx
80108a65:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a68:	83 ec 0c             	sub    $0xc,%esp
80108a6b:	6a 06                	push   $0x6
80108a6d:	52                   	push   %edx
80108a6e:	68 00 10 00 00       	push   $0x1000
80108a73:	50                   	push   %eax
80108a74:	ff 75 08             	pushl  0x8(%ebp)
80108a77:	e8 1b fb ff ff       	call   80108597 <mappages>
80108a7c:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
80108a7f:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108a86:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108a89:	3b 45 10             	cmp    0x10(%ebp),%eax
80108a8c:	0f 82 75 ff ff ff    	jb     80108a07 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
80108a92:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108a95:	c9                   	leave  
80108a96:	c3                   	ret    

80108a97 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80108a97:	55                   	push   %ebp
80108a98:	89 e5                	mov    %esp,%ebp
80108a9a:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80108a9d:	8b 45 10             	mov    0x10(%ebp),%eax
80108aa0:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108aa3:	72 08                	jb     80108aad <deallocuvm+0x16>
    return oldsz;
80108aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
80108aa8:	e9 a5 00 00 00       	jmp    80108b52 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
80108aad:	8b 45 10             	mov    0x10(%ebp),%eax
80108ab0:	05 ff 0f 00 00       	add    $0xfff,%eax
80108ab5:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108aba:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80108abd:	e9 81 00 00 00       	jmp    80108b43 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
80108ac2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ac5:	83 ec 04             	sub    $0x4,%esp
80108ac8:	6a 00                	push   $0x0
80108aca:	50                   	push   %eax
80108acb:	ff 75 08             	pushl  0x8(%ebp)
80108ace:	e8 24 fa ff ff       	call   801084f7 <walkpgdir>
80108ad3:	83 c4 10             	add    $0x10,%esp
80108ad6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108ad9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108add:	75 09                	jne    80108ae8 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
80108adf:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108ae6:	eb 54                	jmp    80108b3c <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108ae8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108aeb:	8b 00                	mov    (%eax),%eax
80108aed:	83 e0 01             	and    $0x1,%eax
80108af0:	85 c0                	test   %eax,%eax
80108af2:	74 48                	je     80108b3c <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108af4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108af7:	8b 00                	mov    (%eax),%eax
80108af9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108afe:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108b01:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108b05:	75 0d                	jne    80108b14 <deallocuvm+0x7d>
        panic("kfree");
80108b07:	83 ec 0c             	sub    $0xc,%esp
80108b0a:	68 bd 95 10 80       	push   $0x801095bd
80108b0f:	e8 52 7a ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108b14:	83 ec 0c             	sub    $0xc,%esp
80108b17:	ff 75 ec             	pushl  -0x14(%ebp)
80108b1a:	e8 56 f5 ff ff       	call   80108075 <p2v>
80108b1f:	83 c4 10             	add    $0x10,%esp
80108b22:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108b25:	83 ec 0c             	sub    $0xc,%esp
80108b28:	ff 75 e8             	pushl  -0x18(%ebp)
80108b2b:	e8 f8 9f ff ff       	call   80102b28 <kfree>
80108b30:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108b36:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
80108b3c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b46:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108b49:	0f 82 73 ff ff ff    	jb     80108ac2 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
80108b4f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108b52:	c9                   	leave  
80108b53:	c3                   	ret    

80108b54 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108b54:	55                   	push   %ebp
80108b55:	89 e5                	mov    %esp,%ebp
80108b57:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108b5a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80108b5e:	75 0d                	jne    80108b6d <freevm+0x19>
    panic("freevm: no pgdir");
80108b60:	83 ec 0c             	sub    $0xc,%esp
80108b63:	68 c3 95 10 80       	push   $0x801095c3
80108b68:	e8 f9 79 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
80108b6d:	83 ec 04             	sub    $0x4,%esp
80108b70:	6a 00                	push   $0x0
80108b72:	68 00 00 00 80       	push   $0x80000000
80108b77:	ff 75 08             	pushl  0x8(%ebp)
80108b7a:	e8 18 ff ff ff       	call   80108a97 <deallocuvm>
80108b7f:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80108b82:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108b89:	eb 4f                	jmp    80108bda <freevm+0x86>
    if(pgdir[i] & PTE_P){
80108b8b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108b8e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108b95:	8b 45 08             	mov    0x8(%ebp),%eax
80108b98:	01 d0                	add    %edx,%eax
80108b9a:	8b 00                	mov    (%eax),%eax
80108b9c:	83 e0 01             	and    $0x1,%eax
80108b9f:	85 c0                	test   %eax,%eax
80108ba1:	74 33                	je     80108bd6 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
80108ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108ba6:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80108bad:	8b 45 08             	mov    0x8(%ebp),%eax
80108bb0:	01 d0                	add    %edx,%eax
80108bb2:	8b 00                	mov    (%eax),%eax
80108bb4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108bb9:	83 ec 0c             	sub    $0xc,%esp
80108bbc:	50                   	push   %eax
80108bbd:	e8 b3 f4 ff ff       	call   80108075 <p2v>
80108bc2:	83 c4 10             	add    $0x10,%esp
80108bc5:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
80108bc8:	83 ec 0c             	sub    $0xc,%esp
80108bcb:	ff 75 f0             	pushl  -0x10(%ebp)
80108bce:	e8 55 9f ff ff       	call   80102b28 <kfree>
80108bd3:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108bd6:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108bda:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108be1:	76 a8                	jbe    80108b8b <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108be3:	83 ec 0c             	sub    $0xc,%esp
80108be6:	ff 75 08             	pushl  0x8(%ebp)
80108be9:	e8 3a 9f ff ff       	call   80102b28 <kfree>
80108bee:	83 c4 10             	add    $0x10,%esp
}
80108bf1:	90                   	nop
80108bf2:	c9                   	leave  
80108bf3:	c3                   	ret    

80108bf4 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108bf4:	55                   	push   %ebp
80108bf5:	89 e5                	mov    %esp,%ebp
80108bf7:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108bfa:	83 ec 04             	sub    $0x4,%esp
80108bfd:	6a 00                	push   $0x0
80108bff:	ff 75 0c             	pushl  0xc(%ebp)
80108c02:	ff 75 08             	pushl  0x8(%ebp)
80108c05:	e8 ed f8 ff ff       	call   801084f7 <walkpgdir>
80108c0a:	83 c4 10             	add    $0x10,%esp
80108c0d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
80108c10:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108c14:	75 0d                	jne    80108c23 <clearpteu+0x2f>
    panic("clearpteu");
80108c16:	83 ec 0c             	sub    $0xc,%esp
80108c19:	68 d4 95 10 80       	push   $0x801095d4
80108c1e:	e8 43 79 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c26:	8b 00                	mov    (%eax),%eax
80108c28:	83 e0 fb             	and    $0xfffffffb,%eax
80108c2b:	89 c2                	mov    %eax,%edx
80108c2d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c30:	89 10                	mov    %edx,(%eax)
}
80108c32:	90                   	nop
80108c33:	c9                   	leave  
80108c34:	c3                   	ret    

80108c35 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108c35:	55                   	push   %ebp
80108c36:	89 e5                	mov    %esp,%ebp
80108c38:	53                   	push   %ebx
80108c39:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80108c3c:	e8 e6 f9 ff ff       	call   80108627 <setupkvm>
80108c41:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108c44:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108c48:	75 0a                	jne    80108c54 <copyuvm+0x1f>
    return 0;
80108c4a:	b8 00 00 00 00       	mov    $0x0,%eax
80108c4f:	e9 f8 00 00 00       	jmp    80108d4c <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80108c54:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80108c5b:	e9 c4 00 00 00       	jmp    80108d24 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80108c60:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108c63:	83 ec 04             	sub    $0x4,%esp
80108c66:	6a 00                	push   $0x0
80108c68:	50                   	push   %eax
80108c69:	ff 75 08             	pushl  0x8(%ebp)
80108c6c:	e8 86 f8 ff ff       	call   801084f7 <walkpgdir>
80108c71:	83 c4 10             	add    $0x10,%esp
80108c74:	89 45 ec             	mov    %eax,-0x14(%ebp)
80108c77:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108c7b:	75 0d                	jne    80108c8a <copyuvm+0x55>
      panic("copyuvm: pte should exist");
80108c7d:	83 ec 0c             	sub    $0xc,%esp
80108c80:	68 de 95 10 80       	push   $0x801095de
80108c85:	e8 dc 78 ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
80108c8a:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108c8d:	8b 00                	mov    (%eax),%eax
80108c8f:	83 e0 01             	and    $0x1,%eax
80108c92:	85 c0                	test   %eax,%eax
80108c94:	75 0d                	jne    80108ca3 <copyuvm+0x6e>
      panic("copyuvm: page not present");
80108c96:	83 ec 0c             	sub    $0xc,%esp
80108c99:	68 f8 95 10 80       	push   $0x801095f8
80108c9e:	e8 c3 78 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108ca3:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108ca6:	8b 00                	mov    (%eax),%eax
80108ca8:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108cad:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
80108cb0:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108cb3:	8b 00                	mov    (%eax),%eax
80108cb5:	25 ff 0f 00 00       	and    $0xfff,%eax
80108cba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
80108cbd:	e8 03 9f ff ff       	call   80102bc5 <kalloc>
80108cc2:	89 45 e0             	mov    %eax,-0x20(%ebp)
80108cc5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80108cc9:	74 6a                	je     80108d35 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
80108ccb:	83 ec 0c             	sub    $0xc,%esp
80108cce:	ff 75 e8             	pushl  -0x18(%ebp)
80108cd1:	e8 9f f3 ff ff       	call   80108075 <p2v>
80108cd6:	83 c4 10             	add    $0x10,%esp
80108cd9:	83 ec 04             	sub    $0x4,%esp
80108cdc:	68 00 10 00 00       	push   $0x1000
80108ce1:	50                   	push   %eax
80108ce2:	ff 75 e0             	pushl  -0x20(%ebp)
80108ce5:	e8 cf cd ff ff       	call   80105ab9 <memmove>
80108cea:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
80108ced:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80108cf0:	83 ec 0c             	sub    $0xc,%esp
80108cf3:	ff 75 e0             	pushl  -0x20(%ebp)
80108cf6:	e8 6d f3 ff ff       	call   80108068 <v2p>
80108cfb:	83 c4 10             	add    $0x10,%esp
80108cfe:	89 c2                	mov    %eax,%edx
80108d00:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d03:	83 ec 0c             	sub    $0xc,%esp
80108d06:	53                   	push   %ebx
80108d07:	52                   	push   %edx
80108d08:	68 00 10 00 00       	push   $0x1000
80108d0d:	50                   	push   %eax
80108d0e:	ff 75 f0             	pushl  -0x10(%ebp)
80108d11:	e8 81 f8 ff ff       	call   80108597 <mappages>
80108d16:	83 c4 20             	add    $0x20,%esp
80108d19:	85 c0                	test   %eax,%eax
80108d1b:	78 1b                	js     80108d38 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80108d1d:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108d24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d27:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108d2a:	0f 82 30 ff ff ff    	jb     80108c60 <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
80108d30:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108d33:	eb 17                	jmp    80108d4c <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108d35:	90                   	nop
80108d36:	eb 01                	jmp    80108d39 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108d38:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108d39:	83 ec 0c             	sub    $0xc,%esp
80108d3c:	ff 75 f0             	pushl  -0x10(%ebp)
80108d3f:	e8 10 fe ff ff       	call   80108b54 <freevm>
80108d44:	83 c4 10             	add    $0x10,%esp
  return 0;
80108d47:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108d4c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108d4f:	c9                   	leave  
80108d50:	c3                   	ret    

80108d51 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108d51:	55                   	push   %ebp
80108d52:	89 e5                	mov    %esp,%ebp
80108d54:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108d57:	83 ec 04             	sub    $0x4,%esp
80108d5a:	6a 00                	push   $0x0
80108d5c:	ff 75 0c             	pushl  0xc(%ebp)
80108d5f:	ff 75 08             	pushl  0x8(%ebp)
80108d62:	e8 90 f7 ff ff       	call   801084f7 <walkpgdir>
80108d67:	83 c4 10             	add    $0x10,%esp
80108d6a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
80108d6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d70:	8b 00                	mov    (%eax),%eax
80108d72:	83 e0 01             	and    $0x1,%eax
80108d75:	85 c0                	test   %eax,%eax
80108d77:	75 07                	jne    80108d80 <uva2ka+0x2f>
    return 0;
80108d79:	b8 00 00 00 00       	mov    $0x0,%eax
80108d7e:	eb 29                	jmp    80108da9 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
80108d80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d83:	8b 00                	mov    (%eax),%eax
80108d85:	83 e0 04             	and    $0x4,%eax
80108d88:	85 c0                	test   %eax,%eax
80108d8a:	75 07                	jne    80108d93 <uva2ka+0x42>
    return 0;
80108d8c:	b8 00 00 00 00       	mov    $0x0,%eax
80108d91:	eb 16                	jmp    80108da9 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
80108d93:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108d96:	8b 00                	mov    (%eax),%eax
80108d98:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108d9d:	83 ec 0c             	sub    $0xc,%esp
80108da0:	50                   	push   %eax
80108da1:	e8 cf f2 ff ff       	call   80108075 <p2v>
80108da6:	83 c4 10             	add    $0x10,%esp
}
80108da9:	c9                   	leave  
80108daa:	c3                   	ret    

80108dab <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80108dab:	55                   	push   %ebp
80108dac:	89 e5                	mov    %esp,%ebp
80108dae:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
80108db1:	8b 45 10             	mov    0x10(%ebp),%eax
80108db4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
80108db7:	eb 7f                	jmp    80108e38 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
80108db9:	8b 45 0c             	mov    0xc(%ebp),%eax
80108dbc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108dc1:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
80108dc4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108dc7:	83 ec 08             	sub    $0x8,%esp
80108dca:	50                   	push   %eax
80108dcb:	ff 75 08             	pushl  0x8(%ebp)
80108dce:	e8 7e ff ff ff       	call   80108d51 <uva2ka>
80108dd3:	83 c4 10             	add    $0x10,%esp
80108dd6:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108dd9:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80108ddd:	75 07                	jne    80108de6 <copyout+0x3b>
      return -1;
80108ddf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108de4:	eb 61                	jmp    80108e47 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108de6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108de9:	2b 45 0c             	sub    0xc(%ebp),%eax
80108dec:	05 00 10 00 00       	add    $0x1000,%eax
80108df1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108df4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108df7:	3b 45 14             	cmp    0x14(%ebp),%eax
80108dfa:	76 06                	jbe    80108e02 <copyout+0x57>
      n = len;
80108dfc:	8b 45 14             	mov    0x14(%ebp),%eax
80108dff:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108e02:	8b 45 0c             	mov    0xc(%ebp),%eax
80108e05:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108e08:	89 c2                	mov    %eax,%edx
80108e0a:	8b 45 e8             	mov    -0x18(%ebp),%eax
80108e0d:	01 d0                	add    %edx,%eax
80108e0f:	83 ec 04             	sub    $0x4,%esp
80108e12:	ff 75 f0             	pushl  -0x10(%ebp)
80108e15:	ff 75 f4             	pushl  -0xc(%ebp)
80108e18:	50                   	push   %eax
80108e19:	e8 9b cc ff ff       	call   80105ab9 <memmove>
80108e1e:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108e21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e24:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108e27:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108e2a:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
80108e2d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108e30:	05 00 10 00 00       	add    $0x1000,%eax
80108e35:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108e38:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80108e3c:	0f 85 77 ff ff ff    	jne    80108db9 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108e42:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108e47:	c9                   	leave  
80108e48:	c3                   	ret    
