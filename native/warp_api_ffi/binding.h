typedef char int8_t;
typedef long long int int64_t;
typedef long long int uint64_t;
typedef long long int uintptr_t;
typedef long int uint32_t;
typedef char bool;
typedef void *DartPostCObjectFnType;

void init_wallet(char *db_path, char *ld_url);

void warp_sync(bool get_tx, uint32_t anchor_offset, int64_t port);

void dart_post_cobject(DartPostCObjectFnType ptr);

uint32_t get_latest_height(void);

bool is_valid_key(char *seed);

bool valid_address(char *address);

char *new_address(uint32_t account);

void set_mempool_account(uint32_t account);

uint32_t new_account(char *name, char *data);

int64_t get_mempool_balance(void);

const char *send_payment(uint32_t account,
                         char *address,
                         uint64_t amount,
                         char *memo,
                         uint64_t max_amount_per_note,
                         uint32_t anchor_offset,
                         int64_t port);

int8_t try_warp_sync(bool get_tx, uint32_t anchor_offset);

void skip_to_last_height(void);

void rewind_to_height(uint32_t height);

int64_t mempool_sync(void);

uint64_t get_taddr_balance(uint32_t account);

char *shield_taddr(uint32_t account);

void set_lwd_url(char *url);

double get_current_price(void);

void dummy_export(void);
