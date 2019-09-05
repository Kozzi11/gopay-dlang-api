module gopay.definition.payment;

enum BankSwiftCode : string
{
    ceska_sporitelna = "GIBACZPX",
    komercni_banka = "KOMBCZPP",
    raiffeisenbank = "RZBCCZPP",
    mbank = "BREXCZPP",
    fio_banka = "FIOBCZPP",
    csob = "CEKOCZPP",
    era = "CEKOCZPP-ERA",
    unicredit_bank_cz = "BACXCZPP",
    vseobecna_verova_banka_banka = "SUBASKBX",
    tatra_banka = "TATRSKBX",
    unicredit_bank_sk = "UNCRSKBX",
    slovenska_sporitelna = "GIBASKBX",
    postova_banka = "POBNSKBA",
    csob_sk = "CEKOSKBX",
    sberbank_slovensko = "LUBASKBX",
    special = "OTHERS",
    mbank1 = "BREXPLPW",
    citi_handlowy = "CITIPLPX",
    iko = "BPKOPLPW-IKO",
    inteligo = "BPKOPLPW-INTELIGO",
    plus_bank = "IVSEPLPP",
    bank_bph_sa = "BPHKPLPK",
    toyota_bank = "TOBAPLPW",
    volkswagen_bank = "VOWAPLP1",
    sgb = "GBWCPLPP",
    pocztowy_bank = "POCZPLP4",
    bgz_bank = "GOPZPLPW",
    idea = "IEEAPLPA",
    bps = "POLUPLPR",
    getin_online = "GBGCPLPK-GIO",
    blik = "GBGCPLPK-BLIK",
    noble_bank = "GBGCPLPK-NOB",
    orange = "BREXPLPW-OMB",
    bz_wbk = "WBKPPLPP",
    raiffeisen_bank_polska_sa = "RCBWPLPW",
    powszechna_kasa_oszczednosci_bank_polski_sa = "BPKOPLPW",
    alior_bank = "ALBPPLPW",
    ing_bank_slaski = "INGBPLPW",
    pekao_sa = "PKOPPLPW",
    getin_online1 = "GBGCPLPK",
    bank_millennium = "BIGBPLPW",
    bank_ochrony_srodowiska = "EBOSPLPW",
    bnp_paribas_polska = "PPABPLPK",
    credit_agricole = "agriplpr",
    deutsche_bank_polska_sa = "DEUTPLPX",
    dnb_nord = "DNBANOKK",
    e_skok = "NBPLPLPW",
    eurobank = "SOGEPLPW",
    polski_bank_przedsiebiorczosci_spolka_akcyjna = "PBPBPLPW",
}

enum Currency : string
{
    czech_crowns = "CZK",
    euros = "EUR",
    polish_zloty = "PLN",
    hungarian_forint = "HUF",
    british_pound = "GBP",
    us_dollar = "USD",
    romanian_leu = "RON",
    croatian_kuna = "HRK",
    bulgarian_lev = "BGN",
}

enum PaymentInstrument : string
{
    payment_card = "PAYMENT_CARD",
    bank_account = "BANK_ACCOUNT",
    premium_sms = "PRSMS",
    mpayment = "MPAYMENT",
    paysafecard = "PAYSAFECARD",
    supercash = "SUPERCASH",
    gopay = "GOPAY",
    paypal = "PAYPAL",
    bitcoin = "BITCOIN",
    account = "ACCOUNT",
    gpay = "GPAY",
}

enum PaymentItemType : string
{
    item = "ITEM",
    discount = "DISCOUNT",
    delivery = "DELIVERY",
}

enum Recurrence : string
{
    daily = "DAY",
    weekly = "WEEK",
    monthly = "MONTH",
    on_demand = "ON_DEMAND",
}

enum VatRate
{
    rate_1 = 0,
    rate_2 = 10,
    rate_3 = 15,
    rate_4 = 21,
}