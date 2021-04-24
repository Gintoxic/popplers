library(readxl)

xlsx.path<-"./daten/destatis/AuszugGV1QAktuell.xlsx"

pop_imp<-read_excel(xlsx.path, sheet = "Onlineprodukt_Gemeinden")

str(pop_raw)
dim(pop_raw)

pop_raw<-pop_imp[6:16083, ]
head(pop_raw)

pop_names<-c("satzart", "text_kz", "land", "rb", "kreis", "vb", "gem", "gemeindename", "flaeche", "bev_ges", "bev_m", "bev_w", "je_km","plz", "lng", "lat", "reisegebiete", "reisegebiete_bez", "verstaedterung", "verstaedterung_bez")
colnames(pop_raw)<-pop_names

