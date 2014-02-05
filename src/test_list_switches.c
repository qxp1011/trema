#include <inttypes.h>
#include "trema.h"


static void
join( char *result, const list_element *switches ) {
  const char comma[] = ", ";
  const list_element *element;
  for ( element = switches; element != NULL; element = element->next ) {
    char tmp[ 19 ]; // "0x" + 64bits in hex + '\0'
    snprintf( tmp, sizeof( tmp ), "%#" PRIx64, *( uint64_t * ) element->data );
    strcat( result, tmp );
    strcat( result, comma );
  }
  result[ strlen( result ) - strlen( comma ) ] = '\0';
}


static void
handle_list_switches_reply( const list_element *switches, void *user_data ) {
  UNUSED( user_data );

  unsigned int num_switch = list_length_of( switches );

  char *list = xmalloc( 20 * num_switch + 1 ); // 20 = dpid string (18 chars) + ", "
  list[ 0 ] = '\0';
  join( list, switches );
  info( "switches = %s", list );
  xfree( list );

  stop_trema();
}


static void
timeout( void *user_data ) {
  UNUSED( user_data );

  error( "List switches request timeout." );
  stop_trema();
}


int
main( int argc, char *argv[] ) {
  init_trema( &argc, &argv );
  add_periodic_event_callback( 30, timeout, NULL );

  add_periodic_event_callback( 2, ( void ( * )( void * ) ) send_list_switches_request, NULL );
  set_list_switches_reply_handler( handle_list_switches_reply );

  start_trema();
}


/*
 * Local variables:
 * c-basic-offset: 2
 * indent-tabs-mode: nil
 * End:
 */
