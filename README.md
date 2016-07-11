# Zenvidia
Un script bash/zenity pour gérer les pilotes propriétaires **NVIDIA©**.

Avant propos
------------
Je ne suis pas un codeur, le script est parfois très approximatif et a besoin de très nombreuses améliorations.
Les tests ont été fait principalement en discret-graphic card pour **optimus** et **Bumblebee**. Je n'ai pas le matériel pour tester efficacement pour GPU unique.

C'est du hard developpement et il faut s'attendre à des plantages du serveur **X** pour les testeur sur GPU unique.

Développé sous Fedora 22, puis 23, le script ne devrait pas apporté de bug majeur pour les utilisateurs de **Bumblebee** sous cette distribution.

Pour l'amélioration du support multi distribution, il fadra envisager un mode de "plugin par distro" qui n'a pas ecore été développé pour le moment.


# Introduction

Le projet initial, **Bashvidia**, est né au alentour de l'année 2010 en tant que projet personnel pour amélioré la maintenance des pilotes **NVIDIA©** dont l'interface **ncurse** montrait rapidement ses limites selon la distribution utilisée et aussi pour palier au manque cruel de paquets distribués à cette époque.

Son seul objectif à ce moment-là était de controler les mise à jour, les télécharger et les installer.
Il a rapidement évolué vers une interface permettant de gérer n'importe quel type de pilote afin de pouvoir les sauvegarder et les restaurer rapidement en cas de problème.

L'interface graphique était une continuité naturelle, cependant le binaire **nvidia-installer** limitait un usage sous **X** et le projet tout d'abord mis à disposition sur **GoogleCode** est resté à l'abandon.

Depuis **nvidia-installer** a évolué, de nouvelles options sont apparues, mais plutôt que de permettre simplement l'installation directement sous **X**, il laisse de possibilité de contourner le "tout terminal" qui semble tant lui tenir à cœur.

Le projet de l'interface **Zenivia** a été initié dans le courant de l'année 2015, surtout pour permettre une meilleure gestion des **Discret Graphic Cards** et d'**Optimus**.

Opérations actuellement disponibles
===================================
Installation des pilotes
------------------------
  
 - depuis un paquet local.
 - depuis une archive téléchargée.
 - directement depuis le serveur NVIDIA©.
 - Installation d'optimus depuis les projets GIT.

Mises à jour
------------

 - Contrôle des mises à jour pilote.
 - Mise à jour d'un nouveau kernel (option dkms ou non).
 - Mise à jour d'optimus depuis les projets GIT.

Outils
------

 - Édition de fichier xorg.conf (détection auto d'optimus).
 - Édition de configuration Zenvidia.
 - Démarrage de Nvidia-Settings (détection auto d'optimus).
 - Gestion des pilotes installés (suppression, archivage).
 - Re-compilation des divers dépendances (Bumblebee, etc).

Tests et support
----------------

 - Test GLX.
 - Manuel et journal des modifications du pilote installé.
 
------------
Installation
============
Avant-propos
------------
Toutes les dépendances s'installent au premier démarrage du script.

Exécution
---------
Depuis un terminal, décompresser l'archive tar.gz. Entrer dans le répertoire créé, puis lancer le script **install.sh**.
Répondre au questions. Valider. C'est terminé.

L'installateur permet d'éditer le fichier de configuration après installation, c'est cependant optionnel.

-------
Licence
=======
Zenvidia and Bashvidia are published under GNU/GPL
--------------------------------------------------

Copyleft PirateProd - Licence GPL v.3

This program is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along with main.c; if not, write to the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor Boston, MA 02110-1301,  USA


