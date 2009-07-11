#!/usr/bin/ruby

require 'test/unit'
require File.dirname(__FILE__)+'/../lib/libcraigscrape'
require File.dirname(__FILE__)+'/libcraigscrape_test_helpers'

class CraigslistGeolistingTest < Test::Unit::TestCase
  include LibcraigscrapeTestHelpers
  
  def test_pukes
    assert_raise(CraigScrape::Scraper::ParseError) do
      CraigScrape::GeoListings.new( relative_uri_for('google.html') ).sites
    end
  end
  
  def test_geo_listings
    geo_listing_us070209 = CraigScrape::GeoListings.new relative_uri_for(
      'geolisting_samples/geo_listing_us070209.html'
    )
    assert_equal 'united states', geo_listing_us070209.location
    assert_equal 326, geo_listing_us070209.sites.length
    assert_equal "sfbay.craigslist.org", geo_listing_us070209.sites["SF bay area"]
    assert_equal "abilene.craigslist.org", geo_listing_us070209.sites["abilene"]
    assert_equal "akroncanton.craigslist.org", geo_listing_us070209.sites["akron / canton"]
    assert_equal "anchorage.craigslist.org", geo_listing_us070209.sites["alaska"]
    assert_equal "albany.craigslist.org", geo_listing_us070209.sites["albany"]
    assert_equal "albuquerque.craigslist.org", geo_listing_us070209.sites["albuquerque"]
    assert_equal "altoona.craigslist.org", geo_listing_us070209.sites["altoona-johnstown"]
    assert_equal "amarillo.craigslist.org", geo_listing_us070209.sites["amarillo"]
    assert_equal "ames.craigslist.org", geo_listing_us070209.sites["ames, IA"]
    assert_equal "annarbor.craigslist.org", geo_listing_us070209.sites["ann arbor"]
    assert_equal "annapolis.craigslist.org", geo_listing_us070209.sites["annapolis"]
    assert_equal "appleton.craigslist.org", geo_listing_us070209.sites["appleton-oshkosh-FDL"]
    assert_equal "asheville.craigslist.org", geo_listing_us070209.sites["asheville"]
    assert_equal "athensga.craigslist.org", geo_listing_us070209.sites["athens, GA"]
    assert_equal "athensohio.craigslist.org", geo_listing_us070209.sites["athens, OH"]
    assert_equal "atlanta.craigslist.org", geo_listing_us070209.sites["atlanta"]
    assert_equal "auburn.craigslist.org", geo_listing_us070209.sites["auburn"]
    assert_equal "augusta.craigslist.org", geo_listing_us070209.sites["augusta"]
    assert_equal "austin.craigslist.org", geo_listing_us070209.sites["austin"]
    assert_equal "bakersfield.craigslist.org", geo_listing_us070209.sites["bakersfield"]
    assert_equal "baltimore.craigslist.org", geo_listing_us070209.sites["baltimore"]
    assert_equal "batonrouge.craigslist.org", geo_listing_us070209.sites["baton rouge"]
    assert_equal "beaumont.craigslist.org", geo_listing_us070209.sites["beaumont / port arthur"]
    assert_equal "bellingham.craigslist.org", geo_listing_us070209.sites["bellingham"]
    assert_equal "bend.craigslist.org", geo_listing_us070209.sites["bend"]
    assert_equal "binghamton.craigslist.org", geo_listing_us070209.sites["binghamton"]
    assert_equal "bham.craigslist.org", geo_listing_us070209.sites["birmingham, AL"]
    assert_equal "blacksburg.craigslist.org", geo_listing_us070209.sites["blacksburg"]
    assert_equal "bloomington.craigslist.org", geo_listing_us070209.sites["bloomington"]
    assert_equal "bn.craigslist.org", geo_listing_us070209.sites["bloomington-normal"]
    assert_equal "boise.craigslist.org", geo_listing_us070209.sites["boise"]
    assert_equal "boone.craigslist.org", geo_listing_us070209.sites["boone"]
    assert_equal "boston.craigslist.org", geo_listing_us070209.sites["boston"]
    assert_equal "boulder.craigslist.org", geo_listing_us070209.sites["boulder"]
    assert_equal "bgky.craigslist.org", geo_listing_us070209.sites["bowling green"]
    assert_equal "brownsville.craigslist.org", geo_listing_us070209.sites["brownsville"]
    assert_equal "brunswick.craigslist.org", geo_listing_us070209.sites["brunswick, GA"]
    assert_equal "buffalo.craigslist.org", geo_listing_us070209.sites["buffalo"]
    assert_equal "capecod.craigslist.org", geo_listing_us070209.sites["cape cod / islands"]
    assert_equal "carbondale.craigslist.org", geo_listing_us070209.sites["carbondale"]
    assert_equal "catskills.craigslist.org", geo_listing_us070209.sites["catskills"]
    assert_equal "cedarrapids.craigslist.org", geo_listing_us070209.sites["cedar rapids"]
    assert_equal "cnj.craigslist.org", geo_listing_us070209.sites["central NJ"]
    assert_equal "centralmich.craigslist.org", geo_listing_us070209.sites["central michigan"]
    assert_equal "chambana.craigslist.org", geo_listing_us070209.sites["champaign urbana"]
    assert_equal "charleston.craigslist.org", geo_listing_us070209.sites["charleston, SC"]
    assert_equal "charlestonwv.craigslist.org", geo_listing_us070209.sites["charleston, WV"]
    assert_equal "charlotte.craigslist.org", geo_listing_us070209.sites["charlotte"]
    assert_equal "charlottesville.craigslist.org", geo_listing_us070209.sites["charlottesville"]
    assert_equal "chattanooga.craigslist.org", geo_listing_us070209.sites["chattanooga"]
    assert_equal "chautauqua.craigslist.org", geo_listing_us070209.sites["chautauqua"]
    assert_equal "chicago.craigslist.org", geo_listing_us070209.sites["chicago"]
    assert_equal "chico.craigslist.org", geo_listing_us070209.sites["chico"]
    assert_equal "cincinnati.craigslist.org", geo_listing_us070209.sites["cincinnati, OH"]
    assert_equal "clarksville.craigslist.org", geo_listing_us070209.sites["clarksville, TN"]
    assert_equal "cleveland.craigslist.org", geo_listing_us070209.sites["cleveland"]
    assert_equal "collegestation.craigslist.org", geo_listing_us070209.sites["college station"]
    assert_equal "cosprings.craigslist.org", geo_listing_us070209.sites["colorado springs"]
    assert_equal "columbiamo.craigslist.org", geo_listing_us070209.sites["columbia / jeff city"]
    assert_equal "columbia.craigslist.org", geo_listing_us070209.sites["columbia, SC"]
    assert_equal "columbus.craigslist.org", geo_listing_us070209.sites["columbus"]
    assert_equal "columbusga.craigslist.org", geo_listing_us070209.sites["columbus, GA"]
    assert_equal "corpuschristi.craigslist.org", geo_listing_us070209.sites["corpus christi"]
    assert_equal "corvallis.craigslist.org", geo_listing_us070209.sites["corvallis/albany"]
    assert_equal "dallas.craigslist.org", geo_listing_us070209.sites["dallas / fort worth"]
    assert_equal "danville.craigslist.org", geo_listing_us070209.sites["danville"]
    assert_equal "dayton.craigslist.org", geo_listing_us070209.sites["dayton / springfield"]
    assert_equal "daytona.craigslist.org", geo_listing_us070209.sites["daytona beach"]
    assert_equal "decatur.craigslist.org", geo_listing_us070209.sites["decatur, IL"]
    assert_equal "delaware.craigslist.org", geo_listing_us070209.sites["delaware"]
    assert_equal "denver.craigslist.org", geo_listing_us070209.sites["denver"]
    assert_equal "desmoines.craigslist.org", geo_listing_us070209.sites["des moines"]
    assert_equal "detroit.craigslist.org", geo_listing_us070209.sites["detroit metro"]
    assert_equal "dothan.craigslist.org", geo_listing_us070209.sites["dothan, AL"]
    assert_equal "dubuque.craigslist.org", geo_listing_us070209.sites["dubuque"]
    assert_equal "duluth.craigslist.org", geo_listing_us070209.sites["duluth / superior"]
    assert_equal "eastidaho.craigslist.org", geo_listing_us070209.sites["east idaho"]
    assert_equal "eastoregon.craigslist.org", geo_listing_us070209.sites["east oregon"]
    assert_equal "newlondon.craigslist.org", geo_listing_us070209.sites["eastern CT"]
    assert_equal "eastnc.craigslist.org", geo_listing_us070209.sites["eastern NC"]
    assert_equal "easternshore.craigslist.org", geo_listing_us070209.sites["eastern shore"]
    assert_equal "eauclaire.craigslist.org", geo_listing_us070209.sites["eau claire"]
    assert_equal "elpaso.craigslist.org", geo_listing_us070209.sites["el paso"]
    assert_equal "elmira.craigslist.org", geo_listing_us070209.sites["elmira-corning"]
    assert_equal "erie.craigslist.org", geo_listing_us070209.sites["erie, PA"]
    assert_equal "eugene.craigslist.org", geo_listing_us070209.sites["eugene"]
    assert_equal "evansville.craigslist.org", geo_listing_us070209.sites["evansville"]
    assert_equal "fargo.craigslist.org", geo_listing_us070209.sites["fargo / moorhead"]
    assert_equal "farmington.craigslist.org", geo_listing_us070209.sites["farmington, NM"]
    assert_equal "fayetteville.craigslist.org", geo_listing_us070209.sites["fayetteville"]
    assert_equal "fayar.craigslist.org", geo_listing_us070209.sites["fayetteville, AR"]
    assert_equal "flagstaff.craigslist.org", geo_listing_us070209.sites["flagstaff / sedona"]
    assert_equal "flint.craigslist.org", geo_listing_us070209.sites["flint"]
    assert_equal "shoals.craigslist.org", geo_listing_us070209.sites["florence / muscle shoals"]
    assert_equal "florencesc.craigslist.org", geo_listing_us070209.sites["florence, SC"]
    assert_equal "keys.craigslist.org", geo_listing_us070209.sites["florida keys"]
    assert_equal "fortcollins.craigslist.org", geo_listing_us070209.sites["fort collins / north CO"]
    assert_equal "fortsmith.craigslist.org", geo_listing_us070209.sites["fort smith, AR"]
    assert_equal "fortwayne.craigslist.org", geo_listing_us070209.sites["fort wayne"]
    assert_equal "fredericksburg.craigslist.org", geo_listing_us070209.sites["fredericksburg"]
    assert_equal "fresno.craigslist.org", geo_listing_us070209.sites["fresno"]
    assert_equal "fortmyers.craigslist.org", geo_listing_us070209.sites["ft myers / SW florida"]
    assert_equal "gadsden.craigslist.org", geo_listing_us070209.sites["gadsden-anniston"]
    assert_equal "gainesville.craigslist.org", geo_listing_us070209.sites["gainesville"]
    assert_equal "galveston.craigslist.org", geo_listing_us070209.sites["galveston"]
    assert_equal "goldcountry.craigslist.org", geo_listing_us070209.sites["gold country"]
    assert_equal "grandisland.craigslist.org", geo_listing_us070209.sites["grand island"]
    assert_equal "grandrapids.craigslist.org", geo_listing_us070209.sites["grand rapids"]
    assert_equal "greenbay.craigslist.org", geo_listing_us070209.sites["green bay"]
    assert_equal "greensboro.craigslist.org", geo_listing_us070209.sites["greensboro"]
    assert_equal "greenville.craigslist.org", geo_listing_us070209.sites["greenville / upstate"]
    assert_equal "gulfport.craigslist.org", geo_listing_us070209.sites["gulfport / biloxi"]
    assert_equal "norfolk.craigslist.org", geo_listing_us070209.sites["hampton roads"]
    assert_equal "harrisburg.craigslist.org", geo_listing_us070209.sites["harrisburg"]
    assert_equal "harrisonburg.craigslist.org", geo_listing_us070209.sites["harrisonburg"]
    assert_equal "hartford.craigslist.org", geo_listing_us070209.sites["hartford"]
    assert_equal "hattiesburg.craigslist.org", geo_listing_us070209.sites["hattiesburg"]
    assert_equal "honolulu.craigslist.org", geo_listing_us070209.sites["hawaii"]
    assert_equal "hickory.craigslist.org", geo_listing_us070209.sites["hickory / lenoir"]
    assert_equal "hiltonhead.craigslist.org", geo_listing_us070209.sites["hilton head"]
    assert_equal "houston.craigslist.org", geo_listing_us070209.sites["houston"]
    assert_equal "hudsonvalley.craigslist.org", geo_listing_us070209.sites["hudson valley"]
    assert_equal "humboldt.craigslist.org", geo_listing_us070209.sites["humboldt county"]
    assert_equal "huntington.craigslist.org", geo_listing_us070209.sites["huntington-ashland"]
    assert_equal "huntsville.craigslist.org", geo_listing_us070209.sites["huntsville"]
    assert_equal "imperial.craigslist.org", geo_listing_us070209.sites["imperial county"]
    assert_equal "indianapolis.craigslist.org", geo_listing_us070209.sites["indianapolis"]
    assert_equal "inlandempire.craigslist.org", geo_listing_us070209.sites["inland empire"]
    assert_equal "iowacity.craigslist.org", geo_listing_us070209.sites["iowa city"]
    assert_equal "ithaca.craigslist.org", geo_listing_us070209.sites["ithaca"]
    assert_equal "jxn.craigslist.org", geo_listing_us070209.sites["jackson, MI"]
    assert_equal "jackson.craigslist.org", geo_listing_us070209.sites["jackson, MS"]
    assert_equal "jacksontn.craigslist.org", geo_listing_us070209.sites["jackson, TN"]
    assert_equal "jacksonville.craigslist.org", geo_listing_us070209.sites["jacksonville"]
    assert_equal "janesville.craigslist.org", geo_listing_us070209.sites["janesville"]
    assert_equal "jerseyshore.craigslist.org", geo_listing_us070209.sites["jersey shore"]
    assert_equal "jonesboro.craigslist.org", geo_listing_us070209.sites["jonesboro"]
    assert_equal "joplin.craigslist.org", geo_listing_us070209.sites["joplin"]
    assert_equal "kalamazoo.craigslist.org", geo_listing_us070209.sites["kalamazoo"]
    assert_equal "kansascity.craigslist.org", geo_listing_us070209.sites["kansas city, MO"]
    assert_equal "kpr.craigslist.org", geo_listing_us070209.sites["kennewick-pasco-richland"]
    assert_equal "racine.craigslist.org", geo_listing_us070209.sites["kenosha-racine"]
    assert_equal "killeen.craigslist.org", geo_listing_us070209.sites["killeen / temple / ft hood"]
    assert_equal "knoxville.craigslist.org", geo_listing_us070209.sites["knoxville"]
    assert_equal "lacrosse.craigslist.org", geo_listing_us070209.sites["la crosse"]
    assert_equal "lafayette.craigslist.org", geo_listing_us070209.sites["lafayette"]
    assert_equal "tippecanoe.craigslist.org", geo_listing_us070209.sites["lafayette / west lafayette"]
    assert_equal "lakecharles.craigslist.org", geo_listing_us070209.sites["lake charles"]
    assert_equal "lakeland.craigslist.org", geo_listing_us070209.sites["lakeland"]
    assert_equal "lancaster.craigslist.org", geo_listing_us070209.sites["lancaster, PA"]
    assert_equal "lansing.craigslist.org", geo_listing_us070209.sites["lansing"]
    assert_equal "laredo.craigslist.org", geo_listing_us070209.sites["laredo"]
    assert_equal "lascruces.craigslist.org", geo_listing_us070209.sites["las cruces"]
    assert_equal "lasvegas.craigslist.org", geo_listing_us070209.sites["las vegas"]
    assert_equal "lawrence.craigslist.org", geo_listing_us070209.sites["lawrence"]
    assert_equal "lawton.craigslist.org", geo_listing_us070209.sites["lawton"]
    assert_equal "allentown.craigslist.org", geo_listing_us070209.sites["lehigh valley"]
    assert_equal "lexington.craigslist.org", geo_listing_us070209.sites["lexington, KY"]
    assert_equal "limaohio.craigslist.org", geo_listing_us070209.sites["lima / findlay"]
    assert_equal "lincoln.craigslist.org", geo_listing_us070209.sites["lincoln"]
    assert_equal "littlerock.craigslist.org", geo_listing_us070209.sites["little rock"]
    assert_equal "logan.craigslist.org", geo_listing_us070209.sites["logan"]
    assert_equal "longisland.craigslist.org", geo_listing_us070209.sites["long island"]
    assert_equal "losangeles.craigslist.org", geo_listing_us070209.sites["los angeles"]
    assert_equal "louisville.craigslist.org", geo_listing_us070209.sites["louisville"]
    assert_equal "lubbock.craigslist.org", geo_listing_us070209.sites["lubbock"]
    assert_equal "lynchburg.craigslist.org", geo_listing_us070209.sites["lynchburg"]
    assert_equal "macon.craigslist.org", geo_listing_us070209.sites["macon"]
    assert_equal "madison.craigslist.org", geo_listing_us070209.sites["madison"]
    assert_equal "maine.craigslist.org", geo_listing_us070209.sites["maine"]
    assert_equal "ksu.craigslist.org", geo_listing_us070209.sites["manhattan, KS"]
    assert_equal "mankato.craigslist.org", geo_listing_us070209.sites["mankato"]
    assert_equal "mansfield.craigslist.org", geo_listing_us070209.sites["mansfield"]
    assert_equal "martinsburg.craigslist.org", geo_listing_us070209.sites["martinsburg"]
    assert_equal "mcallen.craigslist.org", geo_listing_us070209.sites["mcallen / edinburg"]
    assert_equal "medford.craigslist.org", geo_listing_us070209.sites["medford-ashland-klamath"]
    assert_equal "memphis.craigslist.org", geo_listing_us070209.sites["memphis, TN"]
    assert_equal "mendocino.craigslist.org", geo_listing_us070209.sites["mendocino county"]
    assert_equal "merced.craigslist.org", geo_listing_us070209.sites["merced"]
    assert_equal "milwaukee.craigslist.org", geo_listing_us070209.sites["milwaukee"]
    assert_equal "minneapolis.craigslist.org", geo_listing_us070209.sites["minneapolis / st paul"]
    assert_equal "mobile.craigslist.org", geo_listing_us070209.sites["mobile"]
    assert_equal "modesto.craigslist.org", geo_listing_us070209.sites["modesto"]
    assert_equal "mohave.craigslist.org", geo_listing_us070209.sites["mohave county"]
    assert_equal "monroe.craigslist.org", geo_listing_us070209.sites["monroe, LA"]
    assert_equal "montana.craigslist.org", geo_listing_us070209.sites["montana"]
    assert_equal "monterey.craigslist.org", geo_listing_us070209.sites["monterey bay"]
    assert_equal "montgomery.craigslist.org", geo_listing_us070209.sites["montgomery"]
    assert_equal "morgantown.craigslist.org", geo_listing_us070209.sites["morgantown"]
    assert_equal "muncie.craigslist.org", geo_listing_us070209.sites["muncie / anderson"]
    assert_equal "muskegon.craigslist.org", geo_listing_us070209.sites["muskegon"]
    assert_equal "myrtlebeach.craigslist.org", geo_listing_us070209.sites["myrtle beach"]
    assert_equal "nashville.craigslist.org", geo_listing_us070209.sites["nashville"]
    assert_equal "nh.craigslist.org", geo_listing_us070209.sites["new hampshire"]
    assert_equal "newhaven.craigslist.org", geo_listing_us070209.sites["new haven"]
    assert_equal "neworleans.craigslist.org", geo_listing_us070209.sites["new orleans"]
    assert_equal "newyork.craigslist.org", geo_listing_us070209.sites["new york city"]
    assert_equal "nd.craigslist.org", geo_listing_us070209.sites["north dakota"]
    assert_equal "newjersey.craigslist.org", geo_listing_us070209.sites["north jersey"]
    assert_equal "northmiss.craigslist.org", geo_listing_us070209.sites["north mississippi"]
    assert_equal "nmi.craigslist.org", geo_listing_us070209.sites["northern michigan"]
    assert_equal "nwct.craigslist.org", geo_listing_us070209.sites["northwest CT"]
    assert_equal "ocala.craigslist.org", geo_listing_us070209.sites["ocala"]
    assert_equal "odessa.craigslist.org", geo_listing_us070209.sites["odessa / midland"]
    assert_equal "ogden.craigslist.org", geo_listing_us070209.sites["ogden-clearfield"]
    assert_equal "oklahomacity.craigslist.org", geo_listing_us070209.sites["oklahoma city"]
    assert_equal "olympic.craigslist.org", geo_listing_us070209.sites["olympic peninsula"]
    assert_equal "omaha.craigslist.org", geo_listing_us070209.sites["omaha / council bluffs"]
    assert_equal "orangecounty.craigslist.org", geo_listing_us070209.sites["orange county"]
    assert_equal "oregoncoast.craigslist.org", geo_listing_us070209.sites["oregon coast"]
    assert_equal "orlando.craigslist.org", geo_listing_us070209.sites["orlando"]
    assert_equal "outerbanks.craigslist.org", geo_listing_us070209.sites["outer banks"]
    assert_equal "palmsprings.craigslist.org", geo_listing_us070209.sites["palm springs, CA"]
    assert_equal "panamacity.craigslist.org", geo_listing_us070209.sites["panama city, FL"]
    assert_equal "parkersburg.craigslist.org", geo_listing_us070209.sites["parkersburg-marietta"]
    assert_equal "pensacola.craigslist.org", geo_listing_us070209.sites["pensacola / panhandle"]
    assert_equal "peoria.craigslist.org", geo_listing_us070209.sites["peoria"]
    assert_equal "philadelphia.craigslist.org", geo_listing_us070209.sites["philadelphia"]
    assert_equal "phoenix.craigslist.org", geo_listing_us070209.sites["phoenix"]
    assert_equal "pittsburgh.craigslist.org", geo_listing_us070209.sites["pittsburgh"]
    assert_equal "plattsburgh.craigslist.org", geo_listing_us070209.sites["plattsburgh-adirondacks"]
    assert_equal "poconos.craigslist.org", geo_listing_us070209.sites["poconos"]
    assert_equal "porthuron.craigslist.org", geo_listing_us070209.sites["port huron"]
    assert_equal "portland.craigslist.org", geo_listing_us070209.sites["portland, OR"]
    assert_equal "prescott.craigslist.org", geo_listing_us070209.sites["prescott"]
    assert_equal "provo.craigslist.org", geo_listing_us070209.sites["provo / orem"]
    assert_equal "pueblo.craigslist.org", geo_listing_us070209.sites["pueblo"]
    assert_equal "pullman.craigslist.org", geo_listing_us070209.sites["pullman / moscow"]
    assert_equal "quadcities.craigslist.org", geo_listing_us070209.sites["quad cities, IA/IL"]
    assert_equal "raleigh.craigslist.org", geo_listing_us070209.sites["raleigh / durham / CH"]
    assert_equal "reading.craigslist.org", geo_listing_us070209.sites["reading"]
    assert_equal "redding.craigslist.org", geo_listing_us070209.sites["redding"]
    assert_equal "reno.craigslist.org", geo_listing_us070209.sites["reno / tahoe"]
    assert_equal "providence.craigslist.org", geo_listing_us070209.sites["rhode island"]
    assert_equal "richmond.craigslist.org", geo_listing_us070209.sites["richmond"]
    assert_equal "roanoke.craigslist.org", geo_listing_us070209.sites["roanoke"]
    assert_equal "rmn.craigslist.org", geo_listing_us070209.sites["rochester, MN"]
    assert_equal "rochester.craigslist.org", geo_listing_us070209.sites["rochester, NY"]
    assert_equal "rockford.craigslist.org", geo_listing_us070209.sites["rockford"]
    assert_equal "rockies.craigslist.org", geo_listing_us070209.sites["rocky mountains"]
    assert_equal "roseburg.craigslist.org", geo_listing_us070209.sites["roseburg"]
    assert_equal "roswell.craigslist.org", geo_listing_us070209.sites["roswell / carlsbad"]
    assert_equal "sacramento.craigslist.org", geo_listing_us070209.sites["sacramento"]
    assert_equal "saginaw.craigslist.org", geo_listing_us070209.sites["saginaw-midland-baycity"]
    assert_equal "salem.craigslist.org", geo_listing_us070209.sites["salem, OR"]
    assert_equal "saltlakecity.craigslist.org", geo_listing_us070209.sites["salt lake city"]
    assert_equal "sanantonio.craigslist.org", geo_listing_us070209.sites["san antonio"]
    assert_equal "sandiego.craigslist.org", geo_listing_us070209.sites["san diego"]
    assert_equal "slo.craigslist.org", geo_listing_us070209.sites["san luis obispo"]
    assert_equal "sanmarcos.craigslist.org", geo_listing_us070209.sites["san marcos"]
    assert_equal "sandusky.craigslist.org", geo_listing_us070209.sites["sandusky"]
    assert_equal "santabarbara.craigslist.org", geo_listing_us070209.sites["santa barbara"]
    assert_equal "santafe.craigslist.org", geo_listing_us070209.sites["santa fe / taos"]
    assert_equal "sarasota.craigslist.org", geo_listing_us070209.sites["sarasota-bradenton"]
    assert_equal "savannah.craigslist.org", geo_listing_us070209.sites["savannah"]
    assert_equal "scranton.craigslist.org", geo_listing_us070209.sites["scranton / wilkes-barre"]
    assert_equal "seattle.craigslist.org", geo_listing_us070209.sites["seattle-tacoma"]
    assert_equal "sheboygan.craigslist.org", geo_listing_us070209.sites["sheboygan, WI"]
    assert_equal "shreveport.craigslist.org", geo_listing_us070209.sites["shreveport"]
    assert_equal "sierravista.craigslist.org", geo_listing_us070209.sites["sierra vista"]
    assert_equal "siouxcity.craigslist.org", geo_listing_us070209.sites["sioux city, IA"]
    assert_equal "skagit.craigslist.org", geo_listing_us070209.sites["skagit / island / SJI"]
    assert_equal "southbend.craigslist.org", geo_listing_us070209.sites["south bend / michiana"]
    assert_equal "southcoast.craigslist.org", geo_listing_us070209.sites["south coast"]
    assert_equal "sd.craigslist.org", geo_listing_us070209.sites["south dakota"]
    assert_equal "miami.craigslist.org", geo_listing_us070209.sites["south florida"]
    assert_equal "southjersey.craigslist.org", geo_listing_us070209.sites["south jersey"]
    assert_equal "semo.craigslist.org", geo_listing_us070209.sites["southeast missouri"]
    assert_equal "smd.craigslist.org", geo_listing_us070209.sites["southern maryland"]
    assert_equal "swmi.craigslist.org", geo_listing_us070209.sites["southwest michigan"]
    assert_equal "spacecoast.craigslist.org", geo_listing_us070209.sites["space coast"]
    assert_equal "spokane.craigslist.org", geo_listing_us070209.sites["spokane / coeur d'alene"]
    assert_equal "springfieldil.craigslist.org", geo_listing_us070209.sites["springfield, IL"]
    assert_equal "springfield.craigslist.org", geo_listing_us070209.sites["springfield, MO"]
    assert_equal "staugustine.craigslist.org", geo_listing_us070209.sites["st augustine"]
    assert_equal "stcloud.craigslist.org", geo_listing_us070209.sites["st cloud"]
    assert_equal "stgeorge.craigslist.org", geo_listing_us070209.sites["st george"]
    assert_equal "stlouis.craigslist.org", geo_listing_us070209.sites["st louis, MO"]
    assert_equal "pennstate.craigslist.org", geo_listing_us070209.sites["state college"]
    assert_equal "stillwater.craigslist.org", geo_listing_us070209.sites["stillwater"]
    assert_equal "stockton.craigslist.org", geo_listing_us070209.sites["stockton"]
    assert_equal "syracuse.craigslist.org", geo_listing_us070209.sites["syracuse"]
    assert_equal "tallahassee.craigslist.org", geo_listing_us070209.sites["tallahassee"]
    assert_equal "tampa.craigslist.org", geo_listing_us070209.sites["tampa bay area"]
    assert_equal "terrahaute.craigslist.org", geo_listing_us070209.sites["terre haute"]
    assert_equal "texarkana.craigslist.org", geo_listing_us070209.sites["texarkana"]
    assert_equal "toledo.craigslist.org", geo_listing_us070209.sites["toledo"]
    assert_equal "topeka.craigslist.org", geo_listing_us070209.sites["topeka"]
    assert_equal "treasure.craigslist.org", geo_listing_us070209.sites["treasure coast"]
    assert_equal "tricities.craigslist.org", geo_listing_us070209.sites["tri-cities, TN"]
    assert_equal "tucson.craigslist.org", geo_listing_us070209.sites["tucson"]
    assert_equal "tulsa.craigslist.org", geo_listing_us070209.sites["tulsa"]
    assert_equal "tuscaloosa.craigslist.org", geo_listing_us070209.sites["tuscaloosa"]
    assert_equal "twinfalls.craigslist.org", geo_listing_us070209.sites["twin falls"]
    assert_equal "easttexas.craigslist.org", geo_listing_us070209.sites["tyler / east TX"]
    assert_equal "up.craigslist.org", geo_listing_us070209.sites["upper peninsula"]
    assert_equal "utica.craigslist.org", geo_listing_us070209.sites["utica"]
    assert_equal "valdosta.craigslist.org", geo_listing_us070209.sites["valdosta"]
    assert_equal "ventura.craigslist.org", geo_listing_us070209.sites["ventura county"]
    assert_equal "burlington.craigslist.org", geo_listing_us070209.sites["vermont"]
    assert_equal "victoriatx.craigslist.org", geo_listing_us070209.sites["victoria, TX"]
    assert_equal "visalia.craigslist.org", geo_listing_us070209.sites["visalia-tulare"]
    assert_equal "waco.craigslist.org", geo_listing_us070209.sites["waco"]
    assert_equal "washingtondc.craigslist.org", geo_listing_us070209.sites["washington, DC"]
    assert_equal "waterloo.craigslist.org", geo_listing_us070209.sites["waterloo / cedar falls"]
    assert_equal "watertown.craigslist.org", geo_listing_us070209.sites["watertown"]
    assert_equal "wausau.craigslist.org", geo_listing_us070209.sites["wausau"]
    assert_equal "wenatchee.craigslist.org", geo_listing_us070209.sites["wenatchee"]
    assert_equal "wv.craigslist.org", geo_listing_us070209.sites["west virginia (old)"]
    assert_equal "westky.craigslist.org", geo_listing_us070209.sites["western KY"]
    assert_equal "westmd.craigslist.org", geo_listing_us070209.sites["western maryland"]
    assert_equal "westernmass.craigslist.org", geo_listing_us070209.sites["western massachusetts"]
    assert_equal "westslope.craigslist.org", geo_listing_us070209.sites["western slope"]
    assert_equal "wheeling.craigslist.org", geo_listing_us070209.sites["wheeling, WV"]
    assert_equal "wichita.craigslist.org", geo_listing_us070209.sites["wichita"]
    assert_equal "wichitafalls.craigslist.org", geo_listing_us070209.sites["wichita falls"]
    assert_equal "williamsport.craigslist.org", geo_listing_us070209.sites["williamsport"]
    assert_equal "wilmington.craigslist.org", geo_listing_us070209.sites["wilmington, NC"]
    assert_equal "winstonsalem.craigslist.org", geo_listing_us070209.sites["winston-salem"]
    assert_equal "worcester.craigslist.org", geo_listing_us070209.sites["worcester / central MA"]
    assert_equal "wyoming.craigslist.org", geo_listing_us070209.sites["wyoming"]
    assert_equal "yakima.craigslist.org", geo_listing_us070209.sites["yakima"]
    assert_equal "york.craigslist.org", geo_listing_us070209.sites["york, PA"]
    assert_equal "youngstown.craigslist.org", geo_listing_us070209.sites["youngstown"]
    assert_equal "yubasutter.craigslist.org", geo_listing_us070209.sites["yuba-sutter"]
    assert_equal "yuma.craigslist.org", geo_listing_us070209.sites["yuma"]
    
    geo_listing_cn070209 = CraigScrape::GeoListings.new relative_uri_for(
      'geolisting_samples/geo_listing_cn070209.html'
    )     
    assert_equal "china", geo_listing_cn070209.location
    assert_equal 6, geo_listing_cn070209.sites.length
    assert_equal "beijing.craigslist.com.cn", geo_listing_cn070209.sites["beijing"]
    assert_equal "guangzhou.craigslist.com.cn", geo_listing_cn070209.sites["guangzhou"]
    assert_equal "hangzhou.craigslist.org", geo_listing_cn070209.sites["hangzhou"]
    assert_equal "hongkong.craigslist.org", geo_listing_cn070209.sites["hong kong"]
    assert_equal "shanghai.craigslist.com.cn", geo_listing_cn070209.sites["shanghai"]
    assert_equal "shenzhen.craigslist.org", geo_listing_cn070209.sites["shenzhen"]
    
    geo_listing_ca070209 = CraigScrape::GeoListings.new relative_uri_for(
      'geolisting_samples/geo_listing_ca070209.html'
    )     
    assert_equal "canada", geo_listing_ca070209.location
    assert_equal 47, geo_listing_ca070209.sites.length
    assert_equal "barrie.craigslist.ca", geo_listing_ca070209.sites["barrie"]
    assert_equal "belleville.craigslist.ca", geo_listing_ca070209.sites["belleville, ON"]
    assert_equal "calgary.craigslist.ca", geo_listing_ca070209.sites["calgary"]
    assert_equal "chatham.craigslist.ca", geo_listing_ca070209.sites["chatham-kent"]
    assert_equal "comoxvalley.craigslist.ca", geo_listing_ca070209.sites["comox valley"]
    assert_equal "cornwall.craigslist.ca", geo_listing_ca070209.sites["cornwall, ON"]
    assert_equal "cranbrook.craigslist.ca", geo_listing_ca070209.sites["cranbrook, BC"]
    assert_equal "edmonton.craigslist.ca", geo_listing_ca070209.sites["edmonton"]
    assert_equal "abbotsford.craigslist.ca", geo_listing_ca070209.sites["fraser valley"]
    assert_equal "ftmcmurray.craigslist.ca", geo_listing_ca070209.sites["ft mcmurray"]
    assert_equal "guelph.craigslist.ca", geo_listing_ca070209.sites["guelph"]
    assert_equal "halifax.craigslist.ca", geo_listing_ca070209.sites["halifax"]
    assert_equal "hamilton.craigslist.ca", geo_listing_ca070209.sites["hamilton-burlington"]
    assert_equal "kamloops.craigslist.ca", geo_listing_ca070209.sites["kamloops"]
    assert_equal "kelowna.craigslist.ca", geo_listing_ca070209.sites["kelowna"]
    assert_equal "kingston.craigslist.ca", geo_listing_ca070209.sites["kingston, ON"]
    assert_equal "kitchener.craigslist.ca", geo_listing_ca070209.sites["kitchener-waterloo-cambridge"]
    assert_equal "lethbridge.craigslist.ca", geo_listing_ca070209.sites["lethbridge"]
    assert_equal "londonon.craigslist.ca", geo_listing_ca070209.sites["london, ON"]
    assert_equal "montreal.craigslist.ca", geo_listing_ca070209.sites["montreal"]
    assert_equal "nanaimo.craigslist.ca", geo_listing_ca070209.sites["nanaimo"]
    assert_equal "newbrunswick.craigslist.ca", geo_listing_ca070209.sites["new brunswick"]
    assert_equal "newfoundland.craigslist.ca", geo_listing_ca070209.sites["newfoundland / labrador"]
    assert_equal "niagara.craigslist.ca", geo_listing_ca070209.sites["niagara region"]
    assert_equal "ottawa.craigslist.ca", geo_listing_ca070209.sites["ottawa-hull-gatineau"]
    assert_equal "owensound.craigslist.ca", geo_listing_ca070209.sites["owen sound"]
    assert_equal "peterborough.craigslist.ca", geo_listing_ca070209.sites["peterborough"]
    assert_equal "pei.craigslist.ca", geo_listing_ca070209.sites["prince edward island"]
    assert_equal "princegeorge.craigslist.ca", geo_listing_ca070209.sites["prince george"]
    assert_equal "quebec.craigslist.ca", geo_listing_ca070209.sites["quebec city"]
    assert_equal "reddeer.craigslist.ca", geo_listing_ca070209.sites["red deer"]
    assert_equal "regina.craigslist.ca", geo_listing_ca070209.sites["regina"]
    assert_equal "saguenay.craigslist.ca", geo_listing_ca070209.sites["saguenay"]
    assert_equal "sarnia.craigslist.ca", geo_listing_ca070209.sites["sarnia"]
    assert_equal "saskatoon.craigslist.ca", geo_listing_ca070209.sites["saskatoon"]
    assert_equal "soo.craigslist.ca", geo_listing_ca070209.sites["sault ste marie, ON"]
    assert_equal "sherbrooke.craigslist.ca", geo_listing_ca070209.sites["sherbrooke"]
    assert_equal "sudbury.craigslist.ca", geo_listing_ca070209.sites["sudbury"]
    assert_equal "territories.craigslist.ca", geo_listing_ca070209.sites["territories"]
    assert_equal "thunderbay.craigslist.ca", geo_listing_ca070209.sites["thunder bay"]
    assert_equal "toronto.craigslist.ca", geo_listing_ca070209.sites["toronto"]
    assert_equal "troisrivieres.craigslist.ca", geo_listing_ca070209.sites["trois-rivieres"]
    assert_equal "vancouver.craigslist.ca", geo_listing_ca070209.sites["vancouver, BC"]
    assert_equal "victoria.craigslist.ca", geo_listing_ca070209.sites["victoria"]
    assert_equal "whistler.craigslist.ca", geo_listing_ca070209.sites["whistler, BC"]
    assert_equal "windsor.craigslist.ca", geo_listing_ca070209.sites["windsor"]
    assert_equal "winnipeg.craigslist.ca", geo_listing_ca070209.sites["winnipeg"]
    
    geo_listing_ca_sk07020 = CraigScrape::GeoListings.new relative_uri_for(
      'geolisting_samples/geo_listing_ca_sk070209.html'
    )     
    assert_equal "canada", geo_listing_ca_sk07020.location
    assert_equal( 
      { "saskatoon" => "saskatoon.craigslist.ca", "regina" => "regina.craigslist.ca" }, 
      geo_listing_ca_sk07020.sites
    )
  end
  
  def test_sites_in_path
    # This was really tough to test, and in the end, I don't know just how useful this really is...
    hier_dir = relative_uri_for 'geolisting_samples/hierarchy_test071009/'
        
    %w(
      us/fl/miami /us/fl/miami/ us/fl/miami/ /us/fl/miami us/fl/miami/nonsense 
      us/fl/miami/nonsense/more-nonsense us/fl/miami/south\ florida
    ).each do |path|
      assert_equal ["miami.craigslist.org"], CraigScrape::GeoListings.sites_in_path( path, hier_dir )
    end
    
    %w( us/fl /us/fl us/fl/ /us/fl/ ).each do |path|
      assert_equal(
        %w(
          jacksonville panamacity orlando fortmyers keys tallahassee ocala gainesville tampa
          pensacola daytona treasure sarasota staugustine spacecoast lakeland miami
        ).collect{|p| "#{p}.craigslist.org"},
        CraigScrape::GeoListings.sites_in_path( path, hier_dir )
      )
    end
    
    # This tests those escaped funky paths. I *think* this file-based test is actually indicative
    # that the http-retrieval version works as well;
    us_fl_mia_ftmeyers = CraigScrape::GeoListings.sites_in_path(
      "us/fl/ft myers \\/ SW florida", hier_dir
    )
    assert_equal ["fortmyers.craigslist.org"], us_fl_mia_ftmeyers
    
    # make sure we puke on obvious bad-stuff. I *think* this file-based test is actually indicative
    # that the http-retrieval version works as well:
    assert_raise(CraigScrape::GeoListings::BadGeoListingPath) do
      CraigScrape::GeoListings.sites_in_path "us/fl/nonexist", hier_dir
    end
    
    assert_raise(CraigScrape::GeoListings::BadGeoListingPath) do
      # You'll notice that we could actually guess a decent match, but we wont :
      CraigScrape::GeoListings.sites_in_path "us/fl/miami/nonexist", hier_dir
    end
  end

  def test_sites_in_path
    hier_dir = relative_uri_for 'geolisting_samples/hierarchy_test071009/'

    assert_equal(
      %w(miami.craigslist.org), 
      CraigScrape::GeoListings.find_sites( 
        ["us/fl/south florida","+ us/fl/south florida", "-newyork.craigslist.org"], 
        hier_dir
      )
    )
    
    assert_equal(
      %w(
        jacksonville panamacity orlando fortmyers keys tallahassee ocala gainesville tampa 
        pensacola daytona treasure sarasota staugustine spacecoast lakeland newyork
      ).collect{|p| "#{p}.craigslist.org"},
      CraigScrape::GeoListings.find_sites( ["us/fl","-us/fl/miami", "+ newyork.craigslist.org"], hier_dir)
    )

    assert_equal(
      %w(
      westmd fortcollins charleston fayetteville dallas mendocino wichita valdosta terrahaute rockford erie 
      decatur cedarrapids stillwater collegestation charlestonwv albany sacramento houston kalamazoo fortsmith 
      maine minneapolis stockton pennstate bend grandisland palmsprings nmi waterloo topeka eastnc greenbay york
      utica stgeorge oklahomacity grandrapids eastidaho lancaster gulfport sandiego reading kpr fresno iowacity 
      chicago tuscaloosa smd monterey yubasutter victoriatx sd knoxville gadsden jonesboro ksu youngstown toledo 
      lascruces annarbor danville delaware parkersburg appleton stcloud richmond muskegon jerseyshore redding 
      ithaca hartford evansville corpuschristi binghamton chico modesto lynchburg hattiesburg morgantown 
      harrisonburg lubbock carbondale florencesc imperial wenatchee semo savannah prescott lacrosse longisland 
      huntsville santabarbara janesville mankato santafe pullman louisville lexington brunswick duluth columbus 
      hudsonvalley pittsburgh wheeling westky waco shreveport eastoregon corvallis winstonsalem denver 
      tippecanoe newhaven shoals wv greenville lansing detroit athensohio easttexas sanantonio raleigh phoenix 
      honolulu inlandempire pueblo chattanooga lawton worcester twinfalls roseburg roanoke fredericksburg 
      annapolis asheville seattle scranton quadcities oregoncoast stlouis newyork mobile atlanta visalia 
      clarksville providence kansascity galveston madison bham harrisburg muncie bloomington anchorage ventura 
      up tricities rockies elpaso slo indianapolis fayar columbusga bellingham abilene wichitafalls boston 
      mcallen bn sierravista lasvegas sanmarcos nwct farmington mansfield jacksontn bgky altoona eugene 
      lafayette boone odessa spokane norfolk hickory burlington nashville lawrence hiltonhead elmira westernmass 
      southjersey myrtlebeach dothan goldcountry lincoln martinsburg dubuque brownsville washingtondc tucson 
      columbiamo jxn yakima sheboygan olympic humboldt newjersey cosprings springfield beaumont macon eauclaire 
      batonrouge buffalo mohave wilmington rochester sfbay northmiss bakersfield neworleans catskills wausau 
      akroncanton cnj merced chambana flint capecod nh yuma tulsa charlottesville easternshore desmoines 
      athensga austin newlondon outerbanks fortwayne dayton wyoming watertown provo medford texarkana cleveland 
      memphis amarillo limaohio augusta flagstaff jackson plattsburgh peoria skagit saltlakecity saginaw 
      portland syracuse swmi baltimore monroe littlerock boise laredo boulder philadelphia sandusky salem rmn 
      montgomery blacksburg centralmich logan albuquerque losangeles poconos westslope southbend siouxcity reno 
      porthuron greensboro orangecounty fargo ogden charlotte allentown joplin chautauqua lakecharles omaha 
      springfieldil roswell montana killeen milwaukee nd williamsport columbia racine southcoast ames huntington 
      cincinnati auburn miami
      ).collect{|p| "#{p}.craigslist.org"},
      CraigScrape::GeoListings.find_sites(
        ["us","- us/fl", "+ us/fl/miami", ' -jacksonville.craigslist.org'], hier_dir
      )
    )
    
  end

end