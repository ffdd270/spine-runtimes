/******************************************************************************
 * Spine Runtimes License Agreement
 * Last updated January 1, 2020. Replaces all prior versions.
 *
 * Copyright (c) 2013-2020, Esoteric Software LLC
 *
 * Integration of the Spine Runtimes into software or otherwise creating
 * derivative works of the Spine Runtimes is permitted under the terms and
 * conditions of Section 2 of the Spine Editor License Agreement:
 * http://esotericsoftware.com/spine-editor-license
 *
 * Otherwise, it is permitted to integrate the Spine Runtimes into software
 * or otherwise create derivative works of the Spine Runtimes (collectively,
 * "Products"), provided that each user of the Products must obtain their own
 * Spine Editor license and redistribution of the Products in any form must
 * include this license and copyright notice.
 *
 * THE SPINE RUNTIMES ARE PROVIDED BY ESOTERIC SOFTWARE LLC "AS IS" AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL ESOTERIC SOFTWARE LLC BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES,
 * BUSINESS INTERRUPTION, OR LOSS OF USE, DATA, OR PROFITS) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THE SPINE RUNTIMES, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine {
	public class Bone implements Updatable {
		static public var yDown : Boolean;
		internal var _data : BoneData;
		internal var _skeleton : Skeleton;
		internal var _parent : Bone;
		internal var _children : Vector.<Bone> = new Vector.<Bone>();
		public var x : Number;
		public var y : Number;
		public var rotation : Number;
		public var scaleX : Number;
		public var scaleY : Number;
		public var shearX : Number;
		public var shearY : Number;
		public var ax : Number;
		public var ay : Number;
		public var arotation : Number;
		public var ascaleX : Number;
		public var ascaleY : Number;
		public var ashearX : Number;
		public var ashearY : Number;
		public var a : Number;
		public var b : Number;
		public var c : Number;
		public var d : Number;
		public var worldX : Number;
		public var worldY : Number;
		internal var _sorted : Boolean;
		public var active : Boolean;


		/** @param parent May be null. */
		public function Bone(data : BoneData, skeleton : Skeleton, parent : Bone) {
			if (data == null) throw new ArgumentError("data cannot be null.");
			if (skeleton == null) throw new ArgumentError("skeleton cannot be null.");
			_data = data;
			_skeleton = skeleton;
			_parent = parent;
			setToSetupPose();
		}

		public function isActive() : Boolean {
			return active;
		}

		/** Computes the world transform using the parent bone and this bone's local applied transform. */
		public function update() : void {
			updateWorldTransformWith(ax, ay, arotation, ascaleX, ascaleY, ashearX, ashearY);
		}

		/** Computes the world transform using the parent bone and this bone's local transform. */
		public function updateWorldTransform() : void {
			updateWorldTransformWith(x, y, rotation, scaleX, scaleY, shearX, shearY);
		}

		/** Computes the world transform using the parent bone and the specified local transform. The applied transform is set to the
		 * specified local transform. Child bones are not updated.
		 * <p>
		 * See <a href="http://esotericsoftware.com/spine-runtime-skeletons#World-transforms">World transforms</a> in the Spine
		 * Runtimes Guide. */
		public function updateWorldTransformWith(x : Number, y : Number, rotation : Number, scaleX : Number, scaleY : Number, shearX : Number, shearY : Number) : void {
			ax = x;
			ay = y;
			arotation = rotation;
			ascaleX = scaleX;
			ascaleY = scaleY;
			ashearX = shearX;
			ashearY = shearY;

			var rotationY : Number = 0, la : Number = 0, lb : Number = 0, lc : Number = 0, ld : Number = 0;
			var sin : Number = 0, cos : Number = 0;
			var s : Number = 0;
			var sx : Number = _skeleton.scaleX;
			var sy : Number = _skeleton.scaleY * (yDown ? -1 : 1);

			var parent : Bone = _parent;
			if (!parent) { // Root bone.
				rotationY = rotation + 90 + shearY;
				a = MathUtils.cosDeg(rotation + shearX) * scaleX * sx;
				b = MathUtils.cosDeg(rotationY) * scaleY * sx;
				c = MathUtils.sinDeg(rotation + shearX) * scaleX * sy;
				d = MathUtils.sinDeg(rotationY) * scaleY * sy;
				worldX = x * sx + _skeleton.x;
				worldY = y * sy + _skeleton.y;
				return;
			}

			var pa : Number = parent.a, pb : Number = parent.b, pc : Number = parent.c, pd : Number = parent.d;
			worldX = pa * x + pb * y + parent.worldX;
			worldY = pc * x + pd * y + parent.worldY;

			switch (data.transformMode) {
				case TransformMode.normal: {
					rotationY = rotation + 90 + shearY;
					la = MathUtils.cosDeg(rotation + shearX) * scaleX;
					lb = MathUtils.cosDeg(rotationY) * scaleY;
					lc = MathUtils.sinDeg(rotation + shearX) * scaleX;
					ld = MathUtils.sinDeg(rotationY) * scaleY;
					a = pa * la + pb * lc;
					b = pa * lb + pb * ld;
					c = pc * la + pd * lc;
					d = pc * lb + pd * ld;
					return;
				}
				case TransformMode.onlyTranslation: {
					rotationY = rotation + 90 + shearY;
					a = MathUtils.cosDeg(rotation + shearX) * scaleX;
					b = MathUtils.cosDeg(rotationY) * scaleY;
					c = MathUtils.sinDeg(rotation + shearX) * scaleX;
					d = MathUtils.sinDeg(rotationY) * scaleY;
					break;
				}
				case TransformMode.noRotationOrReflection: {
					s = pa * pa + pc * pc;
					var prx : Number = 0;
					if (s > 0.0001) {
						s = Math.abs(pa * pd - pb * pc) / s;
						pa /= _skeleton.scaleX;
						pc /= _skeleton.scaleY;
						pb = pc * s;
						pd = pa * s;
						prx = Math.atan2(pc, pa) * MathUtils.radDeg;
					} else {
						pa = 0;
						pc = 0;
						prx = 90 - Math.atan2(pd, pb) * MathUtils.radDeg;
					}
					var rx : Number = rotation + shearX - prx;
					var ry : Number = rotation + shearY - prx + 90;
					la = MathUtils.cosDeg(rx) * scaleX;
					lb = MathUtils.cosDeg(ry) * scaleY;
					lc = MathUtils.sinDeg(rx) * scaleX;
					ld = MathUtils.sinDeg(ry) * scaleY;
					a = pa * la - pb * lc;
					b = pa * lb - pb * ld;
					c = pc * la + pd * lc;
					d = pc * lb + pd * ld;
					break;
				}
				case TransformMode.noScale:
				case TransformMode.noScaleOrReflection: {
					cos = MathUtils.cosDeg(rotation);
					sin = MathUtils.sinDeg(rotation);
					var za : Number = (pa * cos + pb * sin) / sx;
					var zc : Number = (pc * cos + pd * sin) / sy;
					s = Math.sqrt(za * za + zc * zc);
					if (s > 0.00001) s = 1 / s;
					za *= s;
					zc *= s;
					s = Math.sqrt(za * za + zc * zc);
					if (data.transformMode == TransformMode.noScale
						&& (pa * pd - pb * pc < 0) != (sx < 0 != sy < 0)) s = -s;
					var r : Number = Math.PI / 2 + Math.atan2(zc, za);
					var zb : Number = Math.cos(r) * s;
					var zd : Number = Math.sin(r) * s;
					la = MathUtils.cosDeg(shearX) * scaleX;
					lb = MathUtils.cosDeg(90 + shearY) * scaleY;
					lc = MathUtils.sinDeg(shearX) * scaleX;
					ld = MathUtils.sinDeg(90 + shearY) * scaleY;
					a = za * la + zb * lc;
					b = za * lb + zb * ld;
					c = zc * la + zd * lc;
					d = zc * lb + zd * ld;
					break;
				}
			}
			a *= sx;
			b *= sx;
			c *= sy;
			d *= sy;
		}

		public function setToSetupPose() : void {
			x = data.x;
			y = data.y;
			rotation = data.rotation;
			scaleX = data.scaleX;
			scaleY = data.scaleY;
			shearX = data.shearX;
			shearY = data.shearY;
		}

		public function get data() : BoneData {
			return _data;
		}

		public function get skeleton() : Skeleton {
			return _skeleton;
		}

		public function get parent() : Bone {
			return _parent;
		}

		public function get children() : Vector.<Bone> {
			;
			return _children;
		}

		public function get worldRotationX() : Number {
			return Math.atan2(c, a) * MathUtils.radDeg;
		}

		public function get worldRotationY() : Number {
			return Math.atan2(d, b) * MathUtils.radDeg;
		}

		public function get worldScaleX() : Number {
			return Math.sqrt(a * a + c * c);
		}

		public function get worldScaleY() : Number {
			return Math.sqrt(b * b + d * d);
		}

		/** Computes the applied transform values from the world transform.
		 * <p>
		 * If the world transform is modified (by a constraint, {@link #rotateWorld(float)}, etc) then this method should be called so
		 * the applied transform matches the world transform. The applied transform may be needed by other code (eg to apply another
		 * constraint).
		 * <p>
		 * Some information is ambiguous in the world transform, such as -1,-1 scale versus 180 rotation. The applied transform after
		 * calling this method is equivalent to the local transform used to compute the world transform, but may not be identical. */
		internal function updateAppliedTransform() : void {
			var parent : Bone = this.parent;
			if (parent == null) {
				ax = worldX - skeleton.x;
				ay = worldY - skeleton.y;
				arotation = Math.atan2(c, a) * MathUtils.radDeg;
				ascaleX = Math.sqrt(a * a + c * c);
				ascaleY = Math.sqrt(b * b + d * d);
				ashearX = 0;
				ashearY = Math.atan2(a * b + c * d, a * d - b * c) * MathUtils.radDeg;
				return;
			}
			var pa : Number = parent.a, pb : Number = parent.b, pc : Number = parent.c, pd : Number = parent.d;
			var pid : Number = 1 / (pa * pd - pb * pc);
			var dx : Number = worldX - parent.worldX, dy : Number = worldY - parent.worldY;
			ax = (dx * pd * pid - dy * pb * pid);
			ay = (dy * pa * pid - dx * pc * pid);
			var ia : Number = pid * pd;
			var id : Number = pid * pa;
			var ib : Number = pid * pb;
			var ic : Number = pid * pc;
			var ra : Number = ia * a - ib * c;
			var rb : Number = ia * b - ib * d;
			var rc : Number = id * c - ic * a;
			var rd : Number = id * d - ic * b;
			ashearX = 0;
			ascaleX = Math.sqrt(ra * ra + rc * rc);
			if (scaleX > 0.0001) {
				var det : Number = ra * rd - rb * rc;
				ascaleY = det / ascaleX;
				ashearY = Math.atan2(ra * rb + rc * rd, det) * MathUtils.radDeg;
				arotation = Math.atan2(rc, ra) * MathUtils.radDeg;
			} else {
				ascaleX = 0;
				ascaleY = Math.sqrt(rb * rb + rd * rd);
				ashearY = 0;
				arotation = 90 - Math.atan2(rd, rb) * MathUtils.radDeg;
			}
		}

		public function worldToLocal(world : Vector.<Number>) : void {
			var invDet : Number = 1 / (a * d - b * c);
			var x : Number = world[0] - worldX, y : Number = world[1] - worldY;
			world[0] = x * d * invDet - y * b * invDet;
			world[1] = y * a * invDet - x * c * invDet;
		}

		public function localToWorld(local : Vector.<Number>) : void {
			var localX : Number = local[0], localY : Number = local[1];
			local[0] = localX * a + localY * b + worldX;
			local[1] = localX * c + localY * d + worldY;
		}

		public function worldToLocalRotation(worldRotation : Number) : Number {
			var sin : Number = MathUtils.sinDeg(worldRotation), cos : Number = MathUtils.cosDeg(worldRotation);
			return Math.atan2(a * sin - c * cos, d * cos - b * sin) * MathUtils.radDeg + rotation - shearX;
		}

		public function localToWorldRotation(localRotation : Number) : Number {
			localRotation -= rotation - shearX;
			var sin : Number = MathUtils.sinDeg(localRotation), cos : Number = MathUtils.cosDeg(localRotation);
			return Math.atan2(cos * c + sin * d, cos * a + sin * b) * MathUtils.radDeg;
		}

		/** Rotates the world transform the specified amount.
		 * <p>
		 * After changes are made to the world transform, {@link #updateAppliedTransform()} should be called and {@link #update()} will
		 * need to be called on any child bones, recursively. */
		public function rotateWorld(degrees : Number) : void {
			var cos : Number = MathUtils.cosDeg(degrees), sin : Number = MathUtils.sinDeg(degrees);
			var a : Number = this.a, b : Number = this.b, c : Number = this.c, d : Number = this.d;
			this.a = cos * a - sin * c;
			this.b = cos * b - sin * d;
			this.c = sin * a + cos * c;
			this.d = sin * b + cos * d;
		}

		public function toString() : String {
			return this.data._name;
		}
	}
}