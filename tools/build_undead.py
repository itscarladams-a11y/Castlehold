"""Castlehold wave-120 undead assets.
Original procedural geometry built on the project's existing articulated ogre rig.
No downloaded models or textures.
"""
from build_characters import color
from build_horde import HordeModel
import build_bosses
from build_bosses import BossModel


class SkeletonOgreModel(HordeModel):
    def __init__(self):
        super().__init__('ogre')
        # Keep the ogre anatomy/animation behavior but save a distinct asset ID.
        self.kind = 'ogre_skeleton'
        self.enemy = True
        self.ogre = True

    def build(self):
        bone = color('d8cda8')
        old_bone = color('b7aa86')
        dark = color('1e2422')
        iron = color('4b514e')
        rust = color('784638')
        cloth = color('433746')
        sick = color('7fa36b')
        self.surfaces.update({bone:'bone',old_bone:'bone',dark:'hair',iron:'iron',rust:'cloth',cloth:'cloth',sick:'skin'})
        self.finishes.update({bone:(.90,0.0),old_bone:(.94,0.0),iron:(.48,.64),rust:(.76,.12),cloth:(.86,0.0)})

        # Pelvis and exposed spine.
        self.ell((0,-.02,0),(.43,.25,.30),old_bone,1,14)
        self.ell((-.23,-.01,-.01),(.23,.20,.24),bone,1,12)
        self.ell((.23,-.01,-.01),(.23,.20,.24),bone,1,12)
        self.tube((0,-.08,0),(0,.64,.03),.075,bone,1,10)
        self.ell((0,.58,.03),(.12,.12,.10),old_bone,1,10)

        # Sternum, clavicles and four broad rib pairs. Segmented ribs make the
        # torso read as a skeleton even at phone scale.
        self.tube((0,-.08,-.16),(0,.40,-.18),.055,old_bone,2,8)
        for y,width in [(.34,.48),(.22,.55),(.08,.58),(-.07,.52)]:
            for sign in (-1,1):
                self.tube((0,y,-.12),(sign*width*.58,y+.035,-.10),.038,bone,2,7)
                self.tube((sign*width*.58,y+.035,-.10),(sign*width,y-.10,.04),.035,bone,2,7)
        self.tube((-.38,.37,-.04),(.38,.37,-.04),.065,bone,2,9)

        # Ogre skull, brow, eye sockets, nasal cavity and lower jaw.
        self.ell((0,.02,-.04),(.36,.30,.30),bone,3,18)
        self.ell((0,-.17,-.14),(.30,.13,.22),old_bone,3,14)
        for sign in (-1,1):
            self.ell((sign*.13,.07,-.285),(.095,.075,.045),dark,3,12)
            self.tube((sign*.05,.17,-.23),(sign*.24,.18,-.18),.048,old_bone,3,8)
            self.spike((sign*.18,-.18,-.24),(sign*.23,-.04,-.33),.035,bone,3)
        self.ell((0,-.015,-.31),(.055,.075,.035),dark,3,10)
        self.tube((-.23,-.23,-.18),(.23,-.23,-.18),.048,old_bone,17,8)
        for x in (-.15,-.075,0,.075,.15):
            self.spike((x,-.19,-.25),(x,-.29,-.26),.023,bone,17)
        # A sickly rune stone set into the forehead distinguishes raised ogres.
        self.ell((0,.18,-.305),(.055,.055,.025),sick,3,10)

        # Heavy skeletal arms. Joints are deliberately oversized for readability.
        for upper,fore,hand,sign in [(4,5,6,-1),(7,8,9,1)]:
            self.ell((0,-.02,0),(.13,.13,.13),old_bone,upper,10)
            self.tube((0,-.03,0),(0,-.46,0),.082,bone,upper,9)
            self.ell((0,-.46,0),(.105,.105,.10),old_bone,upper,10)
            self.tube((0,-.02,0),(0,-.39,0),.065,bone,fore,9)
            self.ell((0,-.38,0),(.085,.085,.075),old_bone,fore,9)
            self.ell((0,-.06,-.02),(.13,.10,.12),bone,hand,10)
            for finger in (-.07,0,.07):
                self.tube((finger,-.08,-.07),(finger,-.24,-.13),.022,bone,hand,6)
            if sign < 0:
                # One battered pauldron and hanging strap keep the silhouette medieval.
                self.ell((-.04,.04,.02),(.31,.15,.27),iron,upper,14)
                self.tube((-.23,.02,.04),(-.15,-.30,.03),.025,rust,upper,7)

        # Femurs, knees, shins and long bony feet.
        for thigh,shin,foot in [(10,11,12),(13,14,15)]:
            self.ell((0,-.02,0),(.145,.12,.13),old_bone,thigh,10)
            self.tube((0,-.04,0),(0,-.53,0),.095,bone,thigh,10)
            self.ell((0,-.52,0),(.12,.11,.115),old_bone,thigh,10)
            self.tube((0,-.03,0),(0,-.48,0),.073,bone,shin,9)
            self.ell((0,-.47,0),(.095,.09,.09),old_bone,shin,9)
            self.ell((0,-.05,-.13),(.15,.09,.27),bone,foot,10)
            for x in (-.10,0,.10):
                self.spike((x,-.05,-.27),(x,-.06,-.43),.025,old_bone,foot)

        # Tattered burial cloth and a crude femur-and-iron execution club.
        for x in (-.24,0,.24):
            self.drape((x,-.18,-.28),.22,.42,cloth,1)
        self.tube((0,-.30,0),(0,1.08,0),.072,old_bone,9,9)
        self.ell((0,.94,0),(.17,.18,.16),bone,9,10)
        self.plate([(-.22,.86),(.25,.75),(.48,1.04),(.38,1.39),(.04,1.26),(-.18,1.31)],0,.14,iron,9)
        self.plate([(.34,1.02),(.48,1.04),(.38,1.39),(.28,1.28)],-.015,.15,rust,9)

        return self


class NecromancerModel(BossModel):
    def __init__(self):
        # Ashcaller provides the articulated giant mage/staff rig. The geometry
        # below changes the identity into a distinct necromancer boss.
        super().__init__('boss_ashcaller')
        self.boss_kind = 'boss_necromancer'
        self.necromancer = True
        self.skin = color('69745f')
        self.light = color('9da17c')
        self.rust = color('49384f')
        self.ember = color('79d86b')
        self.dark = color('171d1a')
        self.ivory = color('d8cda8')
        build_bosses.SCALES['boss_necromancer'] = 2.12

    def regalia(self):
        super().regalia()
        # Bone necklace and belt of small skulls.
        for x in (-.34,-.17,0,.17,.34):
            self.ell((x,.18-abs(x)*.18,-.48),(.095,.082,.065),self.ivory,2,10)
            self.ell((x-.03,.20-abs(x)*.18,-.535),(.022,.018,.012),self.dark,2,8)
            self.ell((x+.03,.20-abs(x)*.18,-.535),(.022,.018,.012),self.dark,2,8)
        for x in (-.29,0,.29):
            self.ell((x,-.50,-.52),(.14,.12,.09),self.ivory,1,10)
            for eye in (-.045,.045):self.ell((x+eye,-.47,-.595),(.024,.021,.012),self.dark,1,8)
        # Tall hooked bone crown.
        for sign in (-1,1):
            self.spike((sign*.18,.31,-.02),(sign*.34,.78,.02),.06,self.ivory,3)
            self.spike((sign*.30,.56,.01),(sign*.46,.91,.08),.045,self.ivory,3)
        self.spike((0,.36,.04),(0,.95,.10),.072,self.ivory,3)

    def ogre_weapon(self,wood,iron,edge):
        super().ogre_weapon(wood,iron,edge)
        if self.mage:
            # Skull focus around the sickly green staff flame.
            self.ell((0,2.10,0),(.24,.22,.20),self.ivory,9,14)
            for x in (-.075,.075):self.ell((x,2.14,-.185),(.045,.045,.025),self.dark,9,8)
            self.ell((0,2.04,-.205),(.035,.055,.025),self.dark,9,8)
            for sign in (-1,1):self.spike((sign*.15,2.23,0),(sign*.36,2.48,.03),.045,self.ivory,9)


def build():
    SkeletonOgreModel().build().save()
    NecromancerModel().build().save()


if __name__ == '__main__':
    build()
