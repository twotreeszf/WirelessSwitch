

const int           RELAY_PINS[4] = { 6, 7, 8, 9 };
const int           AUTO_SIG_PIN = 5;

void setup() 
{
    // init relay conrol pins as output mode
    for (int i = 0; i < 4; ++i)
    {
        pinMode(RELAY_PINS[i], OUTPUT);
        digitalWrite(RELAY_PINS[i], LOW);
    }

    // init auto signal pin as input mode
    pinMode(AUTO_SIG_PIN, INPUT_PULLUP);
}

void loop() 
{
    // check auto signal, control relay 4
    if (LOW ==  digitalRead(AUTO_SIG_PIN))
        digitalWrite(RELAY_PINS[4 - 1], HIGH);
    else
        digitalWrite(RELAY_PINS[4 - 1], LOW);

    delay(3000);
}