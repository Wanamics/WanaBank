# WanaBank
Business Central dispose d’une fonctionnalité de rapprochement bancaire,
dont l’efficacité a bien progressé de version en version, mais il reste une
lacune incompréhensible pour les utilisateurs de la version française :

"A quoi cela sert il d’automatiser le rapprochement s’il faut préalablement
saisir les lignes du relevé bancaire ?"

La fonction d’import largement paramétrable proposée à cet effet a du mal à ingurgiter le format ‘CFONB120’ (parfois nommé ETEBAC par abus de langage) proposé par les banques françaises.

Alors, en attendant la généralisation du format CAMT.053 défini par les normes SEPA et censé le remplacer depuis bien longtemps, je vous partage une extension dédiée au format historique.

Outre l’import des lignes proprement dites, les commentaires souvent utiles au rapprochement sont également repris et proposé dans le volet des récapitulatifs.

De plus, un état de rapprochement vous permettra d’analyser les écritures non rapprochées pour justifier l’écart entre le solde du compte bancaire de Business Central et celui de votre relevé.

Enfin, s’il vous arrive encore de recevoir des règlements par chèques, vous trouverez un bordereau de remise amélioré.
