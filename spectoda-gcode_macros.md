Navrhuji následující:

do ~/printer_data/config/moonraker.conf přidat:

[notifier spectoda]
url: json://localhost:5555/notifier
events: gcode
body: {event_message}

a do server.ts přidat další endpoint (tohle by už mělo být hotové):

app.post('/notifier', async (req , res) => {
  const { message } = req.body as { message: string };
  try {
    let parsed: {[key: string]: string} = {};
    message.split(' ').forEach((c)=>{
      const [key, value] = c.split('=');
      if (key && value) {
        parsed[key.toLowerCase()] = value;
      }
    });
    console.log(parsed)
    const label = parsed['label'];
    if (label) {
      const result = await spectodaDevice.emitEvent(label.substring(0, 5), 255);
      return res.json({ status: "success", result: result });
    }
    res.statusCode = 400;
    return res.json({ status: "error", result: "no label in message" });
  } catch (error) {
    res.statusCode = 405;
    return res.json({ status: "error", error: error });
  }
});

v ~/printer_data/config/RGB.cfg potom používat macro např. takto. V message bude spectoda label:

[gcode_macro LED_Heating]
gcode:
  {action_call_remote_method("notify",
                      name="spectoda",
                      message="heat")}
                      
nebo ještě lépe:

[gcode_macro SPECTODA]
gcode: 
  {% if rawparams %}
    {% set escaped_msg = rawparams.split(';', 1)[0].split('\x23', 1)[0]|replace('"', '\\"') %}
    {action_call_remote_method("notify",
                          name="spectoda",
                          message=escaped_msg)}
  {% endif %}
  
a používat kdekoli v gcode:
SPECTODA LABEL=heat value=5
