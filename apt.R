install.packages("dplyr")
install.packages("devtools")
library(devtools)
install_github("dkahle/ggmap")
library(ggmap)
library(dplyr)
stadata <- read.csv("C:/Users/user/Google 드라이브/경기과학기술대/3_2/07. 빅데이터/APT/4호선.csv")
#Google API Key 등록
googleAPIkey <- "Google API Key"
register_google(googleAPIkey)
station_code <- as.character(stadata$"구주소")
station_code <- geocode(station_code)
station_code <- as.character(stadata$구주소) %>% enc2utf8() %>% geocode()
station_last <- cbind(stadata, station_code)
aptdata <- read.csv("C:/Users/user/Google 드라이브/경기과학기술대/3_2/07. 빅데이터/APT/아파트.csv")
aptdata$전용면적 = round(aptdata$전용면적)
count(aptdata, 전용면적) %>% arrange(desc(n))
apt85 <- subset(aptdata, 전용면적=="85")
apt85$거래금액 <- gsub(",","",apt85$거래금액)
apt85avg <- aggregate(as.integer(거래금액) ~ 단지명, apt85, mean)
apt85avg <- rename(apt85avg, "거래금액" = "as.integer(거래금액)")
apt85 <- apt85[!duplicated(apt85$단지명),]
apt85 <- left_join(apt85, apt85avg, by="단지명")
apt85 <- apt85 %>% select("단지명","시군구","번지","전용면적","거래금액")
apt85 <- rename(apt85, "거래금액" = "거래금액.y")
aptadd <- paste(apt85$시군구, apt85$번지)
#head(aptadd)
aptadd <- paste(apt85$"시군구", apt85$"번지") %>% data.frame()
aptadd <- rename(aptadd, "주소" = ".")
head(aptadd)
aptl <- as.character(aptadd$주소) %>% enc2utf8() %>% geocode()
aptlast <- cbind(apt85, aptadd, aptl) %>% select("단지명","전용면적","거래금액","주소",lon,lat)
#head(aptlast)
dongjak <- get_googlemap("isu station",maptype = "roadmap",zoom=15)
ggmap(dongjak)
install.packages("ggplot2")
library(ggplot2)
ggmap(dongjak) + 
  geom_point(data = station_last, aes(x = lon, y=lat),colour = "blue", size=2) +
  geom_text(data = station_last, aes(label=역명, vjust = -1))+
  geom_point(data = aptlast, aes(x=lon, y=lat))+
  geom_text(data = aptlast,aes(label=단지명, vjust=-1))+
  geom_text(data=aptlast,aes(label=거래금액, vjust=1))
