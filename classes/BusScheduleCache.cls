public with sharing class BusScheduleCache {

    private Cache.OrgPartition part;

    public BusScheduleCache() {
        this.part = Cache.Org.getPartition('local.BusSchedule');

        Time[] tList = new List<Time>{
            Time.newInstance(11, 0, 0, 0),
            Time.newInstance(13, 0, 0, 0)
        };

        putSchedule('Yellow', tList);

        System.debug(getSchedule('Yellow'));
    }

    public void putSchedule(String busLine, Time[] schedule){
        this.part.put(busLine, schedule);
    }

    public Time[] getSchedule(String busLine){
        System.debug(busLine);
        System.debug(this.part);
        Time[] timeFromCache = (Time[])this.part.get(busLine);
        System.debug(timeFromCache);
        if(timeFromCache != null){
            return timeFromCache;
        } else {
            Time a = Time.newInstance(8, 0, 0, 0);
            Time b = Time.newInstance(17, 0, 0, 0);
            Time[] tList = new List<Time>();
            tList.add(a);
            tList.add(b);
            return tList;
        }
    }





    /*public BusScheduleCache() {
        Cache.OrgPartition cop = Cache.Org.getPartition('local.BusSchedule');
        this.part = cop;
    }

    public void putSchedule(String busLine, Time[] schedule){
        this.part.put(busLine, schedule);
    }

    public Time[] getSchedule( String busLine){
        Time[] timeFromCache = (Time[])this.part.get(busLine);
        if(timeFromCache != null){
            return timeFromCache;
        } else {
            Time a = Time.newInstance(8, 0, 0, 0);
            Time b = Time.newInstance(17, 0, 0, 0);
            Time[] tList = new List<Time>();
            tList.add(a);
            tList.add(b);
            return tList;
        }
    }*/
}