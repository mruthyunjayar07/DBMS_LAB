

create table call_detail (
  phone_number int not null,
  call_start timestamp not null,
  call_duration int,
  call_description varchar (30),
  primary key ( phone_number, call_start )
  )
partition by range ( unix_timestamp  ( call_start ) ) ( 
partition p0 values less than ( unix_timestamp ( '2025-01-22 00:00:00' ) ),
  partition p1 values less than ( unix_timestamp ( '2025-01-23 00:00:00' ) )
  );
create index idx on call_detail ( phone_number, call_start );

show index from call_detail;

insert into call_detail ( phone_number, call_start, call_duration, call_description ) values
( '122434231', '2025-01-20 00:00:00', 50, 'FDF' ),
( '122343242', '2025-01-22 10:00:00', 40, 'FFR' ),
( '122434230', '2025-01-11 00:00:00', 50, 'FDF' ),
( '122343242', '2025-01-11 10:00:00', 40, 'FFR' ),
( '123232323', '2025-01-11 10:00:00', 30, 'EED' );

select * from call_detail;

select * from call_detail partition (p0);

select * from call_detail partition (p1);
