

#include <SPI.h>
#include <Ethernet.h>
#include <EthernetUdp.h>

byte                MAC_ADDR[]      = { 0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0x56 };
const unsigned int  LOCAL_PORT      = 29979;

EthernetUDP UDP;
long        lastBroadCastTime = 0;
IPAddress   BROADCAST_IP_ADDR(0XFFFFFFFF);
const char* MY_NAME = "TwoTrees Relay Controller";

EthernetServer SERVER(29978);
const int RELAY1 = 6;
const int RELAY2 = 7;
const int RELAY3 = 8;
const int RELAY4 = 9;

const int BUFFER_LEN    = 24;
byte BUFFER[BUFFER_LEN] = {0};

void setup()
{
    lastBroadCastTime = millis();

    Serial.begin(9600);

    Ethernet.begin(MAC_ADDR);
    Serial.println(Ethernet.localIP());

    UDP.begin(LOCAL_PORT);
    SERVER.begin();

    pinMode(RELAY1, OUTPUT);
    digitalWrite(RELAY1, LOW);

    pinMode(RELAY2, OUTPUT);
    digitalWrite(RELAY2, LOW);

    pinMode(RELAY3, OUTPUT);
    digitalWrite(RELAY3, LOW);

    pinMode(RELAY4, OUTPUT);
    digitalWrite(RELAY4, LOW);
}

void loop()
{
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
            if (String("Q") == cmd)
            {
                String ret;
                digitalRead(RELAY1) ? ret += '1' : ret += '0';
                digitalRead(RELAY2) ? ret += '1' : ret += '0';
                digitalRead(RELAY3) ? ret += '1' : ret += '0';
                digitalRead(RELAY4) ? ret += '1' : ret += '0';

                client.write(&ret[0]);
            }
            else if (cmd.charAt(0) == 'O')
            {
                char relay = cmd.charAt(1);
                switch (relay)
                {
                case '1':
                    digitalWrite(RELAY1, HIGH);
                    break;
                case '2':
                    digitalWrite(RELAY2, HIGH);
                    break;
                case '3':
                    digitalWrite(RELAY3, HIGH);
                    break;
                case '4':
                    digitalWrite(RELAY4, HIGH);
                    break;

                default:
                    break;
                }
            }
            else if (cmd.charAt(0) == 'F')
            {
                char relay = cmd.charAt(1);
                switch (relay)
                {
                case '1':
                    digitalWrite(RELAY1, LOW);
                    break;
                case '2':
                    digitalWrite(RELAY2, LOW);
                    break;
                case '3':
                    digitalWrite(RELAY3, LOW);
                    break;
                case '4':
                    digitalWrite(RELAY4, LOW);
                    break;

                default:
                    break;
                }
            }
        }

        delay(1);
        client.stop();
    }

    delay(10);
}
