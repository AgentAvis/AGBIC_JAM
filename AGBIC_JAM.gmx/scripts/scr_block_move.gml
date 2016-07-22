var hspd;

hspd = argument0;

if (place_meeting(x+hspd,y,par_solid_platforming))
{
    while(!(place_meeting(x+sign(hspd),y,par_solid_platforming)))
    {
        x += sign(hspd);
    }
    hspd = 0;
}

x+= hspd;
