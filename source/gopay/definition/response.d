module gopay.definition.response;

enum PaymentStatus
{

    created = "CREATED",
    payment_method_chosen = "PAYMENT_METHOD_CHOSEN",
    paid = "PAID",
    authorized = "AUTHORIZED",
    canceled = "CANCELED",
    timeouted = "TIMEOUTED",
    refunded = "REFUNDED",
    partially_refunded = "PARTIALLY_REFUNDED",
}

// https://doc.gopay.com/en/?php#payment-substate
enum PaymentSubStatus
{

    _101 = "_101",
    _102 = "_102",
    _3001 = "_3001",
    _3002 = "_3002",
    _3003 = "_3003",
    _5001 = "_5001",
    _5002 = "_5002",
    _5003 = "_5003",
    _5004 = "_5004",
    _5005 = "_5005",
    _5006 = "_5006",
    _5007 = "_5007",
    _5008 = "_5008",
    _5009 = "_5009",
    _5010 = "_5010",
    _5011 = "_5011",
    _5012 = "_5012",
    _5013 = "_5013",
    _5014 = "_5014",
    _5015 = "_5015",
    _5016 = "_5016",
    _5017 = "_5017",
    _5018 = "_5018",
    _5019 = "_5019",
    _5020 = "_5020",
    _5021 = "_5021",
    _5022 = "_5022",
    _5023 = "_5023",
    _5024 = "_5024",
    _5025 = "_5025",
    _5026 = "_5026",
    _5027 = "_5027",
    _5028 = "_5028",
    _5029 = "_5029",
    _5030 = "_5030",
    _5031 = "_5031",
    _5033 = "_5033",
    _5035 = "_5035",
    _5036 = "_5036",
    _5037 = "_5037",
    _5038 = "_5038",
    _5039 = "_5039",
    _5040 = "_5040",
    _5041 = "_5041",
    _5042 = "_5042",
    _5043 = "_5043",
    _5044 = "_5044",
    _5045 = "_5045",
    _5046 = "_5046",
    _5047 = "_5047",
    _6502 = "_6502",
    _6504 = "_6504",
}

enum PreAuthState
{

    requested = "REQUESTED",
    authorized = "AUTHORIZED",
    captured = "CAPTURED",
    canceled = "CANCELED",
}


enum RecurrenceState
{

    requested = "REQUESTED",
    started = "STARTED",
    stopped = "STOPPED",
}

enum Result
{

    accepted = "ACCEPTED",
    finished = "FINISHED",
    failed = "FAILED",
}