

#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>
#include <avr/wdt.h>

const int           RELAY_PINS[4] = { 6, 7, 8, 9 };
const int           AUTO_SIG_PIN = 5;

unsigned long       REBOOT_TIME = (12 * 60 * 60 * 1000);

byte                MAC_ADDR[]  = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0x56 };
const unsigned int  LOCAL_PORT  = 29979;

EthernetUDP         UDP;
long                lastBroadCastTime = 0;
IPAddress           BROADCAST_IP_ADDR(0XFFFFFFFF);
const char*         MY_NAME = "TwoTrees Arduino";

EthernetServer      SERVER(29978);


const int           BUFFER_LEN    = 24;
byte                BUFFER[BUFFER_LEN] = {0};

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

    lastBroadCastTime = millis();

    Serial.begin(9600);

    while (!Ethernet.begin(MAC_ADDR))
        Serial.println(Ethernet.localIP());

    while (!UDP.begin(LOCAL_PORT))
        ;

    SERVER.begin();
}

void loop() 
{
    // check if need reboot
    /*
    if (millis() > REBOOT_TIME)
    {
        static int inReboot = false;

        if (!inReboot)
        {
            wdt_enable(WDTO_15MS);
            inReboot = true;
        }
        
        return;
    }*/

    // check auto signal, control relay 4
    if (LOW ==  digitalRead(AUTO_SIG_PIN))
        digitalWrite(RELAY_PINS[4 - 1], HIGH);
    else
        digitalWrite(RELAY_PINS[4 - 1], LOW);

    // broadcast self info
    long curTime = millis();
    if (curTime - lastBroadCastTime > 1000)
    {
        lastBroadCastTime = curTime;

        UDP.beginPacket(BROADCAST_IP_ADDR, LOCAL_PORT);
        UDP.write(MY_NAME);
        if (UDP.endPacket())
            Serial.println(MY_NAME);
    }

    // relay controller http server
    EthernetClient client = SERVER.available();
    if (client) 
    {
        Serial.println("new client");

        memset(BUFFER, 0, BUFFER_LEN);
        if (client.read(BUFFER, BUFFER_LEN))
        {
            Serial.println((char*)BUFFER);

            String cmd = (char*)BUFFER;
            char c = cmd.charAt(0);
            if ('Q' == c)
            {
                String ret;
                for (int i = 0; i < 4; ++i)
                    digitalRead(RELAY_PINS[i]) ? ret += '1' : ret += '0';

                client.write(&ret[0]);
            }
            else if  ('O' == c || 'F' == c)
            {
                uint8_t signal = LOW;
                if ('O' == c)
                    signal = HIGH;
                else if ('F' == c)
                    signal = LOW;

                char relayNum[2] = { 0 };
                relayNum[0] = cmd.charAt(1);
                int relayIndex = atoi(relayNum);

                if (relayIndex >= 1 && relayIndex <= 3)
                    digitalWrite(RELAY_PINS[relayIndex - 1], signal);
            }
        }

        delay(1);
        client.stop();
    }

    delay(10);
}