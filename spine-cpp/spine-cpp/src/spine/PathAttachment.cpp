/******************************************************************************
* Spine Runtimes Software License v2.5
*
* Copyright (c) 2013-2016, Esoteric Software
* All rights reserved.
*
* You are granted a perpetual, non-exclusive, non-sublicensable, and
* non-transferable license to use, install, execute, and perform the Spine
* Runtimes software and derivative works solely for personal or internal
* use. Without the written permission of Esoteric Software (see Section 2 of
* the Spine Software License Agreement), you may not (a) modify, translate,
* adapt, or develop new applications using the Spine Runtimes or otherwise
* create derivative works or improvements of the Spine Runtimes or (b) remove,
* delete, alter, or obscure any trademarks or any copyright, trademark, patent,
* or other intellectual property or proprietary rights notices on or in the
* Software, including any copy thereof. Redistributions in binary or source
* form must include this license and terms.
*
* THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
* IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
* EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
* SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
* PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, BUSINESS INTERRUPTION, OR LOSS OF
* USE, DATA, OR PROFITS) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
* IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
* ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
* POSSIBILITY OF SUCH DAMAGE.
*****************************************************************************/

#include <spine/PathAttachment.h>

namespace Spine {
RTTI_IMPL(PathAttachment, VertexAttachment);

PathAttachment::PathAttachment(const String &name) : VertexAttachment(name), _closed(false), _constantSpeed(false) {
}

Vector<float> &PathAttachment::getLengths() {
	return _lengths;
}

void PathAttachment::setLengths(Vector<float> &inValue) {
	_lengths.clear();
	_lengths.addAll(inValue);
}

bool PathAttachment::isClosed() {
	return _closed;
}

void PathAttachment::setClosed(bool inValue) {
	_closed = inValue;
}

bool PathAttachment::isConstantSpeed() {
	return _constantSpeed;
}

void PathAttachment::setConstantSpeed(bool inValue) {
	_constantSpeed = inValue;
}

String PathAttachment::toString() const {
	String str;
	str.append("PathAttachment { name: ").appendString(getName()).append(", closed: ").append(_closed).append(
			", constantSpeed: ").append(_constantSpeed);
	str.append(", worldVerticesLength: ").append(_worldVerticesLength);
	str.append(", bones: ").append(_bones).append(", weights: ").append(_vertices).append(" }");
	return str;
}
}
