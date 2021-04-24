library(readxl)
library(dplyr)
library(readr)

xlsx.path<-"./daten/destatis/AuszugGV1QAktuell.xlsx"

pop_imp<-read_excel(xlsx.path, sheet = "Onlineprodukt_Gemeinden")

str(pop_imp)
dim(pop_imp)

pop_names<-c("satzart", "text_kz", "land", "rb", "kreis", "vb", "gem", "gemeindename", "flaeche", "bev_ges", "bev_m", "bev_w", "je_km","plz", "lng", "lat", "reisegebiete", "reisegebiete_bez", "verstaedterung", "verstaedterung_bez")
colnames(pop_imp)<-pop_names

pop_raw<-pop_imp[6:16083, ]%>%filter(!is.na(gemeindename))
head(pop_raw)


pop_temp<-pop_raw%>%filter(!is.na(bev_ges))

pop<-pop_raw%>%filter(!is.na(bev_ges))%>%select(-flaeche, -bev_ges, -bev_m, -bev_w, -je_km, -lng, -lat)

cols.num<-c("flaeche", "bev_ges", "bev_m", "bev_w", "je_km", "lng", "lat")

for (i in cols.num)
{
  pop[,i]<-pop_temp[,i]%>%
    unlist()%>%
    readr::parse_number(locale = readr::locale(decimal_mark = ","))
}

ref_land<-  pop_raw%>%   filter(is.na(rb))                    %>%select(land,             gemeindename)
ref_rb<-    pop_raw%>%   filter(is.na(kreis) & !is.na(rb))    %>%select(land,rb,          gemeindename)
ref_kreis<- pop_raw%>%   filter(is.na(vb)    & !is.na(kreis)) %>%select(land,rb,kreis,    gemeindename)
ref_vb<-    pop_raw%>%   filter(is.na(gem)   & !is.na(vb))    %>%select(land,rb,kreis,vb,gemeindename)
ref_gem<-   pop_raw%>%   filter(               !is.na(gem))   %>%select(land,rb,kreis,vb,gem, gemeindename)

#sum(pop$bev_ges)
#save(file="pop_temp.Rdata", "pop")
rm(list="pop")
load(file="pop_temp.Rdata")

pop<-left_join(pop,ref_land%>%select(land,land_text=gemeindename), by="land")
pop<-left_join(pop,ref_rb%>%select(land,rb,rb_text=gemeindename), by=(c("land", "rb")))
pop<-left_join(pop,ref_kreis%>%select(land,rb,kreis,kreis_text=gemeindename), by=(c("land", "rb", "kreis")))
pop<-left_join(pop,ref_vb%>%select(land,rb,kreis,vb,vb_text=gemeindename), by=(c("land", "rb", "kreis", "vb")))

table(pop$rb_text,pop$land_text)

pop%>%group_by(land_text)%>%summarize(n_distinct(rb))

#Clear
rm(list="pop_temp")

save(file="pop.Rdata", "pop")
write.table(pop, file = "pop.csv", row.names = F, sep = ";")
head(pop)


rlp<-pop%>%filter(land_text=="Rheinland-Pfalz", gemeindename=="Koblenz, Stadt")
